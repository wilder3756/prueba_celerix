# ETL con Python y PostgreSQL utilizando Docker Compose

Este proyecto implementa un proceso ETL para cargar datos desde un archivo CSV a una base de datos PostgreSQL utilizando Docker Compose.

## Requisitos

- Docker
- Docker Compose

## Instrucciones rápidas

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/wilder3756/prueba_celerix.git
   cd prueba_celerix

## Paso 2: Configurar y Ejecutar Docker

Verifica la instalación de Docker ejecutando los siguientes comandos:

```bash
docker --version
docker-compose --version

Construye y levanta los contenedores definidos en el archivo docker-compose.yml

```bash
docker-compose up --build