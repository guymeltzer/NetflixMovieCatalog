# Use an official base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy project files
COPY . .
RUN ls -l /app/data_loader.py

ENV PYTHONPATH="${PYTHONPATH}:/app"
ENV AWS_DEFAULT_REGION=eu-north-1

# Install dependencies
RUN apt-get update && apt-get install -y python3-pip python3-venv \
    && python3 -m venv venv \
    && ./venv/bin/pip install --no-cache-dir -r requirements.txt

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
