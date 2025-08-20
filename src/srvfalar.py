import socket
import threading
from gtts import gTTS
import os
import pygame
import time
import tempfile

# Configurações do servidor
HOST = '0.0.0.0'
PORT = 8096
BUFFER_SIZE = 1024

# Diretório específico para os arquivos de áudio, dentro do temp
DIRETORIO_AUDIO = os.path.join(tempfile.gettempdir(), "dados_audio")
contador_audio = 1  # Número sequencial do áudio

def criar_diretorio_audio():
    """Cria o diretório para armazenar arquivos de áudio, se não existir."""
    if not os.path.exists(DIRETORIO_AUDIO):
        os.makedirs(DIRETORIO_AUDIO)
        print(f"Diretório temporário '{DIRETORIO_AUDIO}' criado.")

def limpar_mp3():
    """Apaga todos os arquivos .mp3 no diretório de áudio."""
    for arquivo in os.listdir(DIRETORIO_AUDIO):
        if arquivo.endswith(".mp3"):
            caminho = os.path.join(DIRETORIO_AUDIO, arquivo)
            try:
                os.remove(caminho)
                print(f"Arquivo {arquivo} apagado na inicialização.")
            except Exception as e:
                print(f"Erro ao apagar {arquivo}: {e}")

def texto_para_voz(texto):
    """Converte texto em fala e reproduz."""
    global contador_audio
    print(f"Recebido: {texto}")

    filename = f"audio_{contador_audio}.mp3"
    caminho_completo = os.path.join(DIRETORIO_AUDIO, filename)
    contador_audio += 1  # Incrementa o número do áudio

    try:
        tts = gTTS(text=texto, lang='pt', slow=False)
        tts.save(caminho_completo)

        pygame.mixer.init()
        pygame.mixer.music.load(caminho_completo)
        pygame.mixer.music.play()

        while pygame.mixer.music.get_busy():
            time.sleep(0.1)

    except Exception as e:
        print(f"Erro ao reproduzir áudio: {e}")
    finally:
        print(f"Arquivo {filename} falado!")

def Setup():
    """Configura o servidor socket e limpa arquivos .mp3."""
    criar_diretorio_audio()
    limpar_mp3()
    global server_socket
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((HOST, PORT))
    server_socket.listen(5)
    print(f"Servidor iniciado na porta {PORT}")

def Loop():
    """Loop principal que aceita conexões e processa mensagens."""
    while True:
        client_socket, addr = server_socket.accept()
        print(f"Conexão de {addr}")
        threading.Thread(target=handle_client, args=(client_socket,)).start()

def handle_client(client_socket):
    """Processa dados do cliente."""
    with client_socket as sock:
        data = sock.recv(BUFFER_SIZE)
        if data:
            texto = data.decode('utf-8')
            texto_para_voz(texto)

if __name__ == "__main__":
    Setup()
    Loop()
