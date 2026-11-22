# Práctica 04: Procesos de Simulación de Compra

Este repositorio contiene los scripts SQL y vistas de auditoría desarrollados en **MariaDB / MySQL (`db_test_7b`)** para simular el ciclo de vida completo de compra dentro de una plataforma de comercio electrónico. La implementación valida la integridad referencial entre las 24 tablas del esquema, el control de inventario, la gestión de pagos y devoluciones, así como la transición dinámica de privilegios mediante Control de Acceso Basado en Roles (**RBAC**: `user_not_registered` $\rightarrow$ `common` $\rightarrow$ `buyer`) desde la conexión `AppWeb@localhost`.

---

## Arquitectura de Trazabilidad y Vistas

Para auditar cada operación ejecutada durante las simulaciones, se implementaron **5 vistas individuales** (`vw_practica04_caso_1` a `vw_practica04_caso_5`) y **1 vista maestra consolidada** (`vw_practica04_resumen_general`). Todas comparten un esquema estandarizado de 10 columnas:

| Columna | Descripción |
| :--- | :--- |
| `caso` | Identificador y nombre del escenario de prueba ejecutado. |
| `fase` | Etapa cronológica del proceso dentro del caso de prueba. |
| `rol` | Rol RBAC activo al momento de ejecutar la operación (`user_not_registered`, `common`, `buyer`). |
| `usuario_ejecutor` | Usuario de aplicación que ejecuta la transacción (`AppWeb`). |
| `conexion_bd` | Cadena de conexión a la base de datos (`AppWeb@localhost`). |
| `fecha_evento` | Marca de tiempo (`DATETIME`) en que se registró el evento. |
| `cantidad` | Unidades de producto o eventos involucrados en la operación. |
| `operacion_tabla` | Sentencias SQL ejecutadas y tablas afectadas. |
| `detalle_evento` | Metadatos relacionales (IDs de usuario, carrito, orden, producto, pago, guía y montos). |
| `resultado` | Estado final obtenido tras completar el paso correspondiente. |

---

## Escenarios de Prueba Implementados

### Caso de Prueba 1: "Compra Exitosa, sin modificaciones"
*Vista asociada: `vw_practica04_caso_1`*

1. Un usuario nuevo se registra en la plataforma (`rol: user_not_registered`, usuario de conexión a la BD: `AppWeb` o `AppMobile`) con sus datos personales y de cuenta de usuario.
2. El usuario creado realiza la selección de 5 productos disponibles (de aproximadamente 10,000 productos disponibles, verificando su estatus activo).
3. El usuario crea 1 carrito de compra.
4. El usuario agrega los 5 productos con diferentes cantidades al carrito.
5. El usuario realiza la orden de compra.
6. El usuario registra su domicilio para envío.
7. El usuario registra su método de pago con tarjeta de débito mediante una cuenta simulada de 16 dígitos (vinculada a su tabla dependiente).
8. El usuario registra un pago único (al pagar, el usuario de conexión activa el rol `buyer`).
9. El sistema registra la transacción bancaria y la autoriza (`Approved`).
10. El sistema procesa la orden marcándola como atendida y descuenta el inventario.
11. El usuario recibe el producto en casa (`Delivered`).

---

### Caso de Prueba 2: "Compra con detalles en el último pago y con reclamación y reenvío"
*Vista asociada: `vw_practica04_caso_2`*

1. Un usuario ya registrado (de los 10k disponibles) crea 1 carrito de compra de 10 productos aleatorios con cantidades entre 1 y 5 unidades.
2. El usuario realiza la orden de compra.
3. El usuario registra su domicilio para envío a un lugar distinto a su hogar (dirección de trabajo/oficina).
4. El usuario registra su método de pago con tarjeta de crédito mediante una cuenta simulada de 16 dígitos (vinculada a su tabla dependiente).
5. El usuario registra 6 pagos mensuales a MSI (activando el rol `buyer` al pagar).
6. El sistema registra las transacciones bancarias: autoriza las primeras 5 (`Approved`) y rechaza la última (`Declined`) por *"Límite excedido de crédito"*.
7. El sistema procesa la orden marcándola como atendida.
8. El usuario recibe el pedido en el domicilio laboral.
9. El usuario reclama la devolución de 1 producto que llegó dañado.
10. El sistema realiza el reenvío de reposición del producto en buenas condiciones mediante una nueva guía de rastreo.

---

### Caso de Prueba 3: "Compra exitosa con cancelación parcial, ajuste y reembolso parcial"
*Vista asociada: `vw_practica04_caso_3`*

1. Un usuario ya registrado (de los 10k disponibles) crea 1 carrito de compra de 3 productos de la misma categoría con cantidades entre 1 y 10 unidades.
2. El usuario realiza la orden de compra.
3. El usuario registra un domicilio para envío distinto a su hogar (etiquetado como `"Casa Papas"`).
4. El usuario registra su método de pago con tarjeta digital (**Spin**) mediante una cuenta simulada de 16 dígitos (vinculada a su tabla dependiente).
5. El usuario registra un solo pago en efectivo por el costo total de la compra.
6. El sistema procesa la orden marcándola como atendida.
7. El usuario cancela 1 producto del pedido.
8. El sistema realiza la actualización de la orden de compra (recalculando el subtotal y reintegrando el stock del artículo cancelado).
9. El sistema realiza el reembolso (`Reversed`) por el monto exacto del producto cancelado.
10. El sistema realiza el envío de las partidas vigentes.
11. El cliente recibe el pedido ajustado en `"Casa Papas"`.

---

### Caso de Prueba 4: "Compra exitosa del mismo proveedor con entrega en el punto de recolección"
*Vista asociada: `vw_practica04_caso_4`*

1. Un usuario ya registrado (de los 10k disponibles) crea 1 carrito de compra de 3 productos del mismo proveedor con cantidades de 1 a 3 unidades.
2. El usuario realiza la orden de compra.
3. El usuario registra un domicilio para envío en su `"Hogar"`.
4. El usuario registra su método de pago mediante transferencia **SPEI** con una cuenta simulada de 16 dígitos (vinculada a su tabla dependiente).
5. El usuario registra un solo pago en efectivo por el costo total de la compra.
6. El sistema procesa la orden marcándola como atendida.
7. El sistema realiza el envío al domicilio registrado, registrando un intento fallido por ausencia del destinatario.
8. El cliente recoge el pedido personalmente en el punto de recolección (sucursal) al no haber habido quien lo recibiera en casa.

---

### Caso de Prueba 5: "Compra fallida por falta de inventario"
*Vista asociada: `vw_practica04_caso_5`*

1. Un usuario ya registrado (de los 10k disponibles) crea 1 carrito de compra de 1 producto de un mismo proveedor con cantidades de 1 a 5 unidades.
2. El usuario realiza la orden de compra.
3. El usuario registra su domicilio para envío en su `"Hogar"`.
4. El usuario registra su método de pago con **Cupón de Regalo**.
5. El sistema valida el stock disponible y procesa la orden marcándola como no atendida por falta de inventario.
6. El sistema cancela la orden (`Canceled`), revierte la transacción (`Reversed`) y reasigna/reactiva el cupón utilizado en la cuenta del usuario.

---

## Consultas de Verificación

```sql
-- Trazabilidad individual por escenario
SELECT * FROM vw_practica04_caso_1;
SELECT * FROM vw_practica04_caso_2;
SELECT * FROM vw_practica04_caso_3;
SELECT * FROM vw_practica04_caso_4;
SELECT * FROM vw_practica04_caso_5;

-- Auditoría consolidada de toda la práctica
SELECT * FROM vw_practica04_resumen_general;
