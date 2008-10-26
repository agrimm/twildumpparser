-- MySQL dump 8.23
--
-- Host: 10.0.0.102    Database: howiki
---------------------------------------------------------
-- Server version	4.0.40-wikimedia-log

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
CREATE TABLE `page` (
  `page_id` int(8) unsigned NOT NULL auto_increment,
  `page_namespace` int(11) NOT NULL default '0',
  `page_title` varchar(255) binary NOT NULL default '',
  `page_restrictions` varchar(255) binary NOT NULL default '',
  `page_counter` bigint(20) unsigned NOT NULL default '0',
  `page_is_redirect` tinyint(1) unsigned NOT NULL default '0',
  `page_is_new` tinyint(1) unsigned NOT NULL default '0',
  `page_random` double unsigned NOT NULL default '0',
  `page_touched` varchar(14) binary NOT NULL default '',
  `page_latest` int(8) unsigned NOT NULL default '0',
  `page_len` int(8) unsigned NOT NULL default '0',
  `page_no_title_convert` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`page_id`),
  UNIQUE KEY `name_title` (`page_namespace`,`page_title`),
  KEY `page_random` (`page_random`),
  KEY `page_len` (`page_len`)
) TYPE=InnoDB;

/*!40000 ALTER TABLE `page` DISABLE KEYS */;

--
-- Dumping data for table `page`
--


LOCK TABLES `page` WRITE;
INSERT INTO `page` VALUES (1442,2,'Korg/monobook.js','',0,0,1,0.128080379874,'20051128004645',2607,142,0),(1,0,'Main_Page','',0,0,0,0.08651978154,'20070710205417',3618,254,0),(1442,2,'Korg/monobook.js','',0,0,1,0.128080379874,'20051128004645',2607,142,0),(1875,0,'Sivarai_Namona_Ioane_Ia_Torea','',0,0,0,0.362809785777,'20070710204939',3612,1034,0),(1442,2,'Korg/monobook.js','',0,0,1,0.128080379874,'20051128004645',2607,142,0);

/*!40000 ALTER TABLE `page` ENABLE KEYS */;
UNLOCK TABLES;

