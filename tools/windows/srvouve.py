#!/usr/bin/env python3

import speech_recognition as sr
import socket
import threading
import numpy as np
import sounddevice as sd
from queue import Queue
import time
from scipy.signal import butter, lfilter

# ===== Configuração de áudio e buffer =====
SAMPLE_RATE = 16000
SILENCE_THRESHOLD = 0.02
MIN_SILENCE_FRAMES = int(SAMPLE_RATE * 0.3)
INTERVALO_PROCESSAMENTO = 0.3

audio_buffer = []
buffer_lock = threading.Lock()
captura_ativa = True
flgProcessar = threading.Event()
audio_stream = None

# ===== Filtros e normalização =====
def butter_bandpass(lowcut, highcut, fs, order=4):
    nyq = 0.5 * fs
    low = lowcut / nyq
    high = highcut / nyq
    return butter(order, [low, high], btype='band')

def aplicar_filtro(audio_np, lowcut=300.0, highcut=3400.0, fs=SAMPLE_RATE):
    b, a = butter_bandpass(lowcut, highcut, fs)
    return lfilter(b, a, audio_np)

def normalizar_audio(audio_np):
    max_val = np.max(np.abs(audio_np))
    if max_val == 0:
        return audio_np
    return audio_np / max_val

def detecta_silencio(audio_data, threshold=SILENCE_THRESHOLD, percentile=90):
    rms = np.sqrt(np.mean(np.square(audio_data)))
    energia_percentil = np.percentile(np.abs(audio_data), percentile)
    limiar_adaptativo = max(threshold, energia_percentil * 0.5)
    return rms < limiar_adaptativo

# ===== Captura contínua leve =====
def callback(indata, frames, time_info, status):
    global audio_buffer
    with buffer_lock:
        audio_buffer.extend(indata[:, 0].tolist())

def Captura_Audio():
    global audio_stream
    audio_stream = sd.InputStream(callback=callback, channels=1, samplerate=SAMPLE_RATE)
    audio_stream.start()

# ===== Análise do Buffer =====
def analisa_buffer():
    global audio_buffer
    tempo_ultimo_processamento = time.time()

    while captura_ativa:
        with buffer_lock:
            if len(audio_buffer) >= MIN_SILENCE_FRAMES:
                temp_buffer = np.array(audio_buffer[-MIN_SILENCE_FRAMES:], dtype=np.float32)
                temp_filtrado = aplicar_filtro(temp_buffer)

                if detecta_silencio(temp_filtrado):
                    if time.time() - tempo_ultimo_processamento >= INTERVALO_PROCESSAMENTO:
                        flgProcessar.set()
                        tempo_ultimo_processamento = time.time()
                elif len(audio_buffer) >= SAMPLE_RATE * 8:
                    flgProcessar.set()
                    tempo_ultimo_processamento = time.time()
        time.sleep(0.05)

# ===== Extração segura do buffer =====
def PegaBuffer():
    global audio_buffer
    if not flgProcessar.is_set():
        return None

    with buffer_lock:
        temp_buffer = np.array(audio_buffer, dtype=np.float32)
        temp_filtrado = aplicar_filtro(temp_buffer)

        fim_fala = None
        for i in range(len(temp_filtrado) - MIN_SILENCE_FRAMES, 0, -1):
            janela = temp_filtrado[i - MIN_SILENCE_FRAMES:i]
            if detecta_silencio(janela):
                fim_fala = i
                break

        if fim_fala is None:
            flgProcessar.clear()
            return None
 
        trecho_np = temp_buffer[:fim_fala]
        audio_buffer = audio_buffer[fim_fala:]
        flgProcessar.clear()

    trecho_np = aplicar_filtro(trecho_np)
    trecho_np = normalizar_audio(trecho_np)
    return trecho_np.tolist()

# ===== Reconhecimento de fala =====
r = sr.Recognizer()
clients = []
last_said = Queue(maxsize=10)

def broadcast_message(message):
    for client in clients[:]:
        try:
            print(message.encode('utf-8'))
            client.send(message.encode('utf-8'))
        except:
            clients.remove(client)

def client_handler(client_socket):
    while True:
        message = last_said.get(block=True)
        broadcast_message(message)

def accept_connections(server):
    while True:
        client_sock, addr = server.accept()
        clients.append(client_sock)
        threading.Thread(target=client_handler, args=(client_sock,), daemon=True).start()

# ===== Thread de recebimento via socket =====
def socket_receiver():
    while True:
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect(('127.0.0.1', 8097))
            print("✅ Conectado ao servidor socket (8097).")
            
            while True:
                data = sock.recv(1024).decode('utf-8')
                if data:
                    print(f"📨 Mensagem recebida via socket: {data}")
                    broadcast_message(data)

        except ConnectionRefusedError:
            print("⚠️ Não foi possível conectar ao servidor socket (8098). Tentando novamente em 5 segundos...")
            time.sleep(5)
        except Exception as e:
            print(f"❌ Erro inesperado: {e}. Reconectando em 5 segundos...")
            time.sleep(5)
        finally:
            sock.close()


# ===== Processamento do áudio =====
def ProcessaAudio(audio_np):
    audio_pcm = (audio_np * 32767).astype(np.int16).tobytes()
    audio_data = sr.AudioData(audio_pcm, SAMPLE_RATE, 2)

    try:
        text = r.recognize_google(audio_data, language='pt-BR')
        print("🗣️ Você disse:", text)
        if last_said.full():
            last_said.get_nowait()
        last_said.put_nowait(text)
        broadcast_message(text)
    except Exception as e:
        print("Erro reconhecimento:", e)

def processamento_continuo():
    while True:
        trecho = PegaBuffer()
        if trecho:
            audio_np = np.array(trecho, dtype=np.float32)
            ProcessaAudio(audio_np)
        time.sleep(3)

# ===== Inicialização =====
def setup():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('0.0.0.0', 8097))
    server.listen(5)

    threading.Thread(target=accept_connections, args=(server,), daemon=True).start()
    threading.Thread(target=socket_receiver, daemon=True).start()
    threading.Thread(target=Captura_Audio, daemon=True).start()
    threading.Thread(target=analisa_buffer, daemon=True).start()
    threading.Thread(target=processamento_continuo, daemon=True).start()

# ===== Loop principal =====
def loop():
    print("🎧 Sistema pronto e capturando áudio...")
    while True:
        time.sleep(1)

if __name__ == "__main__":
    setup()
    loop()