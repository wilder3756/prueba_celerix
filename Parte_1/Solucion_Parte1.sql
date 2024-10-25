CREATE TABLE empleados (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_contratacion DATE,
    salario DECIMAL(10, 2),
    id_departamento INT
);

INSERT INTO empleados VALUES
(1, 'Juan', 'Pérez', '2020-01-15', 30000.00, 1),
(2, 'María', 'González', '2019-05-20', 35000.00, 2),
(3, 'Carlos', 'Rodríguez', '2021-03-10', 28000.00, 1),
(4, 'Ana', 'Martínez', '2018-11-01', 40000.00, 3),
(5, 'Luis', 'Sánchez', '2022-07-05', 32000.00, 2);



CREATE TABLE departamentos (
    id_departamento INT PRIMARY KEY,
    nombre_departamento VARCHAR(50)
);

INSERT INTO departamentos VALUES
(1, 'Ventas'),
(2, 'Marketing'),
(3, 'Recursos Humanos'),
(4, 'Tecnología');


CREATE TABLE productos (
    id_producto INT PRIMARY KEY,
    nombre_producto VARCHAR(100),
    precio DECIMAL(10, 2),
    stock INT
);

INSERT INTO productos VALUES
(1, 'Laptop', 1200.00, 50),
(2, 'Smartphone', 800.00, 100),
(3, 'Tablet', 300.00, 75),
(4, 'Monitor', 250.00, 30),
(5, 'Teclado', 50.00, 200);


CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO clientes VALUES
(1, 'Pedro', 'Gómez', 'pedro@email.com'),
(2, 'Laura', 'Fernández', 'laura@email.com'),
(3, 'Miguel', 'Torres', 'miguel@email.com'),
(4, 'Sofia', 'Díaz', 'sofia@email.com');


-- Tabla pedidos (sin cambios en la estructura)
CREATE TABLE pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT,
    fecha_pedido DATE,
    total DECIMAL(10, 2)
);

-- Datos actualizados para la tabla pedidos
INSERT INTO pedidos VALUES
(1, 1, '2023-01-10', 2700.00),  -- 2 laptops + 1 tablet
(2, 2, '2023-02-15', 800.00),   -- 1 smartphone
(3, 3, '2023-03-20', 550.00),   -- 2 monitores + 1 teclado
(4, 4, '2023-04-05', 2100.00);  -- 1 laptop + 1 smartphone + 2 teclados

-- Tabla detalle_pedidos (sin cambios)
CREATE TABLE detalle_pedidos (
    id_detalle INT PRIMARY KEY,
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10, 2)
);

-- Datos para detalle_pedidos (sin cambios)
INSERT INTO detalle_pedidos (id_detalle, id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 2, 1200.00),  -- 2 laptops en el pedido 1
(2, 1, 3, 1, 300.00),   -- 1 tablet en el pedido 1
(3, 2, 2, 1, 800.00),   -- 1 smartphone en el pedido 2
(4, 3, 4, 2, 250.00),   -- 2 monitores en el pedido 3
(5, 3, 5, 1, 50.00),    -- 1 teclado en el pedido 3
(6, 4, 1, 1, 1200.00),  -- 1 laptop en el pedido 4
(7, 4, 2, 1, 800.00),   -- 1 smartphone en el pedido 4
(8, 4, 5, 2, 50.00);    -- 2 teclados en el pedido 4



--1.	Inserte un nuevo empleado en la tabla "empleados" con los siguientes datos: ID 6, nombre "Elena", apellido "López", fecha de contratación "2023-05-01", salario 33000.00, departamento 3
BEGIN;
INSERT INTO empleados (id_empleado, nombre, apellido, fecha_contratacion, salario, id_departamento) 
VALUES (6, 'Elena', 'López', '2023-05-01', 33000.00, 3);
COMMIT;


--2.	Actualice el salario del empleado con ID 2 a 37000.00.
BEGIN;
UPDATE empleados 
SET salario = 37000.00 
WHERE id_empleado = 2;
COMMIT;

--rollback;


--3.	Implemente un trigger que actualice automáticamente el stock de un producto cuando se realiza un nuevo pedido.
--Funcion que implementada para generar el trigger
CREATE OR REPLACE FUNCTION verificar_y_actualizar_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar stock
    IF (SELECT stock FROM productos WHERE id_producto = NEW.id_producto) < NEW.cantidad THEN
        -- Si no hay suficiente stock, lanzar una excepción
        RAISE EXCEPTION 'Stock insuficiente para el producto con ID %', NEW.id_producto; -- Con la Exception postgres hara automaticamente el Rollback
    ELSE
        -- Si hay suficiente stock, actualizarlo restando la cantidad
        UPDATE productos
        SET stock = stock - NEW.cantidad
        WHERE id_producto = NEW.id_producto;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- TRIGGER
CREATE TRIGGER trigger_verificar_stock
BEFORE INSERT ON detalle_pedidos
FOR EACH ROW
EXECUTE FUNCTION verificar_y_actualizar_stock();

--Ejmplo Uso Positivo
INSERT INTO detalle_pedidos (id_detalle, id_pedido, id_producto, cantidad, precio_unitario) 
VALUES (9, 4, 1, 1, 1200.00);  -- Se compra Una Laptop

--Ejemplo Uso Negativo, 
INSERT INTO detalle_pedidos (id_detalle, id_pedido, id_producto, cantidad, precio_unitario) 
VALUES (9, 4, 1, 100, 1200.00); --Se intentan Comprar 100 Laptops y el stock actual es de 49

--select * from detalle_pedidos;
--select * from productos;


--4.	Haz una consulta que muestre el nombre del producto, stock, la cantidad de veces que ha sido pedido, la cantidad de veces que ha sido vendido, la fecha del último pedido para cada producto y el total de ingresos generados por ese producto. agrega un filtro que me muestre solo lso productos que han tenido mas de un pedido
SELECT p.nombre_producto, p.stock, 
       COUNT(dp.id_detalle) AS veces_pedido,
       SUM(dp.cantidad) AS cantidad_vendida, 
       MAX(pe.fecha_pedido) AS fecha_ultimo_pedido, 
       SUM(dp.cantidad * dp.precio_unitario) AS ingresos_totales
FROM productos p
JOIN detalle_pedidos dp ON p.id_producto = dp.id_producto
JOIN pedidos pe ON dp.id_pedido = pe.id_pedido
GROUP BY p.id_producto
HAVING COUNT(dp.id_detalle) > 1;

--5.	Diseñe los índices apropiados para mejorar el rendimiento de consultas frecuentes en la tabla "pedidos".
CREATE INDEX idx_pedidos_id_cliente ON pedidos (id_cliente);
CREATE INDEX idx_pedidos_fecha_pedido ON pedidos (fecha_pedido);
CREATE INDEX idx_pedidos_cliente_fecha ON pedidos (id_cliente, fecha_pedido);

--6.	Escriba una consulta que utilice una ventana deslizante (window function) para calcular el salario acumulado por departamento.
SELECT id_departamento, 
       nombre, 
       salario, 
       SUM(salario) OVER (PARTITION BY id_departamento ORDER BY fecha_contratacion ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS salario_acumulado
FROM empleados
ORDER BY id_departamento, fecha_contratacion;


