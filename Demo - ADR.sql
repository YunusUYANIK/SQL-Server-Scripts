
--ADR rollback scenario

USE master
GO

CREATE DATABASE [TestADR]
ALTER DATABASE [TestADR] SET COMPATIBILITY_LEVEL = 150
GO

USE [TestADR]
GO

ALTER DATABASE TestADR SET ACCELERATED_DATABASE_RECOVERY = ON;

SELECT name,is_accelerated_database_recovery_on FROM sys.databases WHERE name='TestADR';

SET STATISTICS IO,TIME ON;

BEGIN TRAN;
UPDATE Votes SET BountyAmount=10;
GO

ROLLBACK;



--Without ADR rollback scenario

USE master
GO

CREATE DATABASE [TestWithoutADR]
ALTER DATABASE [TestWithoutADR] SET COMPATIBILITY_LEVEL = 150
GO

USE [TestWithoutADR]
GO

SELECT name,is_accelerated_database_recovery_on FROM sys.databases WHERE name='TestWithoutADR';

SET STATISTICS IO,TIME ON;

BEGIN TRAN;
UPDATE Votes SET BountyAmount=10;
GO

ROLLBACK;
