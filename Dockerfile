
FROM python:3.8.0-slim

WORKDIR /app

COPY . /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

ENV DATABASE='emp_db.db'
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

CMD flask db upgrade

CMD flask run

