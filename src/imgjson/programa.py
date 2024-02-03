import tensorflow as tf
import numpy as np
import json
import sys
import os
import traceback

def preprocess_json(file_path):
    # Verifica se o arquivo existe
    if not os.path.exists(file_path):
        print(f"Erro: O arquivo {file_path} não foi encontrado.")
        return None

    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            json_data = file.read()

        # Escapar quebras de linha
        json_data = json_data.replace("\n", "")
        data = json.loads(json_data)

        return data
    except json.JSONDecodeError as e:
        print(f"Erro ao decodificar JSON: {e}")
        return None
    except Exception as e:
        print(f"Erro ao processar o arquivo: {e}")
        traceback.print_exc()
        return None

def Use_data(data):
        # Verifica se a estrutura de dados é a esperada
        print(data['training_data'])
        trainnings =  data['training_data']
            #inputs = np.array([int(x) for x in item['inputs']], dtype=np.int32)



        return trainnings


def train_and_save_model(training_data, model_file):
    # Inicializando listas para armazenar todos os inputs e outputs combinados
    all_inputs = []
    all_outputs = []

    for training in training_data:
        # Aqui, espera-se que cada 'inputs_list' seja uma lista de listas
        inputs_list = training['inputs']
        outputs_list = training['output']

        # Convertendo e agregando
        for input_sample in inputs_list:
            all_inputs.append([int(x) for x in input_sample])
        for output_sample in outputs_list:
            all_outputs.append([float(x) for x in output_sample])

    # Convertendo para arrays NumPy
    inputs = np.array(all_inputs, dtype=np.int32)
    outputs = np.array(all_outputs, dtype=np.float32)

    # Supondo que 'inputs' é um array NumPy
    num_input_features = inputs.shape[1]  # Número de colunas em 'inputs'
    num_output_features = outputs.shape[1]  # Número de colunas em 'inputs'

    print("Número de recursos de entrada:", num_input_features)
    print("Número de recursos de saída:", num_output_features)

    # Construindo o modelo
    model = tf.keras.Sequential([tf.keras.layers.Dense(num_input_features, activation='relu'),  # Ajustando a camada de entrada
        tf.keras.layers.Dense(num_output_features, activation='sigmoid')  # Segunda camada com  neurônios
    ])

    # Compilando o modelo
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

    # Treinando o modelo com todos os dados combinados
    model.fit(inputs, outputs, epochs=10)

    # Salvando o modelo
    model.save(model_file)

if __name__ == "__main__":

    # Caminho absoluto do diretório onde o script Python está localizado
    diretorio_script = os.path.dirname(os.path.abspath(__file__))

    print("Programa de treinamento de rede neural");

    if len(sys.argv) == 3:
        #print("Usage: python script.py <input_json_file> <output_model_file>")
        print("Usage: python script.py <input_json_file> <output_model_file>")
        input_json_file = sys.argv[1]

        print("InputJSON:"+sys.argv[1])
        output_model_file = sys.argv[2]

        print("JSON Saida:"+sys.argv[2])
        #sys.exit(1)
    else:
        print("Usage default value input_json_file");
        input_json_file = diretorio_script+"/training_data.json"
        output_model_file = diretorio_script+"/output.json"
        print("Usage default value output_model_file")

    data_json = preprocess_json(input_json_file)
    if (data_json== None):
        print("Falha na carga do arquivo")
        sys.exit(1)



    trannning = Use_data(data_json)

    train_and_save_model(trannning, output_model_file)








