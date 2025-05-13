# Build Stage
FROM python:3.9 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy all your project files into the container
COPY . .

# Install dependencies (this assumes you have a requirements.txt)
RUN pip install --no-cache-dir -r requirements.txt

# Remove unnecessary files after installation (optional)
RUN rm -rf /root/.cache

# Production Stage (lighter base image)
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=build /app /app

# Expose the port that your application runs on (adjust as needed)
EXPOSE 5000

# Set the entry point or command to run your application (adjust as needed)
CMD ["python", "app.py"]
