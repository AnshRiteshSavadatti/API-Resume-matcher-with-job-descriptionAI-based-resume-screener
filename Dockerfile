# Build Stage
FROM python:3.9 AS build

# Set the working directory inside the container
WORKDIR /app

# Upgrade pip to the latest version
RUN python -m pip install --upgrade pip

# Copy only the requirements file first for better caching
COPY requirements.txt .

# Install dependencies with improved resolver behavior and speed
RUN pip install --no-cache-dir --prefer-binary -r requirements.txt

# Now copy the rest of the project files
COPY . .

# Production Stage
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Install required system dependencies and upgrade pip
RUN apt-get update && \
    apt-get install -y gcc && \
    python -m pip install --upgrade pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy from build stage
COPY --from=build /app /app

# Expose port (adjust if your app uses a different one)
EXPOSE 5000

# Start the application
CMD ["python", "app.py"]
