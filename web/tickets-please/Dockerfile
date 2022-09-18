FROM python:3.9-slim

COPY ./requirements.txt /app/requirements.txt

WORKDIR /app

RUN pip3 install -r requirements.txt

COPY ./app /app/

EXPOSE 5000

CMD ["gunicorn", "app:app", "-w", "2", "-b", "0.0.0.0:5000"]


