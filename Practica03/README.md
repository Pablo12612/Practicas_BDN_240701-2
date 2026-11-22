# Práctica 03: Manipulación de Datos, Relaciones, Procedimientos, Funciones y Eventos en Conexiones Remotas

Este repositorio documenta el desarrollo e implementación de la **Práctica 03** de *Bases de Datos en la Nube*, orientada a la administración, automatización y operación remota de una base de datos relacional de **E-Commerce** desplegada en un servidor privado virtual (**VPS**)[cite: 9].

A partir del esquema relacional construido previamente, se integraron **25 tablas**, se implementaron mecanismos completos de auditoría y trazabilidad, se configuró la seguridad mediante control de acceso basado en roles (**RBAC**) para conexiones remotas y se ejecutaron simulaciones masivas de usuarios y productos mediante rutinas SQL parametrizables[cite: 9].

---

## Arquitectura e Implementación Técnica

### 1. Estructura de la Base de Datos (25 Tablas)
* Integración y validación de **25 tablas** (`24` operativas + `1` tabla de bitácora `tb_logs`)[cite: 9].
* Verificación de llaves primarias, llaves foráneas, tipos de datos e integridad referencial entre usuarios, personas, productos, categorías, proveedores, carritos, órdenes, pagos, transacciones y envíos, habilitadas para consulta y manipulación remota en el VPS[cite: 9].

### 2. Auditoría Automática (72 Triggers)
* Implementación de **72 triggers** distribuidos en las 24 tablas operativas (excluyendo `tb_logs`), cubriendo los tres eventos DML: `AFTER INSERT`, `AFTER UPDATE` y `AFTER DELETE`[cite: 9].
* Registro centralizado en `tb_logs` con identificación de la tabla afectada, tipo de operación, usuario de conexión remota, fecha/hora y descripción detallada del cambio[cite: 10].

### 3. Vistas SQL de Trazabilidad y Catálogo (25 Vistas)
* **24 vistas de trazabilidad**, una por cada tabla operativa, vinculando los registros transaccionales con la bitácora (`tb_logs`) para auditar qué cuenta remota ejecutó cada movimiento[cite: 10].
* **1 vista de Productos por Categoría** (`25` vistas en total) que clasifica los artículos por categorías y subcategorías junto con sus estados de disponibilidad[cite: 10].

### 4. Seguridad, Usuarios Remotos y RBAC (7 Roles)
* Creación y configuración de cuentas de acceso remoto en MySQL con asignación de roles predeterminados[cite: 10].
* Definición granular de privilegios sobre las 24 tablas operativas para los **7 roles del sistema**:
  * `superadmin`
  * `admin`
  * `support`
  * `seller`
  * `buyer`
  * `common_user`
  * `user_not_registered`[cite: 10]

### 5. Rutinas Almacenadas, Funciones y Eventos
* Desarrollo de un **único procedimiento almacenado general y parametrizable** (con parámetros obligatorios, opcionales y comodines) para la simulación masiva de usuarios, apoyado por funciones auxiliares reutilizables (generación de fechas de nacimiento, distribuciones probabilísticas y valores aleatorios controlados)[cite: 10].
* Implementación de **eventos programados de MySQL** para automatizar tareas periódicas o diferidas conforme a las reglas de negocio[cite: 10].

---

## Escenarios de Simulación Ejecutados

### Simulación Masiva de Usuarios (7,500 registros acumulados)
Ejecutada desde una conexión remota con el rol `superadmin` activo, poblando de forma sincronizada `tb_users` y `tb_people`[cite: 11]:
* **Test 1:** Inserción de **500 usuarios** de género masculino originarios de Estados Unidos[cite: 11].
* **Test 2:** Inserción de **2,000 usuarios** de diversos países con edades entre 19 y 35 años[cite: 11].
* **Test 3:** Inserción de **5,000 usuarios** aplicando una distribución probabilística del **80% de cuentas activas (`b'1'`)** y **20% de cuentas inactivas (`b'0'`)**[cite: 11].

### Población Masiva de Productos por Vendedores Remotos (7,000+ registros)
Ejecutada mediante conexiones remotas independientes utilizando cuentas con privilegios del rol `seller`[cite: 11]:
* **`seller1`:** Inserción masiva de **5,000 productos**[cite: 11].
* **`seller2`:** Inserción masiva de **2,000 productos**[cite: 11].
* Cobertura mínima garantizada de **5 productos por categoría y subcategoría**, incluyendo artículos descontinuados (`status = b'0'`) y trazabilidad completa en auditoría[cite: 11].

---

## Respaldos, Documentación y Control de Versiones

* **Respaldos Progresivos:** Generación de dumps SQL identificados por fecha y secuencia al cierre de cada sesión, preservando estructura, datos, triggers, vistas, rutinas y scripts de privilegios[cite: 11, 12].
* **Documentación Técnica (Archify):** Actualización del **Modelo Entidad-Relación Extendido (MERE)** y del **Diccionario de Datos** reflejando las 25 tablas y sus relaciones finales[cite: 12].
* **Flujo Git / GitHub:** Desarrollo organizado en la rama `Practica03` con commits descriptivos y fusión (`merge`) limpia hacia la rama principal del repositorio[cite: 12].
