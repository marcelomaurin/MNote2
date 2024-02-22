import spacy
from spacy.matcher import Matcher

def padraoMM(texto1):
    # Carrega o modelo em português do spaCy
    nlp = spacy.load("pt_core_news_sm")

    # Inicializa o Matcher
    matcher = Matcher(nlp.vocab)

    pattern1 = [{"IS_DIGIT": False}, {"LOWER": "mm"}]
    matcher.add("MM_PATTERN_LOWER2", [pattern1])
    pattern1 = [{"IS_DIGIT": True}, {"LOWER": "mm"}]
    matcher.add("MM_PATTERN_LOWER", [pattern1])
    #pattern2 = [{"IS_DIGIT": True},  {"UPPER": "MM"}]
    #matcher.add("MM_PATTERN_UPPER", [pattern2])
    pattern2 = [{"IS_DIGIT": False},  {"LOWER": "mm"}]
    matcher.add("MM_PATTERN_UPPER2", [pattern2])
    pattern3 = [{"IS_DIGIT": True}, {"IS_SPACE": True}, {"LOWER": "mm"}]
    matcher.add("MM_PATTERN_SPACE_LOW", [pattern3])
    #pattern4 = [{"IS_DIGIT": True}, {"IS_SPACE": True},  {"UPPER": "MM"}]
    #matcher.add("MM_PATTERN_SPACE_UPP", [pattern4])
    #pattern4 = [{"IS_DIGIT": False}, {"IS_SPACE": True}, {"UPPER": "MM"} ]
    #matcher.add("MM_PATTERN_SPACE_UPP2", [pattern4])

    # Processa o texto com o spaCy
    doc = nlp(texto1)

    # Inicializa uma lista para armazenar o texto processado
    #texto_processado = texto1

    # Itera sobre os resultados do Matcher
    for match_id, start, end in matcher(doc):
        # Obtém o span correspondente ao padrão encontrado
        span = doc[start:end]
        print("span:")
        print(span)
        # Converte o número para o formato 0,00mm
        numero = float(span[0].text.replace(",", "."))
        numero_formatado = f"{numero:.2f}mm"
        print(numero_formatado)
        info = span[0].text
        print(info)
        # Adiciona o número formatado à lista de texto processado
        texto1.replace(info,numero_formatado)

    # Substitui os números seguidos de "mm" no texto original pelo número formatado
    #for numero_formatado in texto_processado:
    #    texto1 = texto1.replace(numero_formatado.split("mm")[0] + "mm", numero_formatado)

    return texto1

# Exemplo de uso
texto = "A placa tem 10,0mm x 0,1mm de espessura, 20,000MM de largura e 0,10 mm de comprimento."
texto_processado = padraoMM(texto)
print(texto_processado)

