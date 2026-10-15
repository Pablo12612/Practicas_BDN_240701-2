/* Eliminar usuarios si ya existen */
DROP USER IF EXISTS 'marco.ramirez'@'%';
DROP USER IF EXISTS 'pablo.martinez'@'%';
DROP USER IF EXISTS 'aaron.carballo'@'%';
DROP USER IF EXISTS 'alfonso.garcia'@'%';
DROP USER IF EXISTS 'jhonatan.ibarra'@'%';

/* Eliminar roles si ya existen */
DROP ROLE IF EXISTS 'superadmin';
DROP ROLE IF EXISTS 'admin';
DROP ROLE IF EXISTS 'seller';
DROP ROLE IF EXISTS 'buyer';
DROP ROLE IF EXISTS 'support';
DROP ROLE IF EXISTS 'common';
DROP ROLE IF EXISTS 'user_not_registred';

/* Creación de usuarios remotos */
CREATE USER 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER 'pablo.martinez'@'%' IDENTIFIED BY '240701';
CREATE USER 'aaron.carballo'@'%' IDENTIFIED BY '240988';
CREATE USER 'jhonatan.ibarra'@'%' IDENTIFIED BY '240080';
CREATE USER 'alfonso.garcia'@'%' IDENTIFIED BY '240904';

/* Asignar privilegios directos a usuarios */
GRANT ALL PRIVILEGES ON *.* TO 'pablo.martinez'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test_7b.* TO 'aaron.carballo'@'%';

/* Creación de roles para el sistema de E-Commerce */
CREATE ROLE IF NOT EXISTS 'superadmin';
CREATE ROLE IF NOT EXISTS 'admin';
CREATE ROLE IF NOT EXISTS 'seller';
CREATE ROLE IF NOT EXISTS 'buyer';
CREATE ROLE IF NOT EXISTS 'support';
CREATE ROLE IF NOT EXISTS 'common';
CREATE ROLE IF NOT EXISTS 'user_not_registred';

/* Asignar privilegios a los roles creados */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin';
GRANT ALL PRIVILEGES ON db_test_7b.* TO 'admin';
GRANT SELECT, UPDATE, INSERT ON db_test_7b.* TO 'support';

/* SUPPORT */
GRANT SELECT, INSERT, UPDATE ON db_test_7b.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_7b.tb_products TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_7b.tbc_categories TO 'support';

/* SELLER */
GRANT SELECT, INSERT, UPDATE ON db_test_7b.tb_products TO 'seller';

/* Asignación de roles a usuarios */
GRANT 'superadmin' TO 'pablo.martinez'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'aaron.carballo'@'%';
GRANT 'seller' TO 'jhonatan.ibarra'@'%';
GRANT 'seller' TO 'alfonso.garcia'@'%';

/* Definir roles por defecto */
SET DEFAULT ROLE 'superadmin' TO 'pablo.martinez'@'%';
SET DEFAULT ROLE 'admin' TO 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' TO 'aaron.carballo'@'%';
SET DEFAULT ROLE 'seller' TO 'jhonatan.ibarra'@'%', 'alfonso.garcia'@'%';

/* Aplicar los cambios de privilegios */
FLUSH PRIVILEGES;