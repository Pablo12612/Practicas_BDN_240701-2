USE db_test_7b;

/*1. Cuantas tablas existen en la base de datos */
SHOW TABLES;

/*2. Cuantos triggers existen en la base de datos */ 
SHOW TRIGGERS FROM db_test_7b;

/*3. Cuantos registros existen en la tabla users */
SELECT COUNT(*) AS total_registros FROM tb_users;

/*4. Cuantos registros existen en la tabla bitacora */
SELECT COUNT(*) AS total_registros FROM tb_logs;

/*5- Consuultar todas las operaciones en la base de datos */
SELECT * FROM tb_logs;

/* 6. Consultar todas las operaciones realizadas en la base de datos */
SELECT * FROM tb_logs;

/*7. Verificar losroles dque fueron creados*/
Select user,host from mysql.user where host= '%' and account_locked ='Y';

/* 8. Verificar que usuarios tienen que roles */
SELECT TO_USER AS usuario, TO_HOST AS host, FROM_USER AS rol, FROM_HOST AS rol_host
FROM mysql.role_edges ORDER BY TO_USER, FROM_USER;

/*9. Verificar el total de procedimientos almacenados que existen en la bd*/
SHOW PROCEDURE STATUS WHERE Db= 'db_test_7b';


/* 10. Verificación de Productos */ 
SELECT * FROM tb_products;

/* 11. Contabilizar los productos */ 
SELECT COUNT(*) FROM tb_products;

/* 12. Consulta para saber la trazabilidad de los productos */ 
SELECT * 
FROM vw_trazabilidad_productos 
ORDER BY operation_date DESC 
LIMIT 10;

/* 13. Consulta la trazabilidad de usuarios */ 
SELECT * 
FROM vw_trazabilidad_usuarios 
ORDER BY operation_date ASC;

/* 14. Contabilizar cuántos productos por tabla hay por usuario */
SELECT 
    vp.inserted_by, 
    COUNT(*) AS total_productos
FROM vw_trazabilidad_productos vp
GROUP BY vp.inserted_by;

SELECT * FROM mysql.role_edges;


SELECT 
   u.nick,
   u.email,
   b.db_user AS inserted_by,
   GROUP_CONCAT(
        DISTINCT re.FROM_USER
        ORDER BY re.FROM_USER
        SEPARATOR ', '
   ) AS roles,
   b.operation_description,
   b.operation_date
FROM tb_users u
JOIN tb_logs b 
    ON b.operation_description LIKE CONCAT('%', u.nick, '%')
    AND b.operation_description LIKE CONCAT('%', u.email, '%')

LEFT JOIN mysql.role_edges re
    ON re.TO_USER = SUBSTRING_INDEX(b.db_user, '@', 1)

    WHERE b.table_operation = 'Create'
       AND b.table_name = 'tb_users'

       GROUP BY
          u.nick,
          u.email,
          b.db_user,
          b.operation_description,
          b.operation_date
          
          ORDER BY b.operation_date asc;


          SELECT 
    u.nick,
    u.email,
    b.db_user AS inserted_by,
    GROUP_CONCAT(
        DISTINCT re.FROM_USER
        ORDER BY re.FROM_USER
        SEPARATOR ', '
    ) AS roles,
    b.table_description,
    b.operation_date
FROM tb_users u
JOIN tb_logs b 
    ON b.table_description LIKE CONCAT('%', u.nick, '%')
   AND b.table_description LIKE CONCAT('%', u.email, '%')
LEFT JOIN mysql.role_edges re
    ON re.TO_USER = SUBSTRING_INDEX(b.db_user, '@', 1)
WHERE b.table_operation = 'Create'
  AND b.table_name = 'tb_users'
GROUP BY
    u.nick,
    u.email,
    b.db_user,
    b.table_description,
    b.operation_date
ORDER BY b.operation_date ASC;



SELECT * FROM tb_products;
SELECT
p.id,
p.name,
p.description,
b.db_user AS inserted_by,

COALESCE(
    GROUP_CONCAT(
        DISTINCT re.FROM_USER
        ORDER BY re.FROM_USER
         SEPARATOR ', '
         ), 
         'no hay roles bro') 
         AS roles,

    b.table_operation,
    b.operation_date

    FROM tb_products p

    JOIN tb_logs b
    ON b.table_description LIKE CONCAT(
        '%', p.name, '%'
        )
LEFT JOIN mysql.role_edges re
    ON re.TO_USER = SUBSTRING_INDEX(b.db_user, '@', 1)
    WHERE b.table_operation = 'Create'
    AND b.table_name = 'tb_products'

  GROUP BY 
    p.id, 
    p.name, 
    p.description,
    b.db_user, 
    b.table_description, 
    b.operation_date
    
    ORDER BY b.operation_date ASC;