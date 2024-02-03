import tensorflow as tf
import numpy as np
import json
import sys

def load_data(json_file):
    with open(json_file, 'r') as file:
        data = json.load(file)
    inputs = np.array([item['inputs'] for item in data['training_data']], dtype=np.float32)
    outputs = np.array([item['output'] for item in data['training_data']], dtype=np.float32)
    return inputs, outputs

def train_and_save_model(inputs, outputs, model_file):
    model = tf.keras.Sequential([
        tf.keras.layers.Dense(100, activation='relu'),
        tf.keras.layers.Dense(1, activation='sigmoid')
    ])

    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
    model.fit(inputs, outputs, epochs=10)

    model.save(model_file)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <input_json_file> <output_model_file>")
        sys.exit(1)

    input_json_file = sys.argv[1]
    output_model_file = sys.argv[2]

    inputs, outputs = load_data(input_json_file)
    train_and_save_model(inputs, outputs, output_model_file)


