FROM node:18-bullseye

# Install Python and pip and any system dependencies needed for Python packages
RUN apt-get update && apt-get install -y python3 python3-pip libjpeg-dev

WORKDIR /app

# Copy package.json and install Node dependencies
COPY package*.json ./
RUN npm install

# Copy requirements.txt and install Python dependencies
COPY requirements.txt ./
RUN pip3 install -r requirements.txt

# Copy the rest of your application code
COPY . ./

# Expose the port and set the environment variable for PORT
EXPOSE 3000
ENV PORT=3000

# Command to run the app
CMD ["node", "server.js"]
