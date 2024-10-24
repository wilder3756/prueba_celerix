import pandas as pd

def apply_transformations(df):
    """Aplica las transformaciones al DataFrame."""
    
    # 1. Convertir el formato de fecha a YYYY-MM-DD
    df['Date'] = pd.to_datetime(df['Date'], format='%d-%m-%Y')


    # 2. Convertir tipos de datos
    df['Customs_Code'] = pd.to_numeric(df['Customs_Code'], errors='coerce')
    df['Quantity'] = pd.to_numeric(df['Quantity'], errors='coerce')
    df['Value'] = pd.to_numeric(df['Value'], errors='coerce')
    df['Weight'] = pd.to_numeric(df['Weight'], errors='coerce')

    # 4. Estandarizacion basica a la columna 'Country' (eliminar espacios en blanco)
    df['Country'] = df['Country'].str.strip()

    # 5. Columna calculada: valor por kilogramo
    df['value_per_kg'] = df['Value'] / df['Weight']

    return df
