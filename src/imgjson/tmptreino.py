import tensorflow as tf
import numpy as np
import json
import sys
import os

def preprocess_json(file_path):
    with open(file_path, "r") as file:
        json_data = file.read()
    # Escapar quebras de linha
    json_data = json_data.replace("\n", "\\n")
    return json_data

import json
import os
import numpy as np

def CriaPasta(nome_pasta):
    # Pegando o diretório atual do script
    dir_atual = os.path.dirname(os.path.realpath(__file__))

    # Caminho para a subpasta 'marcas'
    caminho_marcas = os.path.join(dir_atual, 'marcas')

    # Criando a subpasta 'marcas' se ela não existir
    if not os.path.exists(caminho_marcas):
        os.mkdir(caminho_marcas)

    # Caminho completo para a nova pasta dentro de 'marcas'
    caminho_completo = os.path.join(caminho_marcas, nome_pasta)

    # Criando a pasta com o nome fornecido, se ela não existir
    if not os.path.exists(caminho_completo):
        os.mkdir(caminho_completo)

    return caminho_completo

def load_data(json_file):
    # Verificar se o arquivo existe
    if not os.path.exists(json_file):
        raise FileNotFoundError(f"O arquivo {json_file} não foi encontrado.")

    # Verificar se o arquivo pode ser lido
    if not os.access(json_file, os.R_OK):
        raise PermissionError(f"Sem permissão para ler o arquivo {json_file}.")

    with open(json_file, 'r') as file:
        try:
            data = file.read()
            data = data.replace("\n", "")
            data = data.replace("\r", "")
            data = json.loads(data)
        except json.JSONDecodeError as e:
            print(f"Erro ao ler o JSON: {e}")
            return None, None

    # Os inputs estão na primeira entrada de 'training_tag'
    #inputs = np.array(data['training_tag'][0]['inputs'], dtype=np.float32)
    inputs = np.array([item['inputs'] for item in data['training_data']], dtype=np.float32)

    # Imprimir os 10 primeiros registros de inputs
    print("Primeiros 10 registros de inputs:")
    print(inputs[:3])
    # Os outputs estão na primeira entrada de 'training_data'
    #outputs = np.array(data['training_data'][0]['output'], dtype=np.float32)
    outputs = np.array([item['output'] for item in data['training_data']], dtype=np.float32)

    print("Primeiros 10 registros de outputs:")
    print(outputs[:3])
    inputcol =   data['training_detail'][0]['InputCols']
    outputcol =   data['training_detail'][0]['OutputCols']
    return inputs, outputs , inputcol, outputcol

def train_and_save_model(inputs, outputs,inputcol, outputcol,  model_file):
    model = tf.keras.Sequential([tf.keras.layers.Dense(inputcol, activation='relu'),tf.keras.layers.Dense(outputcol, activation='sigmoid')])
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
    model.fit(inputs, outputs, epochs=10)


    model_pathfile = CriaPasta(model_file)
    print("Save File:"+model_pathfile)
    model.save(model_pathfile)

if __name__ == "__main__":
    print("Programa de treinamento de rede neural")
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_json_file> <output_model_file>")
        input_json_file = "C:\\Users\\marcelo.maurin\\Desktop\\projetos\\IMGJSON\\training_data.json"
        output_model_file = "john deere"
        #sys.exit(1)
    else:
        input_json_file = sys.argv[1]
        output_model_file = sys.argv[2]
    preprocess_json(input_json_file)
    print("InputJSON:"+input_json_file)
    print("JSON Saida:"+output_model_file)
    inputs, outputs, inputcol, outputcol  = load_data(input_json_file)
    print("inputcol:"+inputcol)
    print("outputcol:"+outputcol)

    train_and_save_model(inputs, outputs, inputcol,outputcol, output_model_file)

