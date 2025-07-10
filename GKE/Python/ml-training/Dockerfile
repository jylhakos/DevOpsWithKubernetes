FROM python:3.9-slim

WORKDIR /src

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libgl1-mesa-glx \
    wget \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY ./requirements.txt ./requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p /src/model /src/data /src/imgs

# Set environment variables for GCP
ENV GOOGLE_APPLICATION_CREDENTIALS=/src/gcp-key.json
ENV PYTHONUNBUFFERED=1

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python -c "import tensorflow; print('Training container healthy')" || exit 1

# Run training script
CMD ["python", "-u", "train.py"]
