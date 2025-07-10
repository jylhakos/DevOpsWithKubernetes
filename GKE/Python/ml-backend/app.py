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
  
  # Production configuration
  debug = os.getenv('FLASK_ENV') == 'development'
  host = os.getenv('FLASK_HOST', '0.0.0.0')
  port = int(os.getenv('FLASK_PORT', 5000))
  
  global model
  boolean_print = False
  model_loaded = False
  
  # Wait for model to be available
  while not model_loaded:
    try:
      model_path = os.getenv('MODEL_PATH', './model/model')
      model = keras.models.load_model(model_path)
      model_loaded = True
      print("Model loaded successfully")
      break
    except Exception as e:
      if not boolean_print:
        print(f"No model found at {model_path}. Waiting for training service to provide one.")
        print(f"Error: {str(e)}")
        boolean_print = True
      time.sleep(5)
      continue

  print(f"Starting Flask server on {host}:{port}")
  app.run(host=host, port=port, debug=debug, threaded=True)