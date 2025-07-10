from flask import Flask, jsonify, request
from dotenv import load_dotenv
import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import cv2
from flask_cors import CORS, cross_origin
from io import BytesIO
import time

app = Flask(__name__)
CORS(app)

@app.route('/ping')
def ping():
  print('someone is pinging')
  return 'pong'

@app.route('/kurkkuvaimopo', methods=["POST"])
def test():
  try:
    data = request.files.get('img').read()
    npimg = np.fromstring(data, np.uint8)
    img = cv2.imdecode(npimg, cv2.IMREAD_UNCHANGED)
    img = cv2.resize(img, (128,128))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    res = model(np.array(img).reshape(1, 128, 128, 3), training=False)
  except Exception as e:
    print(str(e))
    return str(e), 500

  return str(res[0][0].numpy())


if __name__ == '__main__':
  print("Backend starting")
  load_dotenv()
  if not os.path.isdir("./model"):
    print("NO MODEL VOLUME")
    exit(1)
  debug = os.getenv('ENV') == 'development'
  global model
  boolean_print = False
  while True:
    try:
      model = keras.models.load_model("./model/model")
      break
    except:
      if not boolean_print:
        print("No model in the model volume. Waiting for training service to provide one.")
        boolean_print = True
      time.sleep(5)
      continue

  app.run("0.0.0.0", port=5000, debug=debug)