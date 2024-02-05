# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import os
from PIL import Image

def limpalista(arquivo):
    """
    Cria ou sobrescreve um arquivo com o nome especificado no parâmetro, deixando-o em branco.
    
    Parâmetros:
    - arquivo (str): Nome ou caminho do arquivo a ser criado/sobrescrito.
    """
    with open(arquivo, 'w') as f:
        pass  # Apenas cria ou sobrescreve o arquivo, deixando-o em branco

def Inserelista(arquivo, linha):
    """
    Adiciona uma string ao final do arquivo especificado.
    
    Parâmetros:
    - arquivo (str): Nome ou caminho do arquivo onde a linha será inserida.
    - linha (str): A string que será adicionada ao arquivo.
    """
    with open(arquivo, 'a') as f:
        f.write(linha + '\n')  # Adiciona a string e uma nova linha ao final do arquivo

# Exemplo de uso:
# limpalista('meuarquivo.txt')
# Inserelista('meuarquivo.txt', 'Primeira linha inserida')
# Inserelista('meuarquivo.txt', 'Segunda linha inserida')

def limpalista(arquivo):
    """
    Cria ou sobrescreve um arquivo com o nome especificado no parâmetro, deixando-o em branco.
    
    Parâmetros:
    - arquivo (str): Nome ou caminho do arquivo a ser criado/sobrescrito.
    """
    with open(arquivo, 'w') as f:
        pass  # Apenas cria ou sobrescreve o arquivo, deixando-o em branco

def Inserelista(arquivo, linha):
    """
    Adiciona uma string ao final do arquivo especificado.
    
    Parâmetros:
    - arquivo (str): Nome ou caminho do arquivo onde a linha será inserida.
    - linha (str): A string que será adicionada ao arquivo.
    """
    with open(arquivo, 'a') as f:
        f.write(linha + '\n')  # Adiciona a string e uma nova linha ao final do arquivo
 
# Exemplo de uso:
# limpalista('meuarquivo.txt')
# Inserelista('meuarquivo.txt', 'Primeira linha inserida')
# Inserelista('meuarquivo.txt', 'Segunda linha inserida')




def converter_imagens_cinza(diretorio_entrada, diretorio_saida):
    # Verifica se o diretório de saída existe. Se não, cria-o.
    if not os.path.exists(diretorio_saida):
        os.makedirs(diretorio_saida)
    arquivo = os.path.join(diretorio_saida, "lista.txt")
    limpalista(arquivo)
    # Percorre os arquivos no diretório de entrada
    for filename in os.listdir(diretorio_entrada):
        print(f"filename:{filename}")
        # Verifica se o arquivo é uma imagem .jpg
        if filename.lower().endswith(".jpg"):  
            # Cria os caminhos completos de entrada e saída para o arquivo
            caminho_entrada = os.path.join(diretorio_entrada, filename)
            caminho_saida = os.path.join(diretorio_saida, filename)
            
            # Abre a imagem
            with Image.open(caminho_entrada) as img:
                # Converte a imagem para cinza
                img_cinza = img.convert("L")
                # Salva a imagem convertida no diretório de saída
                # img_cinza.save(caminho_saida)
                # Redimensiona a imagem para 100x100 pixels
                img_redimensionada = img_cinza.resize((100, 100))
                
                # Salva a imagem convertida e redimensionada no diretório de saída
                img_redimensionada.save(caminho_saida)
                Inserelista(arquivo,caminho_saida)
            print(f"Imagem {filename} convertida para cinza e salva em {caminho_saida}.")


# Converte imagens em positivas coloridas testes:
diretorio_entrada = "D:/projetos/maurinsoft/hemacias/fotos/positivas coloridas testes"
diretorio_saida = "D:/projetos/maurinsoft/hemacias/fotos/positivas cinza testes"
converter_imagens_cinza(diretorio_entrada, diretorio_saida)


# Converte imagens em positivas coloridas treino:
diretorio_entrada = "D:/projetos/maurinsoft/hemacias/fotos/positivas coloridas treino"
diretorio_saida = "D:/projetos/maurinsoft/hemacias/fotos/positivas cinza treino"
converter_imagens_cinza(diretorio_entrada, diretorio_saida)

print('Finalizou\n')