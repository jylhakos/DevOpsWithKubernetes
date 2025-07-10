import pandas as pd 
import numpy as np
import pickle
from pathlib import Path
import os
# from sklearn.model_selection import train_test_split
# from keras.models import Sequential
# from keras.layers import Dense, Conv2D, MaxPooling2D, Dropout, Flatten, BatchNormalization
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import cv2
import uuid
from multiprocessing import Pool, cpu_count
from functools import partial
from sklearn.model_selection import train_test_split
from PIL import Image
from io import BytesIO
import requests
from tqdm import tqdm

def create_model():
    model = keras.Sequential([
        layers.Conv2D(64, (4, 4), input_shape=(128, 128, 3)),
        layers.MaxPooling2D((3, 3)),
        layers.Conv2D(64, (3, 3), activation="relu"),
        layers.MaxPooling2D((3, 3)),
        layers.Flatten(),
        layers.Dense(128, activation="relu"),
        layers.Dense(256),
        layers.BatchNormalization(),
        layers.Dense(128, activation="relu"),
        layers.Dense(1, activation="sigmoid"),
        ]
    )
     
    return model

def train(X, y):
    y = np.array(y["y"])
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.15)
    X_train = np.array([cv2.imread(uri) for uri in X_train["uri"]])
    X_test = np.array([cv2.imread(uri) for uri in X_test["uri"]])
    
    model = create_model()
    model.compile(optimizer="adam", loss="binary_crossentropy", metrics=["accuracy"])
    model.fit(x=X_train, y=y_train, batch_size=32, epochs=10, verbose=1)
    points = model.evaluate(X_test, y_test)
    model.save('./model/model')
    return

def url_to_img(url, save_as=''):
    content = requests.get(url, verify=False, timeout=5, allow_redirects=False, stream=True).content
    img = Image.open(BytesIO(content))
    if save_as:
        img.save(save_as)
    return save_as

def modify_images(path):
    img = cv2.imread(path)
    img = cv2.resize(img, (128, 128))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    return img

def get_images(prefix, url):
    imgs = []
    uri = ""
    # print(url)
    
    try:
        identifier = str(uuid.uuid4())
        image_name = prefix + identifier + ".jpg"
        local_path = url_to_img(url, save_as=f"imgs/raw/{image_name}")
        img = modify_images(local_path)
        uri = "imgs/processed/" + image_name
        cv2.imwrite(uri, img)

    except FileNotFoundError as e:
        print(e)
        return
    except Exception as e:
        return

    return uri

def start_train():
    merged = pd.concat([pd.read_csv("./imgs/cucumbers2.csv"), pd.read_csv("./imgs/mopeds2.csv")])
    merged = merged.dropna()

    X = merged.drop(["y"], axis=1)
    y = merged.drop(["uri"], axis=1)

    train(X, y)

def main():
    try:
        model = keras.models.load_model("./model/model")
        print(f"Model already exists at './model/model', exiting as there is nothing to do.")
        return
    except:
        try:
            cucumbers = pd.read_csv("./data/cucumber.csv")
            mopeds = pd.read_csv('./data/moped.csv')
        except:
            print("Cant find 'data' volume with csv:s for image download ")
            exit(1)
        
        if Path("./imgs/cucumbers2.csv").exists() and Path("./imgs/mopeds2.csv").exists() and Path("./imgs/processed").exists() and len(os.listdir("./imgs/processed")) > 50:
            print("at least some images exist, lets continue")
            start_train()
            exit(0)
        
        if not Path("imgs/raw").exists():
            os.makedirs("imgs/raw")
        if not Path("imgs/processed").exists():
            os.makedirs("imgs/processed")

        p = Pool(cpu_count())

        print("Gathering cucumbers...")
        func = partial(get_images, "cucumber_")
        cucumber_imgs = list(tqdm(p.imap(func, cucumbers["url"].sample(213)), desc="Gathering cucumbers...", unit="cucumbers", total=213))
        print("Gathering mopeds...")
        func = partial(get_images, "moped_")
        moped_imgs = list(tqdm(p.imap(func, mopeds["url"].sample(213)), desc="Gathering mopeds...", unit="mopeds", total=213))
        p.close()
        p.join()
        cucumbers = pd.DataFrame({"uri": cucumber_imgs, "y": 0})
        cucumbers.to_csv("./imgs/cucumbers2.csv")
        mopeds = pd.DataFrame({"uri": moped_imgs, "y": 1})
        mopeds.to_csv("./imgs/mopeds2.csv")

        start_train()
        exit(0)

if __name__ == "__main__":
   main()