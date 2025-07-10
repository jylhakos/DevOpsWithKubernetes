FROM python:3.9-slim

WORKDIR /src

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    libsm6 \
    libxext6 \
    libglib2.0-0 \
    libxrender1 \
    libxfixes3 \
    libxi6 \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY ./requirements.txt ./requirements.txt

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Create necessary directories
RUN mkdir -p /src/model /src/data /src/imgs

# Copy application code
COPY . .

# Set proper permissions
RUN chmod +x /src/train.py

# Run as non-root user for security
RUN groupadd -r mluser && useradd -r -g mluser mluser
RUN chown -R mluser:mluser /src
USER mluser

CMD ["python", "-u", "train.py"]
