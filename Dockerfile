# Use a base image with both Node.js and Python
FROM node:18-bullseye

# Install Python
RUN apt-get update && apt-get install -y python3 python3-pip

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Install Python dependencies
RUN pip3 install -r requirements.txt

# Install Node dependencies
RUN npm install

# Expose the port Railway expects
ENV PORT=5000
EXPOSE 5000

# Start the app
CMD ["npm", "start"]
