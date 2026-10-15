FROM python:3.13-slim
WORKDIR /app
RUN useradd --system appuser
COPY app/app.py .
USER appuser
EXPOSE 80
CMD ["python", "app.py"]