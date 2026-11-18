/* ============================================================================
   SCRIPT DE ADMINISTRACIÓN DE USUARIOS, ROLES Y PRIVILEGIOS - db_test_7bb
   Incluye: Equipo de trabajo + Aplicaciones (AppWeb / AppMobile) + Roles RBAC
   ============================================================================ */

USE db_test_7bb;

/* 1. Eliminar usuarios si ya existen (para reinicio limpio del script) */
DROP USER IF EXISTS 'marco.ramirez'@'%';
DROP USER IF EXISTS 'pablo.martinez'@'%';
DROP USER IF EXISTS 'aaron.carballo'@'%';
DROP USER IF EXISTS 'alfonso.garcia'@'%';
DROP USER IF EXISTS 'jhonatan.ibarra'@'%';

DROP USER IF EXISTS 'AppWeb'@'%';
DROP USER IF EXISTS 'AppWeb'@'localhost';
DROP USER IF EXISTS 'AppMobile'@'%';
DROP USER IF EXISTS 'AppMobile'@'localhost';

/* 2. Eliminar roles si ya existen */
DROP ROLE IF EXISTS 'superadmin';
DROP ROLE IF EXISTS 'admin';
DROP ROLE IF EXISTS 'seller';
DROP ROLE IF EXISTS 'buyer';
DROP ROLE IF EXISTS 'support';
DROP ROLE IF EXISTS 'common';
DROP ROLE IF EXISTS 'user_not_registred';
DROP ROLE IF EXISTS 'user_not_registered';

/* 3. Creación de usuarios remotos del equipo */
CREATE USER 'marco.ramirez'@'%' IDENTIFIED BY 'qwerty123';
CREATE USER 'pablo.martinez'@'%' IDENTIFIED BY '240701';
CREATE USER 'aaron.carballo'@'%' IDENTIFIED BY '240988';
CREATE USER 'jhonatan.ibarra'@'%' IDENTIFIED BY '240080';
CREATE USER 'alfonso.garcia'@'%' IDENTIFIED BY '240904';

/* 4. Creación de usuarios de aplicación (Web y Móvil - local y remoto) */
CREATE USER 'AppWeb'@'%' IDENTIFIED BY 'AppWeb123';
CREATE USER 'AppWeb'@'localhost' IDENTIFIED BY 'AppWeb123';
CREATE USER 'AppMobile'@'%' IDENTIFIED BY 'AppMobile123';
CREATE USER 'AppMobile'@'localhost' IDENTIFIED BY 'AppMobile123';

/* 5. Creación de roles para el sistema de E-Commerce */
CREATE ROLE 'superadmin';
CREATE ROLE 'admin';
CREATE ROLE 'seller';
CREATE ROLE 'buyer';
CREATE ROLE 'support';
CREATE ROLE 'common';
CREATE ROLE 'user_not_registered';

/* ============================================================================
   6. ASIGNACIÓN DE PRIVILEGIOS A ROLES Y USUARIOS DIRECTOS
   ============================================================================ */

/* Privilegios directos administrativos */
GRANT ALL PRIVILEGES ON *.* TO 'pablo.martinez'@'%' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test_7bb.* TO 'aaron.carballo'@'%';

/* SUPERADMIN & ADMIN */
GRANT ALL PRIVILEGES ON *.* TO 'superadmin' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON db_test_7bb.* TO 'admin';

/* SUPPORT */
GRANT SELECT, UPDATE, INSERT ON db_test_7bb.* TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_users TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_products TO 'support';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbc_categories TO 'support';

/* SELLER (Incluye tablas y rutinas de carga masiva de productos) */
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_products TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbd_products_categories TO 'seller';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbd_products_users_providers TO 'seller';
GRANT SELECT ON db_test_7bb.tbc_categories TO 'seller';
GRANT SELECT ON db_test_7bb.tb_users TO 'seller';
GRANT EXECUTE ON PROCEDURE db_test_7bb.sp_simular_productos_masivo TO 'seller';
GRANT EXECUTE ON FUNCTION db_test_7bb.fn_random_int TO 'seller';
GRANT EXECUTE ON FUNCTION db_test_7bb.fn_generar_estado_prob TO 'seller';

/* USER_NOT_REGISTERED (Navegación, registro de usuario, armado de carrito, dirección y orden) */
GRANT SELECT ON db_test_7bb.tb_products TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbc_categories TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbc_product_brands TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbc_order_statuses TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbc_payment_methods_types TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbc_shipping_carriers TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbd_product_images TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbd_product_reviews TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbd_products_categories TO 'user_not_registered';
GRANT SELECT ON db_test_7bb.tbd_products_users_providers TO 'user_not_registered';

GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_users TO 'user_not_registered';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_people TO 'user_not_registered';

GRANT SELECT, INSERT, UPDATE, DELETE ON db_test_7bb.tb_carts TO 'user_not_registered';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test_7bb.tbd_carts_items TO 'user_not_registered';

GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_buyer_orders TO 'user_not_registered';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbd_order_items TO 'user_not_registered';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_user_addresses TO 'user_not_registered';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbd_address_components TO 'user_not_registered';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbd_user_payment_methods TO 'user_not_registered';
GRANT SELECT, INSERT ON db_test_7bb.tb_order_payments TO 'user_not_registered';

/* BUYER (Hereda user_not_registered + transacciones bancarias, envíos, devoluciones y stock) */
GRANT 'user_not_registered' TO 'buyer';

GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_order_payments TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbd_payment_transactions TO 'buyer';

GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tb_order_shipments TO 'buyer';
GRANT SELECT, INSERT, UPDATE ON db_test_7bb.tbd_shipment_tracking TO 'buyer';

GRANT UPDATE (current_stock, last_update) ON db_test_7bb.tb_products TO 'buyer';

GRANT SELECT, INSERT, UPDATE, DELETE ON db_test_7bb.tbd_product_reviews TO 'buyer';
GRANT SELECT, INSERT, UPDATE, DELETE ON db_test_7bb.tbd_users_wishlist_products TO 'buyer';

/* ============================================================================
   7. ASIGNACIÓN DE ROLES A USUARIOS Y ROLES POR DEFECTO
   (Sintaxis MariaDB: un rol por sentencia GRANT)
   ============================================================================ */

/* Equipo de trabajo */
GRANT 'superadmin' TO 'pablo.martinez'@'%';
GRANT 'admin' TO 'marco.ramirez'@'%';
GRANT 'support' TO 'aaron.carballo'@'%';
GRANT 'seller' TO 'jhonatan.ibarra'@'%';
GRANT 'seller' TO 'alfonso.garcia'@'%';

/* Aplicaciones Web y Móvil (un GRANT por rol) */
GRANT 'user_not_registered' TO 'AppWeb'@'%';
GRANT 'buyer' TO 'AppWeb'@'%';

GRANT 'user_not_registered' TO 'AppWeb'@'localhost';
GRANT 'buyer' TO 'AppWeb'@'localhost';

GRANT 'user_not_registered' TO 'AppMobile'@'%';
GRANT 'buyer' TO 'AppMobile'@'%';

GRANT 'user_not_registered' TO 'AppMobile'@'localhost';
GRANT 'buyer' TO 'AppMobile'@'localhost';

/* Roles por defecto */
SET DEFAULT ROLE 'superadmin' FOR 'pablo.martinez'@'%';
SET DEFAULT ROLE 'admin' FOR 'marco.ramirez'@'%';
SET DEFAULT ROLE 'support' FOR 'aaron.carballo'@'%';
SET DEFAULT ROLE 'seller' FOR 'jhonatan.ibarra'@'%';
SET DEFAULT ROLE 'seller' FOR 'alfonso.garcia'@'%';

SET DEFAULT ROLE 'user_not_registered' FOR 'AppWeb'@'%';
SET DEFAULT ROLE 'user_not_registered' FOR 'AppWeb'@'localhost';
SET DEFAULT ROLE 'user_not_registered' FOR 'AppMobile'@'%';
SET DEFAULT ROLE 'user_not_registered' FOR 'AppMobile'@'localhost';

/* Aplicar los cambios de privilegios */
FLUSH PRIVILEGES;