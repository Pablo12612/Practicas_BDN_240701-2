CREATE DATABASE IF NOT EXISTS db_test_7b;
USE db_test_7b;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: localhost    Database: db_test_7b
-- ------------------------------------------------------
-- Server version	8.0.36

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `tb_logs`
--

DROP TABLE IF EXISTS `tb_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_logs` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `table_name` varchar(80) NOT NULL,
  `table_operation` enum('Create','Read','Update','Delete') DEFAULT NULL,
  `db_user` varchar(80) NOT NULL,
  `operation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `table_description` text NOT NULL,
  `operation_status` bit(1) DEFAULT b'1',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_logs`
--

LOCK TABLES `tb_logs` WRITE;
/*!40000 ALTER TABLE `tb_logs` DISABLE KEYS */;
INSERT INTO `tb_logs` VALUES (1,'tb_users','Create','root@localhost','2026-09-10 10:25:28','Usuario creado. ID=4, email=240701@utxicotepec.edu.mx, nick=TI-PABLOMG, creation_date=2026-09-10 10:25:28, status=',_binary ''),(2,'tb_users','Create','root@localhost','2026-09-10 10:26:54','Usuario creado. ID=5, email=240597@utxicotepec.edu.mx, nick=TI-MARIOBS, creation_date=2026-09-10 10:26:54, status=',_binary ''),(3,'tb_users','Create','root@localhost','2026-09-10 10:28:45','Usuario creado. ID=6, email=246457@utxicotepec.edu.mx, nick=TI-ALFONSOGH, creation_date=2026-09-10 10:28:45, status=',_binary ''),(4,'tb_users','Create','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:00:50','Usuario creado. ID=7, email=240904@utxicotepec.edu.mx, nick=AlfonsiniBananini, creation_date=2026-09-10 11:00:50, status=',_binary ''),(5,'tb_users','Create','mario.banda@DESKTOP-OCO5KIC','2026-09-10 11:01:31','Usuario creado. ID=8, email=240545@utxicotepec.edu.mx, nick=POZOLEPRO, creation_date=2026-09-10 11:01:31, status=',_binary ''),(6,'tb_users','Create','mario.banda@DESKTOP-OCO5KIC','2026-09-10 11:01:53','Usuario creado. ID=9, email=230545@utxicotepec.edu.mx, nick=POZOLEROJO, creation_date=2026-09-10 11:01:53, status=',_binary ''),(7,'tb_users','Create','mario.banda@DESKTOP-OCO5KIC','2026-09-10 11:02:13','Usuario creado. ID=10, email=223523@utxicotepec.edu.mx, nick=POZOLEBLANCO, creation_date=2026-09-10 11:02:13, status=',_binary ''),(8,'tb_users','Create','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:03:23','Usuario creado. ID=11, email=alfonsiniNaranjini@gmail.com, nick=AlfonsiniNaranjini, creation_date=2026-09-10 11:03:23, status=',_binary ''),(9,'tb_users','Create','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:03:39','Usuario creado. ID=12, email=alfonsiniFresini@gmail.com, nick=AlfonsiniFresini, creation_date=2026-09-10 11:03:39, status=',_binary ''),(10,'tb_users','Create','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:36:59','Usuario creado. ID=13, email=alfonsiniPear@gmail.com, nick=AlfonsiniPear, creation_date=2026-09-10 11:36:59, status=',_binary ''),(11,'tb_users','Update','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:37:50','Usuario modificado. ID=12, nuevo_email=alfonsiniFresini@gmail.com, nuevo_nick=AlfonsiniModificado, nuevo_status=',_binary ''),(12,'tb_users','Delete','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:42:51','Usuario eliminado. ID=13, email=alfonsiniPear@gmail.com, nickname=AlfonsiniPear',_binary ''),(13,'tb_users','Update','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:48:06','Usuario modificado. ID=11, nuevo_email=alfonsiniNaranjini@gmail.com, nuevo_nick=AlfonsiniModificado2, nuevo_status=',_binary ''),(14,'tb_users','Delete','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:48:16','Usuario eliminado. ID=11, email=alfonsiniNaranjini@gmail.com, nickname=AlfonsiniModificado2',_binary ''),(15,'tb_users','Update','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:49:17','Usuario modificado. ID=7, nuevo_email=240904@utxicotepec.edu.mx, nuevo_nick=AlfonsiniModificado3, nuevo_status=',_binary ''),(16,'tb_users','Delete','alfonsini.bananini@DESKTOP-V77K1FA','2026-09-10 11:49:29','Usuario eliminado. ID=7, email=240904@utxicotepec.edu.mx, nickname=AlfonsiniModificado3',_binary ''),(17,'tb_users','Update','mario.banda@DESKTOP-OCO5KIC','2026-09-10 12:16:31','Usuario modificado. ID=8, nuevo_email=240545@utxicotepec.edu.mx, nuevo_nick=POZOLE, nuevo_status=',_binary ''),(18,'tb_users','Delete','mario.banda@DESKTOP-OCO5KIC','2026-09-10 12:45:33','Usuario eliminado. ID=9, email=230545@utxicotepec.edu.mx, nickname=POZOLEROJO',_binary ''),(19,'tb_products','Create','root@localhost','2026-09-17 11:36:27','Producto creado. ID=1, SKU=PROD-001, name=Laptop Alienware 12, price=18500.50, stock=10, status=',_binary ''),(20,'tb_products','Create','root@localhost','2026-09-17 11:37:28','Producto creado. ID=2, SKU=PROD-005, name=Audífonos HyperX Cloud II, price=1750.00, stock=30, status=',_binary ''),(21,'tb_products','Create','jhonatan.ibarra@PC-18','2026-09-17 13:34:50','Producto creado. ID=3, SKU=PROD-002, name=Mouse Gamer RGB, price=350.00, stock=25, status=',_binary ''),(22,'tb_products','Create','jhonatan.ibarra@PC-18','2026-09-17 13:34:50','Producto creado. ID=4, SKU=PROD-003, name=Teclado Mecánico, price=850.50, stock=15, status=',_binary ''),(23,'tb_products','Create','jhonatan.ibarra@PC-18','2026-09-17 13:34:50','Producto creado. ID=5, SKU=PROD-004, name=Monitor 24 FHD, price=2499.99, stock=8, status=',_binary ''),(24,'tb_products','Create','jhonatan.ibarra@PC-18','2026-09-17 13:34:50','Producto creado. ID=6, SKU=PROD-007, name=Audífonos Bluetooth, price=599.00, stock=20, status=',_binary ''),(25,'tb_products','Create','jhonatan.ibarra@PC-18','2026-09-17 13:34:50','Producto creado. ID=7, SKU=PROD-006, name=Webcam 1080p, price=100.00, stock=11, status=',_binary ''),(26,'tb_users','Create','alfonso.garcia@PC-16','2026-09-17 13:40:52','Usuario creado. ID=14, email=pablo@gmail.com, nick=Pablo, creation_date=2026-09-17 13:40:52, status=',_binary '');
/*!40000 ALTER TABLE `tb_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_products`
--

DROP TABLE IF EXISTS `tb_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_products` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `SKU` varchar(50) NOT NULL,
  `name` varchar(250) NOT NULL,
  `description` text,
  `current_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `current_stock` int unsigned NOT NULL DEFAULT '0',
  `status` bit(1) DEFAULT b'1',
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `SKU` (`SKU`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_products`
--

LOCK TABLES `tb_products` WRITE;
/*!40000 ALTER TABLE `tb_products` DISABLE KEYS */;
INSERT INTO `tb_products` VALUES (1,'PROD-001','Laptop Alienware 12','Procesador i6, 16GB RAM, SSD 512GB',18500.50,10,_binary '','2026-09-17 11:36:27','2026-09-17 11:36:27'),(2,'PROD-005','Audífonos HyperX Cloud II','Sonido Surround 7.1, Micrófono extraíble',1750.00,30,_binary '','2026-09-17 11:37:28','2026-09-17 11:37:28'),(3,'PROD-002','Mouse Gamer RGB','Mouse óptico con 7 botones programables y 7200 DPI',350.00,25,_binary '','2026-09-17 13:34:50','2026-09-17 13:34:50'),(4,'PROD-003','Teclado Mecánico','Teclado mecánico switches blue con retroiluminación',850.50,15,_binary '','2026-09-17 13:34:50','2026-09-17 13:34:50'),(5,'PROD-004','Monitor 24 FHD','Monitor 1080p a 75Hz panel IPS sin bordes',2499.99,8,_binary '','2026-09-17 13:34:50','2026-09-17 13:34:50'),(6,'PROD-007','Audífonos Bluetooth','Audífonos diadema con cancelación de ruido pasiva',599.00,20,_binary '','2026-09-17 13:34:50','2026-09-17 13:34:50'),(7,'PROD-006','Webcam 1080p','Cámara HD con micrófono',100.00,11,_binary '','2026-09-17 13:34:50','2026-09-17 13:34:50');
/*!40000 ALTER TABLE `tb_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tb_users`
--

DROP TABLE IF EXISTS `tb_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tb_users` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `email` varchar(100) NOT NULL,
  `nick` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `creation_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_update` datetime DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `status` bit(1) DEFAULT b'1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `nick` (`nick`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tb_users`
--

LOCK TABLES `tb_users` WRITE;
/*!40000 ALTER TABLE `tb_users` DISABLE KEYS */;
INSERT INTO `tb_users` VALUES (4,'240701@utxicotepec.edu.mx','TI-PABLOMG','871534c2971fceb021437786bc940bd2','2026-09-10 10:25:28',NULL,NULL,_binary ''),(5,'240597@utxicotepec.edu.mx','TI-MARIOBS','871534c2971fceb021437786bc940bd2','2026-09-10 10:26:54',NULL,NULL,_binary ''),(6,'246457@utxicotepec.edu.mx','TI-ALFONSOGH','871534c2971fceb021437786bc940bd2','2026-09-10 10:28:45',NULL,NULL,_binary ''),(8,'240545@utxicotepec.edu.mx','POZOLE','99b80047919135e419e068ff7fd150a2','2026-09-10 11:01:31',NULL,NULL,_binary ''),(10,'223523@utxicotepec.edu.mx','POZOLEBLANCO','99b80047919135e419e068ff7fd150a2','2026-09-10 11:02:13',NULL,NULL,_binary ''),(12,'alfonsiniFresini@gmail.com','AlfonsiniModificado','81dc9bdb52d04dc20036dbd8313ed055','2026-09-10 11:03:39',NULL,NULL,_binary ''),(14,'pablo@gmail.com','Pablo','81dc9bdb52d04dc20036dbd8313ed055','2026-09-17 13:40:52',NULL,NULL,_binary '');
/*!40000 ALTER TABLE `tb_users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-17 13:41:25
