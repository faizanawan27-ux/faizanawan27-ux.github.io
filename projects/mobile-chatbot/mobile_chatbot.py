import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Embedding, Bidirectional, GRU, Dense
from tensorflow.keras.preprocessing.sequence import pad_sequences

# Sample data for mobile phone information
mobile_data = {
    "iphone": "The iPhone is a line of smartphones designed and marketed by Apple Inc.",
    "samsung": "Samsung Galaxy is a series of mobile computing devices designed, manufactured and marketed by Samsung Electronics.",
    "pixel": "Google Pixel is a line of consumer electronic devices developed by Google.",
    "oneplus": "OnePlus is a Chinese smartphone manufacturer that focuses on providing flagship-level smartphones at affordable prices.",
    "huawei": "Huawei is a global provider of information and communications technology (ICT) infrastructure and smart devices.",
    "xiaomi": "Xiaomi is a Chinese electronics company known for its smartphones, smart home devices, and other consumer electronics.",
    "motorola": "Motorola is an American telecommunications and consumer electronics company known for its smartphones and mobile devices.",
    "lg": "LG Corporation is a South Korean multinational conglomerate known for its electronic products, including smartphones.",
    "sony": "Sony Corporation is a Japanese multinational conglomerate known for its entertainment and electronics products.",
    "nokia": "Nokia is a Finnish multinational telecommunications, information technology, and consumer electronics company.",
}

# Convert data to lowercase for case-insensitivity
mobile_data = {key.lower(): value for key, value in mobile_data.items()}

# Tokenize the text data
tokenizer = tf.keras.preprocessing.text.Tokenizer()
tokenizer.fit_on_texts(mobile_data.values())

# Define the model with BiGRU
model = Sequential()
model.add(Embedding(input_dim=len(tokenizer.word_index) + 1, output_dim=16, input_length=1))
model.add(Bidirectional(GRU(32)))
model.add(Dense(len(mobile_data), activation='softmax'))

# Compile the model
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Training data
inputs = []
outputs = []
for key, value in mobile_data.items():
    tokenized_sequence = tokenizer.texts_to_sequences([value])[0]
    inputs.append(tokenized_sequence)
    outputs.append(tf.keras.utils.to_categorical(list(mobile_data.keys()).index(key),
                                                   num_classes=len(mobile_data)))

# Pad sequences to have the same length
inputs_padded = pad_sequences(inputs, maxlen=50)  # You can adjust maxlen based on your data

inputs_tensor = tf.convert_to_tensor(inputs_padded)
outputs_tensor = tf.convert_to_tensor(outputs)

# Train the model
model.fit(inputs_tensor, outputs_tensor, epochs=50)


# Chatbot function
def mobile_info_chatbot(query):
    tokenized_query = tokenizer.texts_to_sequences([query])
    padded_query = pad_sequences(tokenized_query, maxlen=50)  # You can adjust maxlen based on your data
    prediction = model.predict(tf.convert_to_tensor(padded_query))
    predicted_index = tf.argmax(prediction, axis=-1).numpy()[0]

    mobile_keys = list(mobile_data.keys())
    predicted_mobile = mobile_keys[predicted_index]

    return mobile_data[predicted_mobile]


# Example usage
while True:
    user_input = input("You: ")
    if user_input.lower() == 'exit':
        break
    elif user_input.lower() == 'iphone':
        response = mobile_data['iphone']
    elif user_input.lower() == 'samsung':
        response = mobile_data['samsung']
    elif user_input.lower() == 'pixel':
        response = mobile_data['pixel']
    elif user_input.lower() == 'oneplus':
        response = mobile_data['oneplus']
    elif user_input.lower() == 'huawei':
        response = mobile_data['huawei']
    elif user_input.lower() == 'xiaomi':
        response = mobile_data['xiaomi']
    elif user_input.lower() == 'motorola':
        response = mobile_data['motorola']
    elif user_input.lower() == 'lg':
        response = mobile_data['lg']
    elif user_input.lower() == 'sony':
        response = mobile_data['sony']
    elif user_input.lower() == 'nokia':
        response = mobile_data['nokia']
    else:
        response = mobile_info_chatbot(user_input)
    print("Chatbot:", response)
