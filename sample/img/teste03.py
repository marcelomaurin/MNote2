import cv2
import numpy as np

# Função para exibir a imagem da câmera
def show_camera_image():
    # Inicializar a captura de vídeo
    cap = cv2.VideoCapture(1)  # 0 representa a câmera padrão, pode ser alterado se você tiver várias câmeras
    # Capturar o próximo quadro
    ret, frame = cap.read()    
    return frame
    
def redefine(imagem):
    # Definir o tamanho desejado para a janela e a imagem
    window_width = 600
    window_height = 400
    # Redimensionar a imagem para o tamanho desejado
    imginv = cv2.resize(imagem, (window_width, window_height))
    return imginv    
    
def MostraImg(texto, imagem):
    #imagem redimensionada
    rimagem = redefine(imagem)
    # Exibir o quadro capturado
    cv2.imshow(texto, rimagem)
    
    
def Esperar():    
    while True:
        # Pressione 'q' para sair do loop
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
            
def MascaraInvertida(imagem):
    # Aplicar o limite para definir os valores verdadeiros
    binary_image = cv2.inRange(imagem, 55, 255)
    # Converter a imagem binária em escala de cinza
    grayscale_image = cv2.cvtColor(binary_image, cv2.COLOR_GRAY2BGR)
    return grayscale_image
    
    
 
def Fundobranco(imagem_colorida):
    # Converter a imagem colorida para escala de cinza
    imagem_cinza = cv2.cvtColor(imagem_colorida, cv2.COLOR_BGR2GRAY)
    # Aplicar uma operação de limiarização para obter a imagem binária
    _, imagem_binaria = cv2.threshold(imagem_cinza, 127, 255, cv2.THRESH_BINARY)
        # Criar uma máscara binária onde os pontos diferentes são definidos como branco
 
    # Encontrar os contornos na imagem binária
    contornos, _ = cv2.findContours(imagem_binaria, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    # Criar uma máscara preenchida com branco
    mascara = np.ones_like(imagem_colorida) * 255
    
    # Preencher os contornos com a cor preta na máscara
    cv2.drawContours(mascara, contornos, -1, 0, thickness=cv2.FILLED)
    
    # Aplicar a máscara na imagem original
    imagem_fundobranco = cv2.bitwise_and(imagem_colorida, mascara)
    
    return imagem_fundobranco    
 
 
def Preencher(image):
    # Converter a imagem binária em escala de cinza
    grayscale_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    threshold = 240  # Limite de limiarização para definir os pontos pontilhados
    # Aplicar uma operação de limiarização para obter a imagem binária
    _, binary_image = cv2.threshold(grayscale_image, threshold, 255, cv2.THRESH_BINARY)
    # Encontrar os contornos na imagem binária
    contours, _ = cv2.findContours(binary_image, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    # Criar uma máscara para o preenchimento
    mask = np.zeros_like(grayscale_image)
    # Preencher os contornos com a cor branca
    cv2.drawContours(mask, contours, -1, 255, thickness=cv2.FILLED)

    # Aplicar a máscara na imagem original para preencher a área pontilhada
    filled_image = cv2.bitwise_and(grayscale_image, mask)
    
    return filled_image
    
def encontrar_contornos(imagem):
    # Converter a imagem em escala de cinza
    imagem_cinza = cv2.cvtColor(imagem, cv2.COLOR_BGR2GRAY)
    
    # Aplicar uma operação de limiarização para obter a imagem binária
    _, imagem_binaria = cv2.threshold(imagem_cinza, 127, 255, cv2.THRESH_BINARY)
    
    # Encontrar os contornos na imagem binária
    contornos, _ = cv2.findContours(imagem_binaria, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    
    return contornos
    


def ImagemMascara(imagem_colorida, imagem_cinza):
    # Converter a imagem colorida para escala de cinza
    imagem_colorida_cinza = cv2.cvtColor(imagem_colorida, cv2.COLOR_BGR2GRAY)
    
    # Aplicar uma operação de diferença entre as imagens em escala de cinza
    diferenca = cv2.absdiff(imagem_colorida_cinza, imagem_cinza)
    
    # Criar uma máscara binária onde os pontos diferentes são definidos como branco
    _, mascara_binaria = cv2.threshold(diferenca, 128, 255, cv2.THRESH_BINARY)
    
    # Criar uma imagem em branco do mesmo tamanho da imagem colorida
    imagem_mascara = np.zeros_like(imagem_colorida)
    
    # Preencher os pontos da imagem colorida comuns à imagem cinza
    imagem_mascara[mascara_binaria != 255] = imagem_colorida[mascara_binaria != 255]

    
    return imagem_mascara
    




def Fechar():
    # Liberar os recursos
    cap.release()
    cv2.destroyAllWindows()
     

# Início do código
imagem = show_camera_image()

# Inicio de codigo
imagem = show_camera_image()

# Separar os canais de cor da imagem
blue, green, red = cv2.split(imagem)

mascara = MascaraInvertida(blue)
#pmascara = Preencher(mascara)
pmascara = Preencher(mascara)

imagem2 = ImagemMascara(imagem,pmascara)
imagem3 = Fundobranco(imagem2)

contornos = encontrar_contornos(imagem2)

# Desenhar os contornos na imagem original
cv2.drawContours(imagem, contornos, -1, (0, 255, 0), 2)


MostraImg('invertida',imagem3)
MostraImg('imagem',imagem)

Esperar()
