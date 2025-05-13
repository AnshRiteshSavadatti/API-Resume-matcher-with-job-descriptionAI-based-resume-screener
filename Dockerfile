FROM python:3.10-slim

# Install system dependencies for Python and Node.js
RUN apt-get update && apt-get install -y python3-pip python3-dev libjpeg-dev nodejs npm

WORKDIR /app

# Copy package.json and install Node dependencies
COPY package*.json ./
RUN npm install

# Copy requirements.txt and install Python dependencies
COPY requirements.txt ./
RUN pip3 install -r requirements.txt

# Copy the rest of your application code
COPY . ./

EXPOSE 3000
ENV PORT=3000

CMD ["node", "server.js"]
