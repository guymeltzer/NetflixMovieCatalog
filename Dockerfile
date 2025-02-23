# Use an official base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy project files (excluding .aws)
COPY . .

# Install dependencies
RUN apt-get update && apt-get install -y python3-pip && \
    pip install --no-cache-dir -r requirements.txt

# Set AWS credentials as environment variables at runtime (not in Dockerfile)
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
