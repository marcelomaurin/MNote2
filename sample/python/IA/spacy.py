import os
import site
import sys
import subprocess

# Verifique se o Spacy está instalado, se não, instale-o
try:
    import spacy
except ImportError:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install', 'spacy'])
    # Reimporta os pacotes instalados durante a execução
    import site; os.execl(sys.executable, os.path.abspath(__file__), *sys.argv)

# Verifique se o modelo de língua portuguesa está instalado, se não, instale-o
try:
    spacy.load('pt_core_news_sm')
except IOError:
    subprocess.check_call([sys.executable, '-m', 'spacy', 'download', 'pt_core_news_sm'])
    # Reimporta os pacotes instalados durante a execução
    import site; os.execl(sys.executable, os.path.abspath(__file__), *sys.argv)

import spacy
from spacy.matcher import Matcher

nlp = spacy.load("pt_core_news_sm")
matcher = Matcher(nlp.vocab)

# Definindo o padrão
pattern = [{'IS_DIGIT': True, 'LENGTH': 4}, # 4 digitos
           {'IS_PUNCT': True},  # um separador que pode ser espaço, traço ou ponto
           {'IS_ALPHA': True, 'LENGTH': 2}, # duas letras
           {'IS_PUNCT': True},  # um separador que pode ser espaço, traço ou ponto
           {'IS_DIGIT': True, 'LENGTH': (1, 2)}]  # talvez 1 ou 2 números

# Adicionando o padrão ao matcher
matcher.add('CODIGO', None, pattern)

# Processando algum texto
doc = nlp("1234-AZ 78")

# Chamando o matcher no doc
matches = matcher(doc)

# Iterando sobre as correspondências
for match_id, start, end in matches:
    # Encontre o token combinado e imprima-o
    matched_span = doc[start:end]
    print(matched_span.text)


