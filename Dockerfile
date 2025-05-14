# -------------------------------
# Build Stage
# -------------------------------
FROM python:3.9 AS build

# Set working directory
WORKDIR /app

# Upgrade pip and install Python dependencies
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir --prefer-binary -r requirements.txt

# Copy all project files
COPY . .

# -------------------------------
# Production Stage
# -------------------------------
FROM node:18-slim AS final  # ✅ Use Node base (since you're starting with server.js)

WORKDIR /app

# Copy from Python build stage
COPY --from=build /app /app

# Install system dependencies for Python and Node
RUN apt-get update && \
    apt-get install -y python3 python3-pip gcc && \
    python3 -m pip install --upgrade pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Reinstall Python packages (optional, for leaner builds you can use venv or skip this if copied)
COPY requirements.txt .
RUN pip3 install --no-cache-dir --prefer-binary -r requirements.txt

# Install Node.js dependencies
COPY package*.json ./
RUN npm install --production

# Copy the rest of the app code again (if not already done in COPY above)
COPY . .

# Expose the app port
EXPOSE 5000

# Start Node.js app
CMD ["node", "server.js"]
