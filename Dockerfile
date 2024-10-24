# Imagen base oficial de Python
FROM python:3.9-slim

# Directorio de trabajo
WORKDIR /app

# Dependencias
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copiar los archivos necesarios
COPY etl/ ./etl/
COPY data/sample_data.csv ./data/sample_data.csv
COPY .env .env

# Establece la variable de entorno para importar módulos del directorio etl
ENV PYTHONPATH=/app/etl

# Comando para ejecutar el script ETL
CMD ["python", "etl/etl_script.py"]
