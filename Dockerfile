# Use an official Python runtime as the base image
FROM python:3.8-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Define environment variable
# This is required for Python Kubernetes client to find the cluster configuration
ENV KUBERNETES_SERVICE_HOST=kubernetes.default.svc

# Run the Python script when the container launches
CMD ["python", "pod_cleaner.py"]