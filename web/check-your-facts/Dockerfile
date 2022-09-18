#imports a python image (3.9-slim); we will be running a simple Python web app, so this is all we need
#for challenges that require an OS, consider using an 'Alpine' image from the Docker registry
FROM python:3.9-slim

#copying the Python requirements file to the /app directory within the build context directory
COPY ./requirements.txt /app/requirements.txt

#sets the working directory for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions
WORKDIR /app

#installing the Python requirements within the working directory
RUN pip3 install -r requirements.txt

#copies app folder from build context to the working directory
COPY ./app /app/

#running Gunicorn (the WGSI) as a command when the container starts
#with -b we bind the application to localhost on port 5000
#with -w we specify the number of 'worker processes'
#'app:app' follows the pattern 'module_name:variable_name', a module being a .py file & the variable name being the WSGI callable within the module 
CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:5000", "app:app"]
    
