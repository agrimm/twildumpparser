-- MySQL dump 8.23
--
-- Host: 10.0.0.102    Database: howiki
---------------------------------------------------------
-- Server version	4.0.40-wikimedia-log

--
-- Table structure for table `redirect`
--


/*!40000 ALTER TABLE `redirects` DISABLE KEYS */;

--
-- Dumping data for table `redirect`
--


LOCK TABLES `redirects` WRITE;
INSERT INTO `redirects` (redirect_source_repository_id, redirect_source_local_id, redirect_target_title, created_at, updated_at) VALUES (3,1859,'Aposetolo Paulo on Wheels!',now(),now()),(3,1860,'Baibel on Wheels!',now(),now());

/*!40000 ALTER TABLE `redirects` ENABLE KEYS */;
UNLOCK TABLES;

