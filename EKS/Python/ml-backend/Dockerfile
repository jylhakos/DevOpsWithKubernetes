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
RUN mkdir -p /src/model

# Copy application code
COPY . .

# Set proper permissions
RUN chmod +x /src/app.py

# Run as non-root user for security
RUN groupadd -r mluser && useradd -r -g mluser mluser
RUN chown -R mluser:mluser /src
USER mluser

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ping || exit 1

CMD ["python", "-u", "app.py"]
