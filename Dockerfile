# Use an official base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy project files
COPY . .

# Install dependencies and create a virtual environment
RUN apt-get update && apt-get install -y python3-pip python3-venv \
    && python3 -m venv /app/venv \
    && /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Set the environment variable to use the virtual environment
ENV PATH="/app/venv/bin:$PATH"

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
