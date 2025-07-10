# Model training for machine learning

The system will automatically train your CNN model first, then deploy the backend API to serve predictions, and finally the frontend for user interaction are managed by Kubernetes on Amazon EKS.

To deploy this to EKS

- Update the ECR repository URLs in the Kubernetes manifests

- Create EFS file system and update the file system ID

- Run the deployment bash script

```
    ./aws-setup/deploy.sh

```
The Python script downloads images to the `./imgs` folder and generates CSV files containing the image URIs in the `./data` folder. It then creates a model in the `./model` folder before exiting with a success code of 0.

The convolutional neural network (CNN) model is constructed using a machine-learning algorithm from the Keras and TensorFlow libraries, leveraging training data.
