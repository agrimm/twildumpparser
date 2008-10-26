-- MySQL dump 8.23
--
-- Host: 10.0.0.102    Database: howiki
---------------------------------------------------------
-- Server version	4.0.40-wikimedia-log

--
-- Table structure for table `redirect`
--

DROP TABLE IF EXISTS `redirect`;
CREATE TABLE `redirect` (
  `rd_from` int(8) unsigned NOT NULL default '0',
  `rd_namespace` int(11) NOT NULL default '0',
  `rd_title` varchar(255) binary NOT NULL default '',
  PRIMARY KEY  (`rd_from`),
  KEY `rd_ns_title` (`rd_namespace`,`rd_title`,`rd_from`)
) TYPE=InnoDB;

/*!40000 ALTER TABLE `redirect` DISABLE KEYS */;

--
-- Dumping data for table `redirect`
--


LOCK TABLES `redirect` WRITE;
INSERT INTO `redirect` VALUES (1859,0,'Aposetolo_Paulo_on_Wheels!'),(1860,0,'Baibel_on_Wheels!'),(1860,2,'Baibel_on_Wheels!');

/*!40000 ALTER TABLE `redirect` ENABLE KEYS */;
UNLOCK TABLES;

