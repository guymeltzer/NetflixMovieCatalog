# Use an official base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy project files
COPY . .

# Copy the .aws folder into the container (assuming the local machine has .aws folder)
COPY ~/.aws /root/.aws

# Set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_DEFAULT_REGION
RUN export AWS_ACCESS_KEY_ID=$(cat /root/.aws/credentials | grep aws_access_key_id | awk '{print $3}') && \
    export AWS_SECRET_ACCESS_KEY=$(cat /root/.aws/credentials | grep aws_secret_access_key | awk '{print $3}') && \
    export AWS_DEFAULT_REGION=$(cat /root/.aws/config | grep region | awk '{print $3}') && \
    echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" && \
    echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" && \
    echo "AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" && \
    # Add the variables to .profile (for sh) so they're available in shell sessions
    echo "export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> /root/.profile && \
    echo "export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> /root/.profile && \
    echo "export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION" >> /root/.profile

# Install dependencies
RUN apt-get update && apt-get install -y python3-pip python3-venv \
    && python3 -m venv venv \
    && ./venv/bin/pip install --no-cache-dir -r requirements.txt

# Expose the application port
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
