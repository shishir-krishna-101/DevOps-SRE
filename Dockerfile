FROM python:3.13-alpine

WORKDIR /app

COPY requirements.txt .

RUN python -m pip install --no-cache-dir --upgrade pip \
    && python -m pip install --no-cache-dir --upgrade -r requirements.txt \
    && python -m pip check \
    && python -m pip show msgpack setuptools urllib3

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY app/app.py .

USER appuser

EXPOSE 80

CMD ["python", "app.py"]
