----******************************************************
--
--          Data Warehouse Database
--
--SQL Code to Create Data Warehouse Database
--***************************************************************
USE master;

IF DB_ID('Ziel_DWH') IS NOT NULL

  DROP DATABASE [Ziel_DWH];

CREATE DATABASE [Ziel_DWH]