# Mobile Chatbot

Object Oriented Programming Lab (CSE208L) project — UET Peshawar, Fall 2024.

A conversational chatbot that answers questions about mobile phone brands.
For known brand keywords it answers instantly from a lookup dictionary; for
anything else it falls back to a small TensorFlow/Keras (Bidirectional GRU)
text-classification model trained on the same brand descriptions, so unseen
phrasing still resolves to the closest matching brand.

## How it works
1. `mobile_data` — a dictionary of brand → description strings.
2. A Keras `Tokenizer` is fit on the descriptions, and a small
   `Embedding → Bidirectional(GRU) → Dense(softmax)` model is trained to
   classify free-text input against the known brands.
3. The main loop first checks for exact brand keyword matches (fast path),
   and otherwise calls `mobile_info_chatbot(query)`, which tokenizes the
   input and lets the trained model predict the closest brand.
4. Type `exit` to end the conversation.

## Run
```
pip install tensorflow
python mobile_chatbot.py
```

## Authors
Faizan, Naveed Ahmad, Sharjeel Qurashi — Section B.
