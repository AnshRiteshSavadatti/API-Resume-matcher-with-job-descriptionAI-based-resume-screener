# -------------------------------
# Stage 1: Python Build Stage
# -------------------------------
FROM python:3.9 AS python-build

WORKDIR /app

# Upgrade pip and install Python dependencies
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir --prefer-binary -r requirements.txt

# Copy all source files
COPY . .

# -------------------------------
# Stage 2: Final App Image with Node and Python
# -------------------------------
FROM node:18-slim

WORKDIR /app

# Install system dependencies and allow pip override
RUN apt-get update && \
    apt-get install -y gcc && \
    python3 -m pip install --upgrade pip && \
    pip install --break-system-packages --no-cache-dir --prefer-binary -r requirements.txt && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Copy files from the Python build stage
COPY --from=python-build /app /app

# Install Node.js dependencies
RUN npm install --production

# Expose the port your app runs on
EXPOSE 5000

# Start your Node.js server
CMD ["node", "server.js"]
