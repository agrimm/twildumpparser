-- MySQL dump 8.23
--
-- Host: 10.0.0.102    Database: howiki
---------------------------------------------------------
-- Server version	4.0.40-wikimedia-log

--
-- Table structure for table `page`
--


/*!40000 ALTER TABLE `articles` DISABLE KEYS */;

--
-- Dumping data for table `page`
--


LOCK TABLES `articles` WRITE;
INSERT INTO `articles` (id, uri, title, repository_id, local_id, created_at, updated_at) VALUES (NULL,NULL,'Main Page',3,1,now(),now()),(NULL,NULL,'Sivarai Namona Ioane Ia Torea',3,1875,now(),now());

/*!40000 ALTER TABLE `articles` ENABLE KEYS */;
UNLOCK TABLES;

