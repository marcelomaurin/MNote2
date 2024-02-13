import os
import sys

def contar_linhas_arquivos(diretorio, extensao):
    total_linhas = 0
    total_arquivos = 0

    for pasta_raiz, _, arquivos in os.walk(diretorio):
        for arquivo in arquivos:
            if arquivo.endswith(extensao):
                caminho_arquivo = os.path.join(pasta_raiz, arquivo)
                with open(caminho_arquivo, 'r', encoding='utf-8') as f:
                    linhas_arquivo = sum(1 for linha in f)
                    total_linhas += linhas_arquivo
                    total_arquivos += 1
                    print(f'{caminho_arquivo}: {linhas_arquivo} linhas')

    print(f'Total de arquivos com a extensão {extensao}: {total_arquivos}')
    print(f'Total de linhas de código nos arquivos com a extensão {extensao}: {total_linhas}')

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python contar_linhas.py <diretório> <extensão>")
        sys.exit(1)

    diretorio = sys.argv[1]
    extensao = sys.argv[2]
    contar_linhas_arquivos(diretorio, extensao)

