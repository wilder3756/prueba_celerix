import os
import pandas as pd
import psycopg2
from psycopg2 import sql
from dotenv import load_dotenv
from transformations import apply_transformations

# Cargar variables de entorno desde el archivo .env
load_dotenv()

# Variables de entorno para seguridad
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")

class ETLProcess:

    def __init__(self, file_path):
        self.file_path = file_path
        self.df = None

    def extract(self):
        """Extrae los datos del archivo CSV."""
        self.df = pd.read_csv(self.file_path)
        print("Datos extraídos con éxito.")

    def transform(self):
        """Aplica las transformaciones en los datos."""
        self.df = apply_transformations(self.df)
        print("Transformaciones aplicadas con éxito.")

    def load(self):
        """Carga los datos transformados en PostgreSQL."""
        try:
            # Conectar a la base de datos PostgreSQL
            conn = psycopg2.connect(
                dbname=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD,
                host=DB_HOST,
                port=DB_PORT
            )
            cur = conn.cursor()

            # Crear la tabla si no existe
            cur.execute("""
                CREATE TABLE IF NOT EXISTS imports_exports (
                    Transaction_ID VARCHAR(255) PRIMARY KEY,
                    Country VARCHAR(255),
                    Product VARCHAR(255),
                    Import_Export VARCHAR(10),
                    Shipping_Method VARCHAR(50),
                    Port VARCHAR(100),
                    Category VARCHAR(100),
                    Quantity INT,
                    Value DECIMAL(10, 2),
                    Date DATE,
                    Customs_Code VARCHAR(20),
                    Weight DECIMAL(10, 2),
                    value_per_kg DECIMAL(10, 2)
                );
            """)
            conn.commit()

            # Insertar los datos
            for _, row in self.df.iterrows():
                cur.execute("""
                    INSERT INTO imports_exports (Transaction_ID, Country, Product, Import_Export, Shipping_Method, Port, Category, Quantity, Value, Date, Customs_Code, Weight, value_per_kg)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON CONFLICT (Transaction_ID) DO NOTHING;
                """, tuple(row))

            conn.commit()
            cur.close()
            conn.close()
            print("Datos cargados en la base de datos PostgreSQL con éxito.")
        except Exception as e:
            print(f"Error al cargar los datos: {e}")

# Ejecutar el proceso ETL
if __name__ == "__main__":
    etl = ETLProcess('data/sample_data.csv')
    etl.extract()
    etl.transform()
    etl.load()
