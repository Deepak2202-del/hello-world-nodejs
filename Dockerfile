FROM node:16
# Uses the official Node.js image version 16 as the base image. This image comes with Node.js and npm pre-installed.
WORKDIR /usr/src/app
#Sets the working directory inside the container to /usr/src/app. All subsequent commands will be run in this directory.
COPY package*.json ./
#Copies package.json and package-lock.json (if it exists) from your local machine to the working directory in the container. This step ensures that only these files are copied first, which helps in utilizing Docker's caching mechanism for npm install.
RUN npm install
# Runs npm install to install the dependencies listed in package.json. This step installs the necessary Node.js packages required for the application.
COPY . .
#Copies all files and directories from the current directory on your local machine to the working directory in the container (/usr/src/app). This includes the application code and other necessary files.

RUN npm run build

EXPOSE 3000

CMD [ "npm", "start" ]
#Specifies the command to run when the container starts. This runs npm start, which typically starts the Node.js application by running the start script defined in package.json.
