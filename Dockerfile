# Build Stage
FROM python:3.9 AS build

# Set the working directory inside the container
WORKDIR /app

# Upgrade pip to the latest version
RUN python -m pip install --upgrade pip

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install dependencies (this assumes you have a valid requirements.txt)
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . .

# Production Stage
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Upgrade pip in the production stage as well
RUN apt-get update && apt-get install -y gcc && \
    python -m pip install --upgrade pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy everything from the build stage
COPY --from=build /app /app

# Expose the port your app uses
EXPOSE 5000

# Run the app
CMD ["python", "app.py"]
