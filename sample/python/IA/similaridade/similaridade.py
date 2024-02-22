import spacy
from spacy import displacy


# Carregando o modelo do spaCy para Português
nlp = spacy.load("pt_core_news_sm")

def calcular_similaridade(texto1, texto2):
    # Processando os textos com o modelo do spaCy
    doc1 = nlp(texto1)
    doc2 = nlp(texto2)

    # Calculando a similaridade entre os documentos
    similaridade = doc1.similarity(doc2)
    return similaridade

def main():
    #Texto do cliente
    texto1 = "cachorro roeu o sapato do seu ze"
    #Texto do selecionado
    texto2 = "o sapato do seu ze o cachorro roeu e apanhou"
    #texto que eu quero
    texto3 = "o cachorro do seu ze foi embora porque apanhou"

    similaridade = calcular_similaridade(texto1, texto2)

    print(f"A similaridade entre os textos é: {similaridade}")
    similaridade = calcular_similaridade(texto1, texto3)

    print(f"A similaridade entre os textos originais é: {similaridade}")

if __name__ == "__main__":
    main()

