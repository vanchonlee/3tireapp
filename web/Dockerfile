# Use the official Node.js image as the base image
FROM node:18

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to leverage Docker caching
COPY package*.json ./

# Install Node.js dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Define the command to run the application
CMD ["node", "-r", "dd-trace/init", "./bin/www"]
