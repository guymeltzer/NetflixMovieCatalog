# Use an official base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy project files
COPY . .

# Copy .aws credentials and config files to the container
COPY /home/guy/.aws /root/.aws

# Extract AWS credentials and region from the .aws files and set them as environment variables
RUN export AWS_ACCESS_KEY_ID=$(cat /root/.aws/credentials | grep aws_access_key_id | awk '{print $3}') && \
    export AWS_SECRET_ACCESS_KEY=$(cat /root/.aws/credentials | grep aws_secret_access_key | awk '{print $3}') && \
    export AWS_DEFAULT_REGION=$(cat /root/.aws/config | grep region | awk '{print $3}') && \
    echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" && \
    echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" && \
    echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" && \
    # Add the variables to /root/.profile for persistence
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> /root/.profile && \
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> /root/.profile && \
    echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /root/.profile

# Set the environment variables in the container
ENV AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
ENV AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
ENV AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION

# Install dependencies
RUN apt-get update && apt-get install -y python3-pip python3-venv \
    && python3 -m venv /app/venv \
    && /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
