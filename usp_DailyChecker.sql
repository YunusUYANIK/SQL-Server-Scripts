USE master
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('dbo.usp_DailyChecker') IS NULL
  EXEC ('CREATE PROCEDURE dbo.usp_DailyChecker AS RETURN 0;');
GO
ALTER PROC [dbo].[usp_DailyChecker]
	@ResultHTML INT = 0,
	@SendMail INT = 0,
	@to VARCHAR(MAX) = NULL,
	@profilename varchar(MAX) = NULL

WITH ENCRYPTION
AS


/*--------------------------------------------------------------------------
Written by Yunus UYANIK AND Buğrahan BOL(%4), yunusuyanik.com
Version 1.8
Date : 12.01.2021
(c) 2020, yunusuyanik.com. All rights reserved.

For more scripts and sample code and Turkish document, check out 
www.yunusuyanik.com - www.silikonakademi.com

MIT License

Copyright (c) 2020 YunusUYANIK

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

---------------------------------------------------------------------------*/



SET NOCOUNT ON;

IF OBJECT_ID('tempdb..##uns_DailyChecker') IS NOT NULL DROP TABLE ##uns_DailyChecker;
	CREATE TABLE ##uns_DailyChecker 
	(Id int identity(1,1),
	unsOrder int,
	CheckGroup VARCHAR(250),
	CheckSubGroup VARCHAR(1000),
	DatabaseName VARCHAR(250),
	Details VARCHAR(max),
	Details2 VARCHAR(max),
	Comment VARCHAR(max),
	Type TINYINT,--0 info ,1 success, 2 warning 3 danger
	DefinitionTSQL NVARCHAR(MAX),
	CreateTSQL NVARCHAR(MAX),
	DropTSQL NVARCHAR(MAX)
	)


RAISERROR('...',0,1) WITH NOWAIT;
RAISERROR('usp_DailyChecker',0,1) WITH NOWAIT;
RAISERROR('www.yunusuyanik.com',0,1) WITH NOWAIT;
RAISERROR('Processes starting...',0,1) WITH NOWAIT;

		DECLARE @sqlrestarttime VARCHAR(100) = (SELECT CONVERT(VARCHAR(100),create_date,120) FROM sys.databases where database_id=2)
		DECLARE @uns_tsql NVARCHAR(MAX)
		DECLARE @ProductVersion NVARCHAR(128) =CONVERT(VARCHAR(100),SERVERPROPERTY('ProductVersion'));
		DECLARE @ProductVersionMajor INT;

		INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2)
		VALUES (-1,'Daily Checker',NULL,NULL,CONVERT(VARCHAR(100),GETDATE(),120)+' tarihinde çalıştırılmıştır.',NULL)


		CREATE TABLE #uns_DefaultServerConfig (name varchar(500),value int)

		INSERT INTO #uns_DefaultServerConfig (name,value) VALUES
		('access check cache bucket count', 0),
		('access check cache quota', 0),
		('ad hoc distributed queries', 0),
		('affinity I/O mask', 0),
		('affinity64 I/O mask', 0),
		('affinity mask', 0),
		('affinity64 mask', 0),
		('allow updates', 0),
		('backup compression default', 0),
		('blocked process threshold', 0),
		('c2 audit mode', 0),
		('clr enabled', 0),
		('common criteria compliance enabled', 0),
		('contained database authentication', 0),
		('cost threshold for parallelism', 5),
		('cross db ownership chaining', 0),
		('cursor threshold', -1),
		('Database Mail XPs', 0),
		('default full-text language', 1033),
		('default language', 0),
		('default trace enabled', 1),
		('disallow results from triggers', 0),
		('EKM provider enabled', 0),
		('filestream_access_level', 0),
		('fill factor', 0),
		('ft crawl bandwidth (max)', 100),
		('ft crawl bandwidth (min)', 0),
		('ft notify bandwidth (max)', 100),
		('ft notify bandwidth (min)', 0),
		('index create memory', 0),
		('in-doubt xact resolution', 0),
		('lightweight pooling', 0),
		('locks', 0),
		('max degree of parallelism', 0),
		('max full-text crawl range', 4),
		('max server memory', 2147483647),
		('max text repl size', 65536),
		('max worker threads', 0),
		('media retention', 0),
		('min memory per query', 1024),
		('min server memory', 0),
		('nested triggers', 1),
		('network packet size', 4096),
		('Ole Automation Procedures', 0),
		('open objects', 0),
		('optimize for ad hoc workloads', 0),
		('PH_timeout', 60),
		('precompute rank', 0),
		('unsOrder boost', 0),
		('query governor cost limit', 0),
		('query wait', -1),
		('recovery interval', 0),
		('remote access', 1),
		('remote admin connections', 0),
		('remote login timeout', 10),
		('remote proc trans', 0),
		('remote query timeout', 600),
		('Replication XPs Option', 0),
		('scan for startup procs', 0),
		('server trigger recursion', 1),
		('set working set size', 0),
		('show advanced options', 0),
		('SMO and DMO XPs', 1),
		('transform noise words', 0),
		('two digit year cutoff', 2049),
		('user connections', 0),
		('user options', 0),
		('xp_cmdshell', 0)

	
		

	/********** Server Info ***************/ RAISERROR('Server Info processing...',0,1) WITH NOWAIT;
	

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,Details,Details2,Type)

	SELECT  0, 'Server Info','ComputerName',CONVERT(VARCHAR(100),SERVERPROPERTY('MachineName')),NULL,0
	UNION
	SELECT  1, 'Server Info','InstanceName',CONVERT(VARCHAR(100),SERVERPROPERTY('ServerName')),NULL,0
	UNION
	SELECT  2, 'Server Info','Edition',CONVERT(VARCHAR(100),SERVERPROPERTY('Edition')),NULL,0
	UNION
	SELECT  3, 'Server Info','ProductVersion',@ProductVersion,NULL,0
	UNION
	SELECT  4, 'Server Info','ProductLevel',CONVERT(VARCHAR(100),SERVERPROPERTY('ProductLevel')),NULL,0
	UNION
	SELECT	5, 'Server Info','Last SQL Restart',CONVERT(VARCHAR(100),@sqlrestarttime,103),NULL,0

	SELECT @ProductVersionMajor = SUBSTRING(@ProductVersion, 1,CHARINDEX('.', @ProductVersion)-1);


	/********** Server Configuration ***************/ RAISERROR('Server Configuration processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,Details,Details2,Type)
	SELECT 
		unsOrder = 20,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='max server memory (MB)'
	UNION
	SELECT 
		unsOrder = 22,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='fill factor (%)'
	UNION
	SELECT 
		unsOrder = 24,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='optimize for ad hoc workloads'
	UNION
	SELECT 
		unsOrder = 26,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='remote admin connections'
	UNION
	SELECT 
		unsOrder = 28,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='cost threshold for parallelism'
	UNION
	SELECT 
		unsOrder = 30,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='backup compression default'
	UNION
	SELECT 
		unsOrder = 32,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='automatic soft-NUMA disabled'
	UNION
	SELECT 
		unsOrder = 34,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='max degree of parallelism'
	UNION
	SELECT 
		unsOrder = 36,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = name,
		Details = name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = NULL,
		Type = 0
	FROM sys.configurations WITH (NOLOCK)
	WHERE name ='xp_cmdshell'
		



	/********** Server Configuration - Non-Default ***************/ RAISERROR('Server Configuration - Non-Default processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,Details,Details2,Type)
	SELECT 
		unsOrder = 40,
		CheckGroup = 'Server Configuration',
		CheckSubGroup = 'Non-Default',
		Details = c.name +' : '+CONVERT(VARCHAR(100),value_in_use),
		Details2 = 'The config default value is : '+CONVERT(varchar(100),uc.value),
		Type = 2
	FROM sys.configurations c WITH (NOLOCK)
	JOIN #uns_DefaultServerConfig uc ON c.name=uc.name
	WHERE c.value!=uc.value
		AND c.name NOT IN (
		'max server memory (MB)',
		'fill factor (%)',
		'optimize for ad hoc workloads',
		'remote admin connections',
		'cost threshold for parallelism',
		'backup compression default',
		'automatic soft-NUMA disabled',
		'max degree of parallelism',
		'xp_cmdshell')



	/********** Group Policy Info - Lock Pages in memory ***************/ RAISERROR('Group Policy Info - Lock Pages in memory processing...',0,1) WITH NOWAIT;
	IF @ProductVersionMajor>12
	BEGIN
		SET @uns_tsql ='
		INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
		SELECT  
				unsOrder = 50, 
				CheckGroup = ''Group Policy'',
				CheckSubGroup = ''Lock Pages in memory'',
				DatabaseName = NULL,
				Details = sql_memory_model_desc,
				Type = CASE WHEN sql_memory_model_desc=''LOCK_PAGES'' THEN 1 ELSE 2 END
		FROM sys.dm_os_sys_info WITH (NOLOCK)'
	END

	/********** Group Policy Info - IFI ***************/ RAISERROR('Group Policy Info - IFI processing...',0,1) WITH NOWAIT;
	IF 
	(SELECT 1 FROM sys.all_objects o WITH (NOLOCK)
	INNER JOIN sys.all_columns c WITH (NOLOCK) ON o.object_id = c.object_id 
	WHERE o.name = 'dm_server_services' AND c.name = 'instant_file_initialization_enabled' ) IS NOT NULL 
	BEGIN
		SET @uns_tsql='
		INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
		SELECT 
			unsOrder = 60, 
			CheckGroup = ''Group Policy'',
			CheckSubGroup = ''IFI'',
			DatabaseName = NULL,
			Details = 
				CASE 
					WHEN instant_file_initialization_enabled =''Y'' THEN QUOTENAME(service_account)+'' service account has ''''Perform volume maintenance tasks'''' policy.''
					WHEN instant_file_initialization_enabled =''N'' THEN QUOTENAME(service_account)+'' service account does not have ''''Perform volume maintenance tasks'''' policy.''
				END,
			Details2 = NULL,
			Comment = NULL,
			Type = CASE WHEN instant_file_initialization_enabled=''Y'' THEN 1 ELSE 2 END
		FROM sys.dm_server_services WITH (NOLOCK)
		WHERE filename LIKE ''%sqlservr.exe%''
		OPTION (RECOMPILE); '
		EXEC sp_executesql @uns_tsql;
	END



	/********** Database Configuration - tempdb Configuration ***************/ RAISERROR('Database Configuration - tempdb Configuration processing...',0,1) WITH NOWAIT;
		DECLARE @tempdbfilecount int
		DECLARE @cpucount int
		DECLARE @sizecontrol int 

			SELECT @cpucount=cpu_count FROM sys.dm_os_sys_info

			SELECT @tempdbfilecount=COUNT(1) ,
				@sizecontrol=
				CASE 
				WHEN (SELECT TOP 1 size FROM sys.master_files WITH (NOLOCK) WHERE database_id=2 AND type=0 ) = SUM(s.size)/@tempdbfilecount
				THEN 1 
				ELSE 0 END
			FROM sys.master_files s WITH (NOLOCK)
			WHERE database_id=2 AND type=0

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)
	SELECT 
		unsOrder = 70,
		CheckGroup = 'Database Configuration',
		CheckSubGroup = 'tempdb Configuration',
		DatabaseName = 'tempdb',
		Details=
		CASE
			WHEN @cpucount>=8 AND @tempdbfilecount=8 AND @sizecontrol=1			
				THEN 'Data file count : '+CONVERT(varchar(10),@tempdbfilecount)+' and size of files are same.'
			WHEN @cpucount>=8 AND @tempdbfilecount=8 AND @sizecontrol=0			
				THEN 'tempdb file(s) size are not same'
			WHEN @cpucount>=8 AND @tempdbfilecount<>8 AND @sizecontrol=1		
				THEN 'tempdb file count is not correct it is : '+CONVERT(varchar(10),@tempdbfilecount)
			WHEN @cpucount>=8 AND @tempdbfilecount<>8 AND @sizecontrol=0		
				THEN 'tempdb configuration is not true. Check Required!'
			WHEN @cpucount<8 AND @tempdbfilecount=@cpucount AND @sizecontrol=1
				THEN 'tempdb configuration is correct.'
			WHEN @cpucount<8 AND @tempdbfilecount=@cpucount AND @sizecontrol=0
				THEN '#tempdb configuration is not true. Check Required!'
			WHEN @cpucount<8 AND @tempdbfilecount!=@cpucount AND @sizecontrol=1
				THEN '#tempdb configuration is not true. Check Required!'
			WHEN @cpucount<8 AND @tempdbfilecount!=@cpucount AND @sizecontrol=0
				THEN '#tempdb configuration is not true. Check Required!'
		ELSE '#tempdb control fail' END,
		Details2 = NULL,
		Type = CASE 
					WHEN @cpucount>=8 AND @tempdbfilecount=8 and @sizecontrol=1 THEN 1
					WHEN @cpucount<8 AND @tempdbfilecount=@cpucount and @sizecontrol=1 THEN 1 
				ELSE 3 END 
	


	/********** Database Configuration - User Databases Configuration ***************/ RAISERROR('Database Configuration - User Databases Configuration processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)

	SELECT
		unsOrder = 80,
		CheckGroup = 'Database Configuration',
		CheckSubGroup = 'is_auto_close_on',
		DatabaseName = name,
		Details= 'is_auto_close_on : '+CONVERT(varchar(10),is_auto_close_on),
		Details2 = NULL,
		Type = 3
	FROM sys.databases WITH (NOLOCK)
	WHERE database_id>5
	AND is_auto_close_on=1
	UNION
	SELECT
		unsOrder = 82,
		CheckGroup = 'Database Configuration',
		CheckSubGroup = 'is_auto_shrink_on',
		DatabaseName = name,
		Details= 'is_auto_shrink_on : '+CONVERT(varchar(10),is_auto_shrink_on),
		Details2 = NULL,
		Type = 3
	FROM sys.databases WITH (NOLOCK)
	WHERE database_id>5
	AND is_auto_shrink_on=1
	UNION
	SELECT
		unsOrder = 84,
		CheckGroup = 'Database Configuration',
		CheckSubGroup = 'is_auto_create_stats_on',
		DatabaseName = name,
		Details= 'is_auto_create_stats_on : '+CONVERT(varchar(10),is_auto_create_stats_on),
		Details2 = NULL,
		Type = 3
	FROM sys.databases WITH (NOLOCK)
	WHERE database_id>5
	AND is_auto_create_stats_on=0
	UNION
	SELECT
		unsOrder = 86,
		CheckGroup = 'Database Configuration',
		CheckSubGroup = 'is_auto_update_stats_on',
		DatabaseName = name,
		Details= 'is_auto_update_stats_on : '+CONVERT(varchar(10),is_auto_update_stats_on),
		Details2 = NULL,
		Type = 3
	FROM sys.databases WITH (NOLOCK)
	WHERE database_id>5
	AND is_auto_update_stats_on=0
	UNION
	SELECT
		unsOrder = 88,
		CheckGroup = 'Database Configuration',
		CheckSubGroup = 'compatibility_level',
		DatabaseName = name,
		Details= 'compatibility_level : '+CONVERT(varchar(10),compatibility_level),
		Details2 = NULL,
		Type = 2
	FROM sys.databases WITH (NOLOCK)
	WHERE database_id>5
	AND compatibility_level=100

	/********** Database Configuration - LegacyCardinality ***************/ RAISERROR('Database Configuration - LegacyCardinality processing...',0,1) WITH NOWAIT;
	IF @ProductVersionMajor>12
	BEGIN
		IF OBJECT_ID('tempdb..##uns_LegacyCardinality') IS NOT NULL DROP TABLE ##uns_LegacyCardinality;
		CREATE TABLE ##uns_LegacyCardinality (DatabaseName VARCHAR(255), LegacyCardinalityValue INT)
		EXEC sys.sp_MSforeachdb N'
		USE [?]
		IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
		INSERT INTO ##uns_LegacyCardinality (DatabaseName,LegacyCardinalityValue)
		SELECT 
			DatabaseName = N''?'' ,
			Value = CONVERT(INT,value)
		FROM sys.database_scoped_configurations 
		WHERE name=''LEGACY_CARDINALITY_ESTIMATION'';';
		INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
		SELECT
			unsOrder=90,
			CheckGroup='Database Configuration',
			CheckSubGroup='LEGACY_CARDINALITY_ESTIMATION',
			DatabaseName,
			Details = 'LEGACY_CARDINALITY_ESTIMATION : '+IIF(LegacyCardinalityValue=0,'OFF','ON'),
			Type = 2
		FROM ##uns_LegacyCardinality
		WHERE LegacyCardinalityValue=1
	END
	
	/********** Auto-Growth - Possibly Warnings ***************/ RAISERROR('Auto-Growth - Possibly Warnings processing...',0,1) WITH NOWAIT;
	;WITH cte_AutoGrowt AS (
		SELECT d.name as database_name,
			CASE
				WHEN mf.is_percent_growth=0 AND (mf.growth*8/1024)%64!=0 AND (mf.growth*8/1024)>64 AND mf.growth!=0
					THEN 'Auto-Growth is NOT multiple of 64MB '
				WHEN mf.is_percent_growth=0 AND (mf.growth*8/1024)<64  AND mf.growth!=0
					THEN 'Auto-Growth is set below 64MB '
				WHEN mf.is_percent_growth=1
					THEN 'Auto-Growth is set that type of percent '
				WHEN mf.growth=0
					THEN 'Auto-Growth is disable '
				ELSE NULL END AS details,
			CASE
				WHEN mf.is_percent_growth=0 THEN (mf.growth*8/1024) ELSE mf.growth END AS growth
		FROM sys.master_files mf WITH (NOLOCK)
		JOIN sys.databases d WITH (NOLOCK) on mf.database_id=d.database_id
		WHERE d.state=0 AND mf.type IN (0,1))
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT  
		unsOrder = 110, 
		CheckGroup = 'Auto-Growth',
		CheckSubGroup = 'Possibly Warnings',
		DatabaseName = database_name,
		Details = details+ '('+CONVERT(VARCHAR(10),growth)+').',
		Details2 = NULL,
		Comment = NULL,
		Type = 2 
	FROM cte_AutoGrowt WITH (NOLOCK)
	WHERE details IS NOT NULL



	/********** Databases - Size Growth Trend ***************/ RAISERROR('Databases - Size Growth Trend processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..#uns_BackupSize') IS NOT NULL DROP TABLE #uns_BackupSize;
	SELECT 
		database_name,
		BackupDate = CONVERT(DATE,backup_start_date),
		BackupSize_MB = CONVERT(DECIMAL(18,2),ROUND(AVG([backup_size]/1024/1024),4)),
		CompressedBackupSize_MB = CONVERT(DECIMAL(18,2),ROUND(AVG([compressed_backup_size]/1024/1024),4))
	INTO #uns_BackupSize
	FROM msdb.dbo.backupset
	WHERE 
		[type] = 'D'
		AND backup_start_date BETWEEN DATEADD(DAY, - 31, GETDATE()) AND GETDATE()
	GROUP BY 
		[database_name],
		CONVERT(DATE,backup_start_date)

	;WITH CTE AS (
	SELECT 
		database_name,
		MaxBackupDate = MAX(BackupDate),
		MinBackupDate = MIN(BackupDate)
	FROM #uns_BackupSize ubs
	GROUP BY database_name)
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder=120,
		CheckGroup='Databases',
		CheckSubGroup='Database growth according to taken backups',
		DatabaseName = c.database_name,
		Details = 'In '+CONVERT(VARCHAR(10),DATEDIFF(DAY,c.MinBackupDate,c.MaxBackupDate))+' days the database growth ratio is : '
		+CONVERT(VARCHAR(100),(CONVERT(DECIMAL(18,4),((Maxubs.BackupSize_MB-Minubs.BackupSize_MB)/Minubs.BackupSize_MB))*100))
		+'[br]First Date Backup Size : '+CONVERT(VARCHAR(100),Minubs.BackupSize_MB)
		+'[br]Last Date Backup Size : '+CONVERT(VARCHAR(100),Maxubs.BackupSize_MB),
		Type = 0
	FROM CTE c
	INNER JOIN #uns_BackupSize Maxubs ON c.MaxBackupDate=Maxubs.BackupDate AND c.database_name=Maxubs.database_name
	INNER JOIN #uns_BackupSize Minubs ON c.MinBackupDate=Minubs.BackupDate AND c.database_name=Minubs.database_name
	ORDER BY 1,2



	/********** Database Files - Too much free space ***************/ RAISERROR('Database Files - Too much free space processing...',0,1) WITH NOWAIT;
	/********** Database Files - Log File Bigger Than 4/1 Data File***************/ RAISERROR('Database Files - Log File Bigger Than 4/1 Data File processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_DatabaseFiles') IS NOT NULL DROP TABLE ##uns_DatabaseFiles;
	CREATE TABLE ##uns_DatabaseFiles (DatabaseName VARCHAR(255), FileName VARCHAR(255),type_desc VARCHAR(255),size_on_disk_mb DECIMAL(18,2),free_size_mb DECIMAL(18,2))
    EXEC sys.sp_MSforeachdb N'
	USE [?]
	IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
	INSERT INTO ##uns_DatabaseFiles (DatabaseName, FileName, type_desc, size_on_disk_mb, free_size_mb)
	SELECT	
		DatabaseName = DB_NAME(database_id),
		FileName = name,
		type_desc,
		size_on_disk_mb = CAST((size*1.0/128) AS DECIMAL(18, 2)),
		free_size_mb = CAST((size*1.0/128) AS DECIMAL(18, 2))-CAST((FILEPROPERTY(name, ''SpaceUsed'')/128.0) AS DECIMAL(18,2))
	FROM sys.master_files
	WHERE DB_NAME(database_id) = ''?''';
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder=140,
		CheckGroup='Database Files',
		CheckSubGroup='Too much free space',
		DatabaseName,
		Details = 'File Size (MB) : '+CONVERT(VARCHAR(100),size_on_disk_mb)+'[br]Free Size (MB) : '+CONVERT(VARCHAR(100),free_size_mb),
		Type = 3
	FROM ##uns_DatabaseFiles
	WHERE 
		type_desc='ROWS'
		AND size_on_disk_mb>1000
		AND (size_on_disk_mb/4)*1<free_size_mb
	UNION
	SELECT
		unsOrder=142,
		CheckGroup='Database Files',
		CheckSubGroup='Log File Bigger Than 4/1 Data File',
		rs.DatabaseName,
		Details = 'File Size (MB) : '+CONVERT(VARCHAR(100),SUM(rs.size_on_disk_mb))+'[br]Log File Size (MB) : '+CONVERT(VARCHAR(100),SUM(ls.size_on_disk_mb)),
		Type = 3
	FROM ##uns_DatabaseFiles rs
	JOIN ##uns_DatabaseFiles ls ON rs.DatabaseName=ls.DatabaseName
	WHERE 
		ls.type_desc='LOG' 
		AND rs.type_desc='ROWS'
		AND rs.size_on_disk_mb>1000
		AND ls.size_on_disk_mb>1000
	GROUP BY rs.DatabaseName,rs.type_desc,ls.type_desc
	HAVING SUM(ls.size_on_disk_mb)>(SUM(rs.size_on_disk_mb)/4)*2


	/********** Log File - Count ***************/ RAISERROR('Database File Configurations - Log File Count processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder = 144,
		CheckGroup = 'Database File Configurations',
		CheckSubGroup = 'Log File Count',
		DatabaseName = DB_NAME(database_id),
		Details = 'Database has '+CONVERT(varchar(10),COUNT(1))+' log files. Log file is sequential, no need multiple log files.',
		Type = 2
	FROM sys.master_files 
	WHERE type=1 
	GROUP BY DB_NAME(database_id)
	HAVING COUNT(1)>1



	/********** Virtual Log File ***************/ RAISERROR('Virtual Log File processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..#VLFInfo') IS NOT NULL
		DROP TABLE #VLFInfo;
	IF OBJECT_ID('tempdb..#VLFCountResults') IS NOT NULL
		DROP TABLE #VLFCountResults;
	CREATE TABLE #VLFInfo (RecoveryUnitID int, FileID  int,
						   FileSize bigint, StartOffset bigint,
						   FSeqNo      bigint, [Status]    bigint,
						   Parity      bigint, CreateLSN   numeric(38));
	 
	CREATE TABLE #VLFCountResults(DatabaseName sysname, VLFCount int);
	 
	EXEC sp_MSforeachdb N'Use [?]; 

					INSERT INTO #VLFInfo 
					EXEC sp_executesql N''DBCC LOGINFO([?])''; 
	 
					INSERT INTO #VLFCountResults 
					SELECT DB_NAME(), COUNT(*) 
					FROM #VLFInfo; 

					TRUNCATE TABLE #VLFInfo;'

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)
	SELECT 
		unsOrder = 170, 
		CheckGroup = 'Virtual Log File',
		CheckSubGroup = 'VLF count info',
		DatabaseName,
		Details = 'VLF Count : '+ CONVERT(VARCHAR(100),VLFCount),
		Details2 = NULL,
		Type = CASE WHEN VLFCount>1000 THEN 3 ELSE 1 END
	FROM #VLFCountResults 
	ORDER BY DatabaseName



	/********** Memory - SQL Server Memory ************** RAISERROR('Memory - SQL Server Memory processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)
	SELECT 
		unsOrder = 100, 
		CheckGroup = 'Memory',
		CheckSubGroup = 'SQL Server Memory',
		DatabaseName = NULL,
		Details = 'SQL Server Memory Usage (MB) : '+CONVERT(VARCHAR(100),(physical_memory_in_use_kb/1024))+' ,Memory Utilizastion (%) : '+CONVERT(VARCHAR(100),memory_utilization_percentage),
		Details2 = 'Lock Pages (MB) : '+CONVERT(VARCHAR(100),(locked_page_allocations_kb/1024)),
		Type = 0
	FROM sys.dm_os_process_memory WITH (NOLOCK) */
	


	/********** Memory - OS Memory Performance ************** RAISERROR('Memory - OS Memory Performance processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)
	SELECT 
		unsOrder = 110, 
		CheckGroup = 'Memory',
		CheckSubGroup = 'OS Memory Performance',
		DatabaseName = NULL,
		Details = 'Physical Memory (MB) : '+CONVERT(VARCHAR(100),(total_physical_memory_kb/1024)),
		Details2 = 'system_memory_state_desc : '+system_memory_state_desc,
		Type = 0
	FROM sys.dm_os_sys_memory WITH (NOLOCK) 
	*/


	/********** Worker Info - CPU or Disk Performance ************** RAISERROR('Worker Info - CPU or Disk Performance processing...',0,1) WITH NOWAIT;
		IF OBJECT_ID('tempdb..#temp_Scheduler') IS NOT NULL
			DROP TABLE #temp_Scheduler;
		SELECT 
			AVG(current_tasks_count) current_tasks_count, 
			AVG(work_queue_count) work_queue_count,
			AVG(runnable_tasks_count) runnable_tasks_count,
			AVG(pending_disk_io_count) pending_disk_io_count
		INTO #temp_Scheduler
		FROM sys.dm_os_schedulers WITH (NOLOCK)
		WHERE scheduler_id < 255

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT 
		unsOrder = 120, 
		CheckGroup = 'Worker Info',
		CheckSubGroup = 'CPU or Disk Performance',
		DatabaseName = NULL,
		Details =  'runnable_tasks_count : '+CONVERT(VARCHAR(100),[runnable_tasks_count])+', pending_disk_io_count : '+CONVERT(VARCHAR(100),[pending_disk_io_count])+', current_tasks_count : '+CONVERT(VARCHAR(100),[current_tasks_count])+', work_queue_count : '+CONVERT(VARCHAR(100),[work_queue_count]),
		Type = CASE 
			WHEN (runnable_tasks_count>3 OR pending_disk_io_count>3) 
			THEN 3 ELSE 0 END
	FROM #temp_Scheduler
	*/



	/********** Disk Info ***************/ RAISERROR('Disk Info processing...',0,1) WITH NOWAIT;
	;WITH cte_DiskInfo
	AS (
		SELECT 
			tab.volume_mount_point,
			tab.total_bytes_gb,
			tab.available_bytes_gb,
			tab.free_size_percent,
			ReadLatency = CASE WHEN num_of_reads = 0 THEN 0 ELSE (io_stall_read_ms/num_of_reads) END,
			WriteLatency = CASE WHEN num_of_writes = 0 THEN 0 ELSE (io_stall_write_ms/num_of_writes) END,
			Latency = CASE WHEN (num_of_reads = 0 AND num_of_writes = 0) THEN 0 ELSE (io_stall/(num_of_reads + num_of_writes)) END
		FROM (
				SELECT 
					SUM(num_of_reads) AS num_of_reads,
					SUM(io_stall_read_ms) AS io_stall_read_ms, 
					SUM(num_of_writes) AS num_of_writes,
					SUM(io_stall_write_ms) AS io_stall_write_ms, 
					SUM(num_of_bytes_read) AS num_of_bytes_read,
					SUM(num_of_bytes_written) AS num_of_bytes_written, 
					SUM(io_stall) AS io_stall, 
					MAX(vs.volume_mount_point) as volume_mount_point,
					MAX(vs.total_bytes)/1024/1024/1024 as total_bytes_gb,
					MAX(vs.available_bytes)/1024/1024/1024 as available_bytes_gb,
					CAST(MAX(vs.available_bytes) * 100.0 / MAX(vs.total_bytes) AS DECIMAL(5, 2)) as free_size_percent
				FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
					INNER JOIN sys.master_files AS mf WITH (NOLOCK)
					ON vfs.database_id = mf.database_id AND vfs.file_id = mf.file_id
					CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.[file_id]) AS vs 
					GROUP BY vs.volume_mount_point
			) AS tab
	)
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,Details,Type)
	SELECT 
		DISTINCT 
		unsOrder = 200, 
		CheckGroup = 'Disk',
		CheckSubGroup = 'Size',
		Details = '<b>Disk Letter:</b> '+volume_mount_point+'[br][br]<b>Size (GB):</b> '+CONVERT(VARCHAR(100),total_bytes_gb)+'[br][br]<b>Free Size (GB):</b> '+CONVERT(VARCHAR(100),available_bytes_gb)+
		' (%'+CONVERT(VARCHAR(10),free_size_percent)+')',
		Type = CASE WHEN free_size_percent<5 THEN 3 WHEN free_size_percent BETWEEN 5 AND 20 THEN 2 WHEN free_size_percent>20 THEN 1 ELSE NULL END
	FROM cte_DiskInfo
	UNION
	SELECT 
		DISTINCT 
		unsOrder = 210, 
		CheckGroup = 'Disk',
		CheckSubGroup = 'Latency',
		Details = '<b>Disk Letter:</b> '+volume_mount_point+'[br][br]<b>ReadLatency:</b> '+CONVERT(VARCHAR(100),ReadLatency)+'[br][br]<b>WriteLatency:</b> '+CONVERT(VARCHAR(100),WriteLatency)+'[br][br]<b>Latency:</b> '+CONVERT(VARCHAR(100),Latency),
		Type = CASE WHEN Latency>100 THEN 3 WHEN Latency BETWEEN 50 AND 100 THEN 2 ELSE 0 END
	FROM cte_DiskInfo



	/********** Wait Type ***************/ RAISERROR('Wait Type processing...',0,1) WITH NOWAIT;
	-- This is Paul White Script
	;WITH [Waits] AS
		(SELECT
			[wait_type],
			[wait_time_ms] / 1000 AS [WaitS],
			([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
			[signal_wait_time_ms] / 1000.0 AS [SignalS],
			[waiting_tasks_count] AS [WaitCount],
			100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
			ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
		FROM sys.dm_os_wait_stats WITH (NOLOCK)
		WHERE [wait_type] NOT IN (
			-- These wait types are almost 100% never a problem and so they are
			-- filtered out to avoid them skewing the results. Click on the URL
			-- for more information.
			N'BROKER_EVENTHANDLER', -- https://www.sqlskills.com/help/waits/BROKER_EVENTHANDLER
			N'BROKER_RECEIVE_WAITFOR', -- https://www.sqlskills.com/help/waits/BROKER_RECEIVE_WAITFOR
			N'BROKER_TASK_STOP', -- https://www.sqlskills.com/help/waits/BROKER_TASK_STOP
			N'BROKER_TO_FLUSH', -- https://www.sqlskills.com/help/waits/BROKER_TO_FLUSH
			N'BROKER_TRANSMITTER', -- https://www.sqlskills.com/help/waits/BROKER_TRANSMITTER
			N'CHECKPOINT_QUEUE', -- https://www.sqlskills.com/help/waits/CHECKPOINT_QUEUE
			N'CHKPT', -- https://www.sqlskills.com/help/waits/CHKPT
			N'CLR_AUTO_EVENT', -- https://www.sqlskills.com/help/waits/CLR_AUTO_EVENT
			N'CLR_MANUAL_EVENT', -- https://www.sqlskills.com/help/waits/CLR_MANUAL_EVENT
			N'CLR_SEMAPHORE', -- https://www.sqlskills.com/help/waits/CLR_SEMAPHORE
			N'CXCONSUMER', -- https://www.sqlskills.com/help/waits/CXCONSUMER
 
			-- Maybe comment these four out if you have mirroring issues
			N'DBMIRROR_DBM_EVENT', -- https://www.sqlskills.com/help/waits/DBMIRROR_DBM_EVENT
			N'DBMIRROR_EVENTS_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_EVENTS_QUEUE
			N'DBMIRROR_WORKER_QUEUE', -- https://www.sqlskills.com/help/waits/DBMIRROR_WORKER_QUEUE
			N'DBMIRRORING_CMD', -- https://www.sqlskills.com/help/waits/DBMIRRORING_CMD
 
			N'DIRTY_PAGE_POLL', -- https://www.sqlskills.com/help/waits/DIRTY_PAGE_POLL
			N'DISPATCHER_QUEUE_SEMAPHORE', -- https://www.sqlskills.com/help/waits/DISPATCHER_QUEUE_SEMAPHORE
			N'EXECSYNC', -- https://www.sqlskills.com/help/waits/EXECSYNC
			N'FSAGENT', -- https://www.sqlskills.com/help/waits/FSAGENT
			N'FT_IFTS_SCHEDULER_IDLE_WAIT', -- https://www.sqlskills.com/help/waits/FT_IFTS_SCHEDULER_IDLE_WAIT
			N'FT_IFTSHC_MUTEX', -- https://www.sqlskills.com/help/waits/FT_IFTSHC_MUTEX
 
			-- Maybe comment these six out if you have AG issues
			N'HADR_CLUSAPI_CALL', -- https://www.sqlskills.com/help/waits/HADR_CLUSAPI_CALL
			N'HADR_FILESTREAM_IOMGR_IOCOMPLETION', -- https://www.sqlskills.com/help/waits/HADR_FILESTREAM_IOMGR_IOCOMPLETION
			N'HADR_LOGCAPTURE_WAIT', -- https://www.sqlskills.com/help/waits/HADR_LOGCAPTURE_WAIT
			N'HADR_NOTIFICATION_DEQUEUE', -- https://www.sqlskills.com/help/waits/HADR_NOTIFICATION_DEQUEUE
			N'HADR_TIMER_TASK', -- https://www.sqlskills.com/help/waits/HADR_TIMER_TASK
			N'HADR_WORK_QUEUE', -- https://www.sqlskills.com/help/waits/HADR_WORK_QUEUE
 
			N'KSOURCE_WAKEUP', -- https://www.sqlskills.com/help/waits/KSOURCE_WAKEUP
			N'LAZYWRITER_SLEEP', -- https://www.sqlskills.com/help/waits/LAZYWRITER_SLEEP
			N'LOGMGR_QUEUE', -- https://www.sqlskills.com/help/waits/LOGMGR_QUEUE
			N'MEMORY_ALLOCATION_EXT', -- https://www.sqlskills.com/help/waits/MEMORY_ALLOCATION_EXT
			N'ONDEMAND_TASK_QUEUE', -- https://www.sqlskills.com/help/waits/ONDEMAND_TASK_QUEUE
			N'PARALLEL_REDO_DRAIN_WORKER', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_DRAIN_WORKER
			N'PARALLEL_REDO_LOG_CACHE', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_LOG_CACHE
			N'PARALLEL_REDO_TRAN_LIST', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_TRAN_LIST
			N'PARALLEL_REDO_WORKER_SYNC', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_SYNC
			N'PARALLEL_REDO_WORKER_WAIT_WORK', -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_WAIT_WORK
			N'PREEMPTIVE_XE_GETTARGETSTATE', -- https://www.sqlskills.com/help/waits/PREEMPTIVE_XE_GETTARGETSTATE
			N'PWAIT_ALL_COMPONENTS_INITIALIZED', -- https://www.sqlskills.com/help/waits/PWAIT_ALL_COMPONENTS_INITIALIZED
			N'PWAIT_DIRECTLOGCONSUMER_GETNEXT', -- https://www.sqlskills.com/help/waits/PWAIT_DIRECTLOGCONSUMER_GETNEXT
			N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP', -- https://www.sqlskills.com/help/waits/QDS_PERSIST_TASK_MAIN_LOOP_SLEEP
			N'QDS_ASYNC_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_ASYNC_QUEUE
			N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP',
				-- https://www.sqlskills.com/help/waits/QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP
			N'QDS_SHUTDOWN_QUEUE', -- https://www.sqlskills.com/help/waits/QDS_SHUTDOWN_QUEUE
			N'REDO_THREAD_PENDING_WORK', -- https://www.sqlskills.com/help/waits/REDO_THREAD_PENDING_WORK
			N'REQUEST_FOR_DEADLOCK_SEARCH', -- https://www.sqlskills.com/help/waits/REQUEST_FOR_DEADLOCK_SEARCH
			N'RESOURCE_QUEUE', -- https://www.sqlskills.com/help/waits/RESOURCE_QUEUE
			N'SERVER_IDLE_CHECK', -- https://www.sqlskills.com/help/waits/SERVER_IDLE_CHECK
			N'SLEEP_BPOOL_FLUSH', -- https://www.sqlskills.com/help/waits/SLEEP_BPOOL_FLUSH
			N'SLEEP_DBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DBSTARTUP
			N'SLEEP_DCOMSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_DCOMSTARTUP
			N'SLEEP_MASTERDBREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERDBREADY
			N'SLEEP_MASTERMDREADY', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERMDREADY
			N'SLEEP_MASTERUPGRADED', -- https://www.sqlskills.com/help/waits/SLEEP_MASTERUPGRADED
			N'SLEEP_MSDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_MSDBSTARTUP
			N'SLEEP_SYSTEMTASK', -- https://www.sqlskills.com/help/waits/SLEEP_SYSTEMTASK
			N'SLEEP_TASK', -- https://www.sqlskills.com/help/waits/SLEEP_TASK
			N'SLEEP_TEMPDBSTARTUP', -- https://www.sqlskills.com/help/waits/SLEEP_TEMPDBSTARTUP
			N'SNI_HTTP_ACCEPT', -- https://www.sqlskills.com/help/waits/SNI_HTTP_ACCEPT
			N'SOS_WORK_DISPATCHER', -- https://www.sqlskills.com/help/waits/SOS_WORK_DISPATCHER
			N'SP_SERVER_DIAGNOSTICS_SLEEP', -- https://www.sqlskills.com/help/waits/SP_SERVER_DIAGNOSTICS_SLEEP
			N'SQLTRACE_BUFFER_FLUSH', -- https://www.sqlskills.com/help/waits/SQLTRACE_BUFFER_FLUSH
			N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP', -- https://www.sqlskills.com/help/waits/SQLTRACE_INCREMENTAL_FLUSH_SLEEP
			N'SQLTRACE_WAIT_ENTRIES', -- https://www.sqlskills.com/help/waits/SQLTRACE_WAIT_ENTRIES
			N'WAIT_FOR_RESULTS', -- https://www.sqlskills.com/help/waits/WAIT_FOR_RESULTS
			N'WAITFOR', -- https://www.sqlskills.com/help/waits/WAITFOR
			N'WAITFOR_TASKSHUTDOWN', -- https://www.sqlskills.com/help/waits/WAITFOR_TASKSHUTDOWN
			N'WAIT_XTP_RECOVERY', -- https://www.sqlskills.com/help/waits/WAIT_XTP_RECOVERY
			N'WAIT_XTP_HOST_WAIT', -- https://www.sqlskills.com/help/waits/WAIT_XTP_HOST_WAIT
			N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG', -- https://www.sqlskills.com/help/waits/WAIT_XTP_OFFLINE_CKPT_NEW_LOG
			N'WAIT_XTP_CKPT_CLOSE', -- https://www.sqlskills.com/help/waits/WAIT_XTP_CKPT_CLOSE
			N'XE_DISPATCHER_JOIN', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_JOIN
			N'XE_DISPATCHER_WAIT', -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_WAIT
			N'XE_TIMER_EVENT' -- https://www.sqlskills.com/help/waits/XE_TIMER_EVENT
			)
		AND [waiting_tasks_count] > 0
		)
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,Details,Type)
	SELECT 
		TOP 5 
		unsOrder = 300, 
		CheckGroup = 'Performance',
		CheckSubGroup = 'Wait Types',
		Details = [W1].[wait_type]+' - '+CONVERT(varchar, DATEADD(ms, [W1].[WaitS], 0), 114)+' wait has been detected. '
		+'Percent : '+CONVERT(VARCHAR(100),CAST([W1].[Percentage] AS DECIMAL (16,2))),
		Type = 2
		--CAST ('https://www.sqlskills.com/help/waits/' + MAX ([W1].[wait_type]) as XML) AS [Help/Info URL]
	FROM [Waits] AS [W1]
	ORDER BY RowNum -- percentage threshold


	/********** Index Definition - Fill Factor ***************/ RAISERROR('Index Definition - Fill Factor processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_FillFactorGroupCounts') IS NOT NULL DROP TABLE ##uns_FillFactorGroupCounts;
	CREATE TABLE ##uns_FillFactorGroupCounts (DatabaseName VARCHAR(255), FillFactorValue INT, [Count] INT)
	EXEC sp_MSforeachdb '
	USE [?]
	IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
	INSERT INTO ##uns_FillFactorGroupCounts (DatabaseName,FillFactorValue,[Count])
	SELECT 
		DatabaseName = ''?'',
		fill_factor,
		Count = COUNT(1)
	FROM sys.indexes
	WHERE fill_factor BETWEEN 1 AND 80 
	GROUP BY fill_factor'
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder=400,
		CheckGroup='Index Definition',
		CheckSubGroup='Fill Factor',
		DatabaseName,
		Details = CONVERT(varchar(10),[Count])+' indexes fill factor is : '+CONVERT(varchar(10),FillFactorValue),
		Type = 2
	FROM ##uns_FillFactorGroupCounts



	/********** Index Definition - Heap Table ***************/ RAISERROR('Index Definition - Heap Table processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_HeapTableCounts') IS NOT NULL DROP TABLE ##uns_HeapTableCounts;
	CREATE TABLE ##uns_HeapTableCounts (DatabaseName VARCHAR(255), [Count] INT)
	EXEC sp_MSforeachdb '
	USE [?]
	IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
	INSERT INTO ##uns_HeapTableCounts (DatabaseName,[Count])
	SELECT   
		DatabaseName = ''?'',
		Count = COUNT(o.name) 
	FROM sys.indexes i WITH (NOLOCK)
	INNER JOIN sys.objects o WITH (NOLOCK) ON  i.object_id = o.object_id
	WHERE o.type_desc = ''USER_TABLE'' AND i.type_desc = ''HEAP'''
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder=402,
		CheckGroup='Index Definition',
		CheckSubGroup='Heap Table',
		DatabaseName,
		Details = 'Database has '+CONVERT(varchar(10),[Count])+' heap table(s).',
		Type = 2
	FROM ##uns_HeapTableCounts
	WHERE [Count]>0


	/********** Index Definition - Non-Indexed ForeignKeys ***************/ RAISERROR('Index Definition - Non-Indexed ForeignKeys processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_NonIndexedForeignKeys') IS NOT NULL DROP TABLE ##uns_NonIndexedForeignKeys;
	CREATE TABLE ##uns_NonIndexedForeignKeys (DatabaseName VARCHAR(1000), ObjectName VARCHAR(1000), ColumnName VARCHAR(1000))
	EXEC sp_MSforeachdb '
	USE [?]
	IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
	BEGIN
	;WITH CTE AS (
	SELECT 
		DatabaseName = ''?'',
		OjbectName = Object_Name(a.parent_object_id),
		ColumnName = b.NAME
	FROM sys.foreign_key_columns a
	INNER JOIN sys.all_columns b ON a.parent_column_id = b.column_id AND a.parent_object_id = b.object_id
	INNER JOIN sys.objects c ON b.object_id = c.object_id
	WHERE c.is_ms_shipped = 0

	EXCEPT

	SELECT 
		DatabaseName = ''?'',
		OjbectName = Object_name(a.Object_id),
		ColumnName = b.NAME
	FROM sys.index_columns a
	INNER JOIN sys.all_columns b ON  a.object_id = b.object_id AND a.column_id = b.column_id
	INNER JOIN sys.objects c ON a.object_id = c.object_id
	WHERE  
		a.key_ordinal = 1
		AND c.is_ms_shipped = 0)
	INSERT INTO ##uns_NonIndexedForeignKeys
	SELECT * FROM CTE
	END'
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		TOP 50 
		unsOrder=404,
		CheckGroup='Index Definition',
		CheckSubGroup='Non-Indexed ForeignKeys',
		DatabaseName,
		Details = 'There are '+CONVERT(VARCHAR(10),COUNT(1))+' Non-Indexed Foreing key(s)',
		Type = 2
	FROM ##uns_NonIndexedForeignKeys
	GROUP BY DatabaseName


	/********** Index Definition - Lock Option ***************/ RAISERROR('Index Definition - Lock Option..',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_IndexLockOption') IS NOT NULL DROP TABLE ##uns_IndexLockOption;
	CREATE TABLE ##uns_IndexLockOption (DatabaseName VARCHAR(255), [Count] INT)
	EXEC sp_MSforeachdb '
	USE [?]
	IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
	INSERT INTO ##uns_IndexLockOption (DatabaseName,[Count])

	SELECT DatabaseName = ''?'',[Count] = count(1) 
	FROM sys.indexes i 
	INNER JOIN sys.tables t on i.object_id=t.object_id
	WHERE i.type not in (0,5,6) and (i.allow_page_locks=0 or i.allow_row_locks=0)'

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
		SELECT
			unsOrder=407,
			CheckGroup='Index Definition',
			CheckSubGroup='Indexes Lock Options',
			DatabaseName,
			Details = 'Database has '+CONVERT(varchar(10),[Count])+' [PageLock] or [RowLock] Index(es)',
			Type = 2
		FROM ##uns_IndexLockOption
		WHERE [Count]!=0


	/********** Table Configurations - Table nvarchar/varchar Max Columns ***************/ RAISERROR('Table Configurations - Table nvarchar/varchar Max Columns ..',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_TableColumnsLenghtMAX') IS NOT NULL DROP TABLE ##uns_TableColumnsLenghtMAX;
	CREATE TABLE ##uns_TableColumnsLenghtMAX (DatabaseName VARCHAR(255), [Count] INT)
	EXEC sp_MSforeachdb '
	USE [?]
	IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
	INSERT INTO ##uns_TableColumnsLenghtMAX (DatabaseName,[Count])
	SELECT DatabaseName =''?'',[Count] = count(1) 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE DATA_TYPE in (''nvarchar'',''varchar'')
	AND CHARACTER_MAXIMUM_LENGTH=-1'

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder=409,
		CheckGroup='Table Configurations',
		CheckSubGroup='Table nvarchar/varchar Max Columns',
		DatabaseName,
		Details = 'Database has '+CONVERT(varchar(10),[Count])+'  (n)varchar max column(s)',
		Type = 2
	FROM ##uns_TableColumnsLenghtMAX
	WHERE [Count]!=0



	/********** Table Configurations - Identity INT column max value ***************/ RAISERROR('Table Configurations - Identity INT column max value ..',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_IdentityColumns') IS NOT NULL DROP TABLE ##uns_IdentityColumns;
	CREATE TABLE ##uns_IdentityColumns (DatabaseName VARCHAR(255), TableName varchar(max), ColumnName varchar(max), CurrentIdentityValue bigint)

	EXEC sys.sp_MSforeachdb N'
		USE [?]
		IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
		INSERT INTO ##uns_IdentityColumns (DatabaseName,TableName,ColumnName,CurrentIdentityValue)
		SELECT 
			DatabaseName = N''?'' ,
			TableName = b.name,
			ColumnName = a.name,
			CurrentIdentityValue = CONVERT(bigint,last_value)
		FROM sys.identity_columns a 
		INNER JOIN sys.tables b ON a.object_id=b.object_id
			WHERE a.system_type_id !=127;';

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder=411,
		CheckGroup='Table Configurations',
		CheckSubGroup='Identity INT column max value',
		DatabaseName,
		Details = '<b>Table:</b> '+CONVERT(VARCHAR(500),TableName)+'[br][br]<b>Column:</b> '+CONVERT(VARCHAR(500),ColumnName)+'[br][br]<b>CurrentIdentityValue:</b> '+CONVERT(VARCHAR(500),CurrentIdentityValue)+'[br][br]<b>PercentOfMaxValueSize:</b> '+CONVERT(VARCHAR(500),CONVERT(bigint,CurrentIdentityValue)*100.00/2147483648),
		Type = 3
	FROM ##uns_IdentityColumns
	WHERE Convert(bigint,CurrentIdentityValue)*100/2147483648 > 75  



	/********** Backup Info ***************/ RAISERROR('Backup Info processing...',0,1) WITH NOWAIT;
		IF OBJECT_ID('tempdb..#tmp_BackupDetails') IS NOT NULL
		DROP TABLE #tmp_BackupDetails;
		SELECT  
			d.database_id,
			[database_name] = d.name, 
			[last_backup_date] = (MAX(backup_finish_date)),
			backup_size_mb=CAST(COALESCE(MAX(bs.backup_size),0)/1024.00/1024.00 AS NUMERIC(18,2)),
			avg_backup_duration_sec= AVG(CAST(DATEDIFF(s, bs.backup_start_date, bs.backup_finish_date) AS int)),
			bs.type
			INTO #tmp_BackupDetails
		FROM sys.databases d WITH (NOLOCK) 
		LEFT JOIN msdb.dbo.backupset bs WITH (NOLOCK) 
				ON bs.database_name = d.name 
					AND bs.is_copy_only = 0
			WHERE d.name NOT IN ('tempdb','distribution','model') AND d.state=0
		GROUP BY d.database_id,d.Name, bs.type

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)
	SELECT 
		unsOrder = 
			CASE WHEN type='D' THEN 500
			WHEN type='L' THEN 510
			WHEN type IS NULL THEN 520 END ,
		CheckGroup = 'Backup',
		CheckSubGroup = 
			CASE WHEN type='D' THEN 'Full Backup Operations' 
			WHEN type='L' THEN 'Log Backup Operations' 
			WHEN type IS NULL THEN 'Warning Backup Operations' END ,
		DatabaseName = [database_name] ,
		Details=
			CASE 
				WHEN last_backup_date > GETDATE()-3 AND type='D' THEN 'Last FULL Backup : '+CONVERT(VARCHAR(100),last_backup_date,120) 
				WHEN last_backup_date IS NULL THEN '! there is no FULL backup.'
				WHEN last_backup_date < GETDATE()-3 AND type='D' THEN '! there is no FULL backup in last three days.[br]Last FULL Backup : '+CONVERT(VARCHAR(100),last_backup_date,120) 
				WHEN last_backup_date > GETDATE()-1 AND type='L' THEN 'Last LOG Backup : '+CONVERT(VARCHAR(100),last_backup_date,120)
				WHEN last_backup_date IS NULL AND type='L' THEN '! there is no LOG backup'
				WHEN last_backup_date < GETDATE()-1 AND type='L' THEN '! there is no LOG backup in last day[br]Last LOG Backup : '+CONVERT(VARCHAR(100),last_backup_date,120)
			END,
		Details2 = 'Last backup taken '+CAST(backup_size_mb AS VARCHAR(20))+' MB in '+CAST(avg_backup_duration_sec AS VARCHAR(20))+' second(s).',
		Type = 
			CASE 
				WHEN last_backup_date > GETDATE()-3 AND type='D' THEN 1
				WHEN last_backup_date IS NULL THEN 3
				WHEN last_backup_date < GETDATE()-3 AND type='D' THEN 2
				WHEN last_backup_date > GETDATE()-1 AND type='L' THEN 1
				WHEN last_backup_date IS NULL AND type='L' THEN 3
				WHEN last_backup_date < GETDATE()-1 AND type='L' THEN 2
			END
	FROM #tmp_BackupDetails 
	ORDER BY database_id

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT 530 unsOrder, 'Backup' CheckGroup,'FULL Recovery Model & Log Backup Operations' CheckSubGroup,d.name DatabaseName,
	'Database recovery model is FULL but no LOG backup. ' Details,3
	FROM sys.databases d WITH (NOLOCK) WHERE database_id NOT IN (SELECT database_id FROM #tmp_BackupDetails WHERE type='L')
	AND d.recovery_model=1 AND d.state=0 AND d.database_id!=3





	/********** Data Corruption - Suspect Pages ***************/ RAISERROR('Data Corruption - Suspect Pages processing...',0,1) WITH NOWAIT;
	IF 0>(SELECT COUNT(1) FROM msdb.dbo.suspect_pages)
	BEGIN
		INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)
		SELECT 
			unsOrder = 600, 
			CheckGroup = 'Data Corruption',
			CheckSubGroup = 'Suspect Pages',
			DatabaseName = DB_NAME([database_id]),
			Details = 'Page : '+CONVERT(VARCHAR(100),[database_id])+':'+CONVERT(VARCHAR(100),[file_id])+':'+CONVERT(VARCHAR(100),[page_id]),
			Details2 = '' +
			CASE WHEN event_type = 1 THEN 'An 823 error that causes a suspect page (such as a disk error) or an 824 error other than a bad checksum or a torn page (such as a bad page ID).'
			WHEN event_type = 2 THEN 'Bad checksum.'
			WHEN event_type = 3 THEN 'Torn page.'
			WHEN event_type = 4 THEN 'Restored (page was restored after it was marked bad).'
			WHEN event_type = 5 THEN 'Repaired (DBCC repaired the page).'
			WHEN event_type = 7 THEN 'Deallocated by DBCC.' END +
			' Error Count : '+CONVERT(VARCHAR(100),[error_count])+ ' Last Update Date : '+CONVERT(VARCHAR(100),[last_update_date]),
			--Script eklenecek dbcc checkdb
			Type = 3
		FROM msdb.dbo.suspect_pages WITH (NOLOCK)
		ORDER BY database_id
	END
	ELSE
	BEGIN
		INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,Details,Type)
		VALUES (602,'Data Corruption','Suspect Pages','There is no suspect pages on [msdb].[dbo].[suspect_pages]',1)
	END



	/********** Data Integrity - Last Good Check DB ***************/ RAISERROR('Data Integrity - Last Good Check DB processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID(N'tempdb..#uns_LastCheckDBCC') IS NOT NULL BEGIN DROP TABLE #uns_LastCheckDBCC END
		CREATE TABLE #uns_LastCheckDBCC
		(DatabaseName varchar(100), IsOnline BIT, ParentObject varchar(100), [Object] varchar(100), [Field] varchar(100), [Value] varchar(100));

		DECLARE @cmd NVARCHAR(MAX);
		DECLARE @dbName SYSNAME;
		DECLARE @IsOnline BIT;

		DECLARE cur CURSOR LOCAL FORWARD_ONLY STATIC
		FOR
		SELECT DBCCCommand = 'DBCC DBINFO(''' + d.name + ''') WITH TABLERESULTS;', DatabaseName = d.name, IsOnline = CONVERT(BIT,CASE WHEN d.state_desc = 'ONLINE' THEN 1 ELSE 0 END)
		FROM sys.databases d
		WHERE database_id!=2
		ORDER BY d.name;

		OPEN cur;
		FETCH NEXT FROM cur INTO @cmd, @dbName, @IsOnline;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			RAISERROR (@dbName, 0, 1) WITH NOWAIT;
			IF @IsOnline = 1
			BEGIN
				INSERT INTO #uns_LastCheckDBCC (ParentObject, [Object], [Field], [Value])
				EXEC sp_executesql @cmd;
				UPDATE #uns_LastCheckDBCC 
				SET DatabaseName = @dbName
					, IsOnline = @IsOnline
				WHERE DatabaseName IS NULL;
			END
			ELSE
			BEGIN
				INSERT INTO #uns_LastCheckDBCC (DatabaseName, IsOnline)
				VALUES (@dbName, @IsOnline)
			END
			FETCH NEXT FROM cur INTO @cmd, @dbName, @IsOnline;
		END

		CLOSE cur;
		DEALLOCATE cur;

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT 
		unsOrder = 620, 
		CheckGroup = 'Data Integrity',
		CheckSubGroup = 'Last Good Check DB',
		DatabaseName = r.DatabaseName ,
		Details = 
			CASE 
				WHEN r.Value='1900-01-01 00:00:00.000' OR r.Value IS NULL THEN 'The database even not Check DBCC.' 
				ELSE 'Last Check DBCC : '+CONVERT(VARCHAR(100),r.Value,120) END,
		Type = CASE 
				WHEN r.Value>GETDATE()-7 THEN 1
				ELSE 2 END
	FROM #uns_LastCheckDBCC r
	WHERE r.Field = 'dbi_dbccLastKnownGood'
		OR r.Field IS NULL;



	/********** Login and User - sysadmin ***************/ RAISERROR('Login and User - sysadmin processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT
		unsOrder=650,
		CheckGroup='Login and User',
		CheckSubGroup='sysadmin',
		DatabaseName = NULL,
		Details=cast(COUNT(1) as nvarchar(20))+' login has sysadmin role.',
		Details2 = NULL,
		Comment = NULL,
		Type = 0
	FROM sys.syslogins sl WITH (NOLOCK)
	LEFT JOIN sys.server_principals sp WITH (NOLOCK) ON sl.name=sp.name
	WHERE sl.sysadmin=1 AND is_disabled=0
	


	/********** Login and User - Orphaned user ***************/ RAISERROR('Login and User - Orphaned user processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..##uns_Orphanedusers') IS NOT NULL DROP TABLE ##uns_Orphanedusers;
	CREATE TABLE ##uns_Orphanedusers (DatabaseName VARCHAR(255), [Count] INT)
	EXEC sp_MSforeachdb '
	USE [?]
	IF ''?'' <> ''master'' AND ''?'' <> ''model'' AND ''?'' <> ''msdb'' AND ''?'' <> ''tempdb''
	INSERT INTO ##uns_Orphanedusers (DatabaseName,[Count])

	SELECT DatabaseName = ''?'', Count = COUNT(1)
	FROM sys.database_principals AS dp  
	LEFT JOIN sys.server_principals AS sp  
		ON dp.sid = sp.sid  
	WHERE sp.sid IS NULL  
		AND authentication_type_desc != ''NONE'''
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Type)
	SELECT
		unsOrder=660,
		CheckGroup='Login and User',
		CheckSubGroup='Orphaned user',
		DatabaseName,
		Details = 'Database has '+CONVERT(varchar(10),[Count])+' Orphaned user(s)',
		Type = 2
	FROM ##uns_Orphanedusers
	WHERE [Count]!=0



	/********** CPU Info ***************/ RAISERROR('CPU Info processing...',0,1) WITH NOWAIT;
	/********** Performance Counters Info ***************/ RAISERROR('Performance Counters processing...',0,1) WITH NOWAIT;
	IF OBJECT_ID('tempdb..#temp_CPUInfo') IS NOT NULL
		DROP TABLE #temp_CPUInfo;
	DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)) 

	;WITH cte_CPUInfo
	AS (
	SELECT TOP(256) SQLProcessUtilization AS [SQLServerProcessCPUUtilization], 
				   100 - SystemIdle - SQLProcessUtilization AS [OtherProcessCPUUtilization]
	FROM (SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
				AS [SystemIdle], 
				record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') 
				AS [SQLProcessUtilization], [timestamp] 
		  FROM (SELECT [timestamp], CONVERT(xml, record) AS [record] 
				FROM sys.dm_os_ring_buffers WITH (NOLOCK)
				WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
				AND record LIKE N'%<SystemHealth>%') AS x) AS y )

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Type)
	SELECT 
		unsOrder = 700, 
		CheckGroup = 'Counters',
		CheckSubGroup = 'Performance',
		DatabaseName = NULL,
		Details = 'SQL Server Process CPU Utilization : '+CONVERT(VARCHAR(100),AVG([SQLServerProcessCPUUtilization])),
		Details2 = ' Other Process CPU Utilization : '+CONVERT(VARCHAR(100),AVG([OtherProcessCPUUtilization])),
		Type = 0
	FROM cte_CPUInfo
	UNION
	SELECT 
		unsOrder = 700, 
		CheckGroup = 'Counters',
		CheckSubGroup = 'Performance',
		DatabaseName = NULL,
		Details = counter_name+': '+CONVERT(VARCHAR(100),[cntr_value]),
		Details2 = NULL,
		Type = 0
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE instance_name IN ('', '_Total') AND cntr_type != 272696576
		AND counter_name IN
		('Total Server Memory (KB)','Target Server Memory (KB)','Memory Grants Pending','Page life expectancy','Buffer cache hit ratio','Average Wait Time (ms)','Active Temp Tables','User Connections','Lock Wait Time (ms)','Average Wait Time (ms)','Free Memory (KB)')
	OPTION (RECOMPILE)




	/********** Lock Info - Deadlock ***************/ RAISERROR('Lock Info - Deadlock processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT 
		unsOrder = 750, 
		CheckGroup = 'Lock Info',
		CheckSubGroup = 'Deadlock',
		DatabaseName = NULL,
		Details = 'Number of Deadlocks : '+CONVERT(VARCHAR(100),cntr_value),
		Details2 = NULL,
		Comment = NULL,
		Type = 3
	FROM sys.dm_os_performance_counters WITH (NOLOCK)
	WHERE counter_name = 'Number of Deadlocks/sec' AND instance_name = '_Total' AND cntr_value>0




	/********** Jobs - Failed,Retry,Canceled ***************/ RAISERROR('Jobs - Failed,Retry,Canceled processing...',0,1) WITH NOWAIT;
	;WITH cte_Jobs AS (
	SELECT 
	[job_name] = j.name, 
	[step_name] = jh.step_name,
	[last_run duration] = STUFF(STUFF(REPLACE(STR(jh.run_duration,7,0),
		' ','0'),4,0,':'),7,0,':'),
	[last_start date] = CONVERT(DATETIME, RTRIM(jh.run_date) + ' '
		+ STUFF(STUFF(REPLACE(STR(RTRIM(jh.run_time),6,0),
		' ','0'),3,0,':'),6,0,':')),
		[status] = CASE
				WHEN jh.run_status = 0 THEN 'Failed'
				WHEN jh.run_status = 2 THEN 'Retry'
				WHEN jh.run_status = 3 THEN 'Canceled'
				END
	FROM msdb.dbo.sysjobs j
	LEFT OUTER JOIN msdb.dbo.sysjobschedules js
		ON j.job_id = js.job_id
	LEFT OUTER JOIN msdb.dbo.sysschedules s
		ON js.schedule_id = s.schedule_id 
	LEFT  JOIN (SELECT job_id, max(run_duration) AS run_duration
			FROM msdb.dbo.sysjobhistory
			GROUP BY job_id) maxdur
	ON j.job_id = maxdur.job_id
	LEFT JOIN msdb.dbo.sysjobhistory jh ON jh.job_id=j.job_id
	WHERE run_status != 1 AND jh.step_id!=0)

	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT 
		unsOrder = CASE WHEN [status] = 'Failed' THEN 800 WHEN [status] = 'Retry' THEN 802 WHEN [status] = 'Canceled' THEN 804 ELSE 806 END, 
		CheckGroup = 'Jobs',
		CheckSubGroup = [status],
		DatabaseName = NULL,
		Details =	'Job Name : '+CONVERT(VARCHAR(100),[job_name]) + 
					'[br]Step Name: '+CONVERT(VARCHAR(100),[step_name]) +
					'[br]Duration : '+CONVERT(VARCHAR(100),[last_run duration])+
					'[br]Error Time : '+CONVERT(VARCHAR(100),[last_start date],120),
		Details2 = NULL,
		Comment = NULL,
		Type = CASE WHEN [status] = 'Failed' THEN 3 ELSE 2 END
	FROM cte_Jobs WITH (NOLOCK)
	WHERE [last_start date]>GETDATE()-3;




	/********** Jobs - Long Running ***************/ RAISERROR('Jobs - Long Running processing...',0,1) WITH NOWAIT;


	DECLARE @MinJobRunDateTime DATETIME = GETDATE()-7 
	DECLARE @MinJobDurationSec INT = 60
	DECLARE @ThresholdPercent DECIMAL(18,2) = 10 

	SET @ThresholdPercent = (@ThresholdPercent+100)*0.01

	;WITH CTE AS (
	SELECT	JobName = sj.name,
			StepName = jh.step_name,
			AVGRunDurationSeconds = AVG(run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100)
	FROM msdb.dbo.sysjobs sj
	INNER JOIN msdb.dbo.sysjobhistory jh ON sj.job_id = jh.job_id
	WHERE msdb.dbo.agent_datetime(run_date, run_time)>@MinJobRunDateTime
	GROUP BY sj.name,jh.step_name
	)
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT	
		unsOrder = 810,
		CheckGroup = 'Jobs',
		CheckSubGroup = 'Long Running',
		DatabaseName = NULL,
		Details = '
		JobName : '+CONVERT(VARCHAR(100),sj.name)+
		'[br]StepName = '+CONVERT(VARCHAR(100),jh.step_name)+
		'[br]RunDateTime = '+CONVERT(VARCHAR(100),msdb.dbo.agent_datetime(run_date, run_time),120)+
		'[br]EndDateTime = '+CONVERT(VARCHAR(100),DATEADD(SECOND, run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100, msdb.dbo.agent_datetime(jh.run_date, jh.run_time)),120)+
		'[br]RunDuration_DDHHMMSS = '+CONVERT(VARCHAR(100),STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(jh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':'))+ 
		'[br]RunDurationSeconds = '+CONVERT(VARCHAR(100),(run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100))+ 
		'[br]AVGRunDurationSeconds = '+CONVERT(VARCHAR(100),CTE.AVGRunDurationSeconds),
		Details2 = NULL,
		Comment = NULL,
		Type = 2
	FROM msdb.dbo.sysjobs sj
	INNER JOIN msdb.dbo.sysjobhistory jh ON sj.job_id = jh.job_id
	INNER JOIN CTE ON CTE.JobName=sj.name AND CTE.StepName=jh.step_name
	WHERE step_id!=0
	AND (run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100) > (CTE.AVGRunDurationSeconds*@ThresholdPercent)
	AND CTE.AVGRunDurationSeconds>@MinJobDurationSec
	AND msdb.dbo.agent_datetime(run_date, run_time)>@MinJobRunDateTime


	/********** msdb - Job History Purge ***************/ RAISERROR('msdb - Job History Purge processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT 
		unsOrder = 820, 
		CheckGroup = 'msdb',
		CheckSubGroup = 'History Purge',
		DatabaseName = 'msdb',
		Details = CASE WHEN MIN(msdb.dbo.agent_datetime(run_date, run_time))<DATEADD(dd, -30, GETDATE())
					THEN 'Probably history not purged, oldest job history: '+CONVERT(VARCHAR(100),MIN(msdb.dbo.agent_datetime(run_date, run_time)))
					WHEN MIN(msdb.dbo.agent_datetime(run_date, run_time))>DATEADD(dd, -30, GETDATE())
					THEN 'Too purge fruquently, oldest job history: '+CONVERT(VARCHAR(100),MIN(msdb.dbo.agent_datetime(run_date, run_time))) 
					ELSE 'Purges are okay, oldest job history: '+CONVERT(VARCHAR(100),MIN(msdb.dbo.agent_datetime(run_date, run_time)))  END,
		Details2 = NULL,
		Comment = NULL,
		Type = 0
	FROM msdb.dbo.sysjobhistory


	/********** msdb - Backup History Purge ***************/ RAISERROR('msdb - Backup History Purge processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT 
		unsOrder = 820, 
		CheckGroup = 'msdb',
		CheckSubGroup = 'History Purge',
		DatabaseName = 'msdb',
		Details = CASE WHEN MIN(backup_start_date) <DATEADD(dd, -31, GETDATE())
					THEN 'Probably history not purged, oldest backup history: '+CONVERT(VARCHAR(100),MIN(backup_start_date))
					WHEN MIN(backup_start_date)>DATEADD(dd, -10, GETDATE())
					THEN 'Too purge fruquently, oldest backup history: '+CONVERT(VARCHAR(100),MIN(backup_start_date)) 
					ELSE 'Purges are okay, oldest backup history: '+CONVERT(VARCHAR(100),MIN(backup_start_date)) END,
		Details2 = NULL,
		Comment = NULL,
		Type = 0
	FROM msdb.dbo.backupset



	/********** Always On ***************/ RAISERROR('Always On processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT 
		unsOrder = 1000,
		CheckGroup = 'Always On',
		CheckSubGroup = CASE WHEN last_commit_time<DATEADD(MINUTE,-30,GETDATE()) THEN 'Warning - There is delay 30 min' ELSE 'Info' END,
		DatabaseName = DB_NAME(database_id),
		Details = 
		'Last Commit : '+CONVERT(VARCHAR(100),last_commit_time,120)
		+'[br]Queue Size : '+CONVERT(VARCHAR(100),redo_queue_size),
		Details2 = 
		'Estimated Time : '+ CONVERT(VARCHAR(20),DATEADD(mi,(redo_queue_size/redo_rate/60.0),GETDATE()),120)
		+'[br]Behind Time : '+CAST(CAST(((DATEDIFF(s,last_commit_time,GetDate()))/3600) as varchar) + ' hour(s), ' + CAST((DATEDIFF(s,last_commit_time,GetDate())%3600)/60 as varchar) + ' min, ' + CAST((DATEDIFF(s,last_commit_time,GetDate())%60) as varchar) + ' sec' as VARCHAR(30))
		,
		Comment = CASE WHEN last_commit_time<DATEADD(MINUTE,-30,GETDATE()) THEN 'If your Queue Size more than 1000, probably you have a transfer issue.' ELSE NULL END,
		Type = CASE WHEN redo_queue_size>1000 THEN 3 WHEN redo_queue_size BETWEEN 500 AND 1000 THEN 2 ELSE 1 END
	FROM master.sys.dm_hadr_database_replica_states WITH (NOLOCK)
	WHERE last_redone_time is not null AND redo_rate>0


	/********** Performance - Duplicate Query Plan ***************/ RAISERROR('Performance - Duplicate Query Plan processing...',0,1) WITH NOWAIT;
	INSERT INTO ##uns_DailyChecker (unsOrder,CheckGroup,CheckSubGroup,DatabaseName,Details,Details2,Comment,Type)
	SELECT TOP 1
		unsOrder = 10000, 
		CheckGroup = 'Performance',
		CheckSubGroup = 'Duplicate Query Plan',
		DatabaseName = NULL,
		Details =	'There are '+CONVERT(VARCHAR(100),COUNT(query_hash))+' plans for one query in the plan cache.[br] query hash: '+CONVERT(VARCHAR(100),query_hash,1),
		Details2 = NULL,
		Comment = NULL,
		Type = 3
	FROM sys.dm_exec_query_stats
	GROUP BY query_hash
	HAVING COUNT(query_hash)>100
	ORDER BY COUNT(query_hash) DESC 










---------------------------------------------------------------------------------------------------
/****************** @ResultHTML Parameter *******************/

	IF @ResultHTML=1
	BEGIN
	
	IF OBJECT_ID('tempdb..#uns_ResultHTML') IS NOT NULL DROP TABLE #uns_ResultHTML;
	CREATE TABLE #uns_ResultHTML (unsOrder_HTML INT,HTMLValue NVARCHAR(MAX))

	/*** Header and Footer ***/
	INSERT INTO #uns_ResultHTML (unsOrder_HTML,HTMLValue)
	SELECT -999,'
	<html>
		<head>
			<meta charset="utf-8">
			<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
			<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" crossorigin="anonymous">
			
		</head>
	



	<body>
	<div class="container">'
	UNION
	SELECT -998,'<br><br><div class="text-center card text-white bg-dark mb-3"><div class="card-header">
	<img src="http://www.silikonakademi.com/img/logo.png" class="mr-3" alt="..."></div>
	<div class="card-body"><p class="card-text">Health Check Silikon Akademi tarafından [Customer] için hazırlanmıştır.</p>
	<a href="http://www.silikonakademi.com/" class="btn btn-outline-info">silikonakademi.com</a></div></div>'
	UNION
	SELECT 9999999 ,'<br></div></body></html>'
	/*** SQL Server Bilgileri ***/
	UNION
	SELECT -1,'<div class="row"><div class="col-9"><br><h4>SQL Server Bilgileri </h4><br>'
	UNION
	SELECT 0,'<table class="table table-bordered">'
	UNION
	SELECT 1,'<tr><td>'+CheckSubGroup+'</td><td>'+Details+'</td></tr>' FROM ##uns_DailyChecker
	WHERE CheckGroup='Server Info' 
	UNION SELECT 2,'</table></div>'

	UNION SELECT 6,'<div class="col-3">'
	UNION SELECT 7,'<span class="btn btn-'
	+CASE 
		WHEN Type = 0 THEN 'Info'
		WHEN Type = 1 THEN 'Success'
		WHEN Type = 2 THEN 'Warning'
		WHEN Type = 3 THEN 'Danger' END+'">'
	+CASE 
		WHEN Type = 0 THEN 'Info'
		WHEN Type = 1 THEN 'Success'
		WHEN Type = 2 THEN 'Warning'
		WHEN Type = 3 THEN 'Danger' END
	+' <span class="badge badge-light">'+CONVERT(VARCHAR(10),COUNT(1))+'</span></span>' FROM ##uns_DailyChecker
	GROUP BY Type
	UNION SELECT 8,'</div></div>'
	
	


	IF OBJECT_ID('tempdb..#uns_ResultHTML_Desc') IS NOT NULL DROP TABLE #uns_ResultHTML_Desc;
	CREATE TABLE #uns_ResultHTML_Desc (CheckGroup VARCHAR(250),CheckSubGroup VARCHAR(1000),HTMLValue NVARCHAR(MAX))
	INSERT INTO #uns_ResultHTML_Desc (CheckGroup,CheckSubGroup,HTMLValue)
	SELECT /*BEGIN*/  'Server Configuration','automatic soft-NUMA disabled','
	<br><h4>SQL Server Konfigürasyonu - automatic soft-NUMA disabled </h4>
	<p><b>automatic soft-NUMA disabled </b>: Numa ayarının otomatik olarak yapılmasını sağlamaktadır. 
	<br><b class="text-success">Best Practice : </b><u><mark>Kapalı (0)</mark> olarak ayarlanması gerekmektedir.</u></p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/  'Server Configuration','backup compression default','
	<br><h4>SQL Server Konfigürasyonu - backup compression default </h4>
	<p><b>backup compression default</b> : Backup alınırken belirtilmediği durumlarda varsayılan olarak backup''ın sıkıştırılarak alınıp alınmayacağını belirtir.  
	<br><b class="text-success">Best Practice : </b><u><mark>Açık</mark> olarak ayarlanması tavsiye edilmektedir.</u></p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/  'Server Configuration','cost threshold for parallelism','
	<br><h4>SQL Server Konfigürasyonu - cost threshold for parallelism </h4>
	<p><b>cost threshold for parallelism </b> : Bu değer default 5 olarak gelmektedir. Maliyeti bu değerini aşan sorgular SQL Server tarafından paralel çalıştırılır.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/  'Server Configuration','fill factor (%)','
	<br><h4>SQL Server Konfigürasyonu - fill factor (%) </h4>
	<p><b>fill factor (%) </b> : SQL Server seviyesinde Fill Factor değeri yeni oluşturulan indeksler üzerinde varsayılan olarak verilebilmektedir. Fill Factor değeri page''lerde boşluk bırakabilmemizi sağlayan özellik olup bu özellik yanlış ayarlanması durumunda indekslerin fragmante olmasına ve performans kayıplarına sebep olmaktadır. 
	<br><b class="text-success">Best Practice : </b><u>Değerin <mark>90</mark> olarak ayarlanması tavsiye edilmektedir.</u></p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/  'Server Configuration','max degree of parallelism','
	<br><h4>SQL Server Konfigürasyonu - max degree of parallelism </h4>
	<p><b>max degree of parallelism </b> : Değeri verilen CPU core sayısını göstermektedir. Defualt olarak 0 gelen bu değer, maliyetli çalıştırılan bir sorgunun birden fazla CPU Core’u kullanılabileceği anlamına gelmektedir. Bu da maliyetli çalışan bir sorgunun diğer sorgular için ayrılan kaynakları da kullanıp yavaşlığa sebep olmasına yol açabilir.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/  'Server Configuration','max server memory (MB)','
	<br><h4>SQL Server Konfigürasyonu - max server memory (MB) </h4>
	<p><b>max server memory (MB) </b> : SQL Server''a ayrılmış memory miktarını belirtmektedir.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/  'Server Configuration','optimize for ad hoc workloads','
	<br><h4>SQL Server Konfigürasyonu - optimize for ad hoc workloads </h4>
	<p><b>optimize for ad hoc workloads </b> : SQL Server üzerinde yapılan her sorgular Execution Planlar oluşturulmakta ve bu planlar Memory üzerinde bulunmaktadır. Memory üzerinde önemli bir bölüm olan Plan Cache alnını optimize etmek için kullanılan bu ayar, parametrik olmayan veya bir defa çalıştırılıp daha sonra kullanılmayan execution planların Plan Cache''te tamamının saklanmasını engeller. Bu sayede Memory üzerinde yer alan Plan Cache bölümünden tasarruf yapılmış olur. 
	<br><b class="text-success">Best Practice : </b><u><mark>Açık</mark> olarak ayarlanması tavsiye edilmektedir.</u></p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/  'Server Configuration','remote admin connections','
	<p><b>remote admin connections </b> : SQL Server açılan  her bağlantı için bir kaynak ayırır. Eğer yeni bağlantı için yeterli kaynak yok ise SQL Server kaynak açılana kadar cevap vermeyecektir. Böyle durumlarda SQL Server servisini restart etmek yerine, eğer DAC(Dedicated Admin Connections) ayarı açık ise SQL Server sysadmin rolüne sahip kişiler için her zaman bir bağlantı kaynağı ayıracak ve sorun anında SQL server''a bağlanmamızı sağlayacaktır. 
	<br><b class="text-success">Best Practice : </b><u><mark>Açık</mark> olarak ayarlanması tavsiye edilmektedir.</u></p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/  'Server Configuration','xp_cmdshell','
	<br><h4>SQL Server Konfigürasyonu - xp_cmdshell </h4>
	<p><b>xp_cmdshell </b> : SQL Server üzerinden OS üzerine erişime izin veren ayardır.</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Server Configuration','Non-Default','
	<br><h4>SQL Server Konfigürasyonu - Varsayılan Dışındakiler </h4>
	<p> Aşağıdaki SQL Server ayarları varsayılan ayarlardan farklı olduğu gözlemlenmiştir. Ayarların kontrol edilmesi gerekmektedir.</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Group Policy','Lock Pages in memory','
	<br><h4>Group Policy Konfigürasyonu </h4>
	<p><b>Lock Pages in memory </b>: SQL Server aldığı memory''i uygulamaların ya da işletim sisteminin ihtiyaç duyması durumunda aldığı memoryi paylaşmaması performans açısından önemli olmaktadır. Bunun için Local Policy tarafında SQL Server servis hesabına yetki tanımlanması gerekmektedir. <u>SQL Server service hesabının bu policy''e tanımlanması gerekmektedir.</u>
	</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Group Policy','IFI','
	<br><h4>Group Policy Konfigürasyonu </h4>
	<p><b>Instant File Initialization (IFI) </b>: Bu ayar veritabanımızın data dosyaları oluşturulduğunda ya da SQL Server tarafından büyütülmesi gerektiğinde, bunu daha hızlı yapmak için kullanılmaktadır. Daha hızlı yapmasının sebebi ise, bu ayarı aktif etmediğimiz durumda veritabanı data dosyalarımızın oluşturulması veya büyütülmesi gerektiğinde öncelikle dosyanın tümü 0 ile doldurularak SQL Serverın kullanımı için ayrılıyor. Bu ayarı aktifleştirdiğimizde data dosyalarımız SQL Serverın kullanımı için ayrıldığında 0 ile doldurulmaz ve böylece yeni data dosyalarının oluşturulması ve büyütülmesi hızlı bir şekilde tamamlanır. <u>SQL Server service hesabının bu policy''e tanımlanması gerekmektedir.</u>
	</p>
	<table class="table table-bordered">'



	UNION
	SELECT /*BEGIN*/ 'Database Configuration','tempdb Configuration','
	<br><h4>tempdb Konfigürasyonu </h4>
	<p>tempdb veritabanı bir sistem veritabanı olup, SQL Server her yeniden başlatıldığında bu veritabanı yeniden oluşturulmaktadır. tempdb önemli bir sistem veritabanı olup sadece kullanıcı tanimli temp tablolar için değil, SQL Server ihtiyaç duyduğunda Order by , group by, join gibi işlemlerde de Tempdb yi kullanmaktadır. Bu sebeple tempdb sistem performansını doğrudan etkilemektedir, tempdb file sayısının fazla olması işlemlerin bu file''lara bölünerek performans kazanmasını sağlamaktadır. tempdb data file''larının boyutlarının aynı olması ve kullandığı diskin hızlı olması hatta sistem üzerindeki SSD disklerde kullanılması önerilmektedir. 
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Database Configuration','is_auto_close_on','
	<h4>User Database Konfigürasyonu </h4>
	<p><b> is_auto_close_on </b> : SQL Server''da kullanılmayan, üzerinde connection olmayan veritabanlarının kapalı konuma alınması demektir. Ancak bu, veritabanını kullanmak isteyen bir sonraki kullanıcının bekleme süresini arttıracağından bu özelliğin kapatılması önerilir.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Database Configuration','is_auto_shrink_on','
	<h4>User Database Konfigürasyonu </h4>
	<p><b>is_auto_shrink_on </b> : SQL Server''a SQL Server üzerinde yapılan işlemler sonrasında veritabanında büyümeler olsa bile verilerin silinmesi halinde veritabanı boyutu küçülmeyecektir.Zorunlu olmayan durumlar dışında Shrink işlemi ile veritabanın data dosyalarının küçültülmesi, indekslerin bozulmasına(fragmantasyon) sebep olacaktır. Bu sebeple veritabanları üzerinde Auto Shrink açılmamalı ve data dosyaları üzerinde Shrink işlemi yapılmamalıdır.Eğer zorunlu bir durum var ise Shrink işleminden sonra Index''lerin bakımlarının yapılması gerekmektedir.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Database Configuration','is_auto_create_stats_on','
	<h4>User Database Konfigürasyonu </h4>
	<p><b>is_auto_create_stats_on </b> : SQL Server SQL Server daha iyi execution planlar oluşturmak için Statistic''leri kullanır. Bu özelliğin açık olmaması eksik statistic''ler sebebiyle sorgularda performans sorununa yol açabilir.</p>                       
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Database Configuration','is_auto_update_stats_on','
	<h4>User Database Konfigürasyonu </h4>
	<p><b>is_auto_update_stats_on </b> : SQL Server SQL Server daha iyi execution planlar oluşturmak için Statistic''leri kullanır. Bu özelliğin açık olmaması eksik statistic''ler sebebiyle sorgularda performans sorununa yol açabilir.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Database Configuration','compatibility_level','
	<h4>User Database Konfigürasyonu </h4>
	<p><b>compatibility_level </b> : SQL Server''da SQL Server eski bir sürümden upgrade edildiğinde veya eski bir sürümdeki veritabanı daha güncel bir sürüme alındığında bu özellik değişmemektedir. Veritabanının güncel sürümün tüm özelliklerinden faydalanmasını sağlamak adına bu değişiklik yapılmalıdır.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Database Configuration','LEGACY_CARDINALITY_ESTIMATION','
	<h4>LEGACY_CARDINALITY_ESTIMATION</h4>
	<p></p>
	<table class="table table-bordered">'




	UNION
	SELECT /*BEGIN*/ 'Auto-Growth','Possibly Warnings','
	<br><h4>Auto-Growth </h4>
	<p>AutoGrowth değerleri veritabanının büyüme ihtiyacı olduğunda, eklenecek olan boş alanı temsil eder. MB ve Percent olarak iki çeşidi vardır. Percent tipi, büyümeleri düzensiz katsayılarda yapacağı için best practice olarak 64 ve katları olacak şekilde düzenlenmelidir.
	</p>
	<table class="table table-bordered">'



	UNION
	SELECT /*BEGIN*/ 'Databases','Database growth according to taken backups','
	<br><h4>Database growth according to taken backups </h4>
	<p></p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'Database Files','Too much free space','
	<br><h4>Too much free space on Data File </h4>
	<p></p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Database Files','Log File Bigger Than 4/1 Data File','
	<br><h4>Log File Bigger Than 4/1 Data File</h4>
	<p></p>
	<table class="table table-bordered">'




	UNION
	SELECT /*BEGIN*/ 'Virtual Log File','VLF count info','
	<br><h4>Virtual Log File</h4>
	<p>SQL Server Transaction Log dosyaları birden fazla Virtual LogFile''lardan oluşmaktadır. Bu dosyaların fazla olması SQL Server''ın ya da servislerinin restart olması durumundaveritabanları daha geç ayağa kalkmakta ve Log backup alma , restore etme işlemlerinin uzun sürmesine neden olmaktadır. VLF dosyalarının Veritabanı yöneticilerinin kontrolünde büyümelerini sağlaması için File''ların Initial Size, AutoGrowth / MaxSize ayarlarını yapılandırmaları gerekmektedir. VLF count bilgileri DBCC LOGINFO() komutu ile kontrol edilebilmektedir.                 

	<br><li>Virtual Log File sayıları <mark>1000</mark>''den büyük olan veritabanlarına müdahale edilerek değerler küçültülmelidir.</li>

	</p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'Database File Configurations','Log File Count','
	<br><h4>Database File Configurations - Log File Count</h4>
	<p>Birden fazla log dosyasını kontrol eder. Log dosyaları sequential olarak çalıştığı için birden fazla olması best practice''lere aykırı bir durumdur.</p>
	<table class="table table-bordered">'



	UNION
	SELECT /*BEGIN*/ 'Memory','','
	<br><h4>Memory</h4>
	<p>
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Worker Info','CPU or Disk Performance','
		'


	UNION
	SELECT /*BEGIN*/ 'Disk','Size','
	<br><h4>Disk Size</h4>
	<p>Disklerin doluluk oranlarını kontrol ettiğimiz bu kısımdaki değerlerimiz; 
	<ul class="list-group">
		<li class="list-group-item"><b>Free Space < %5 </b> : Acil müdahale gerekmektedir.
		<li class="list-group-item"><b>Free Space BETWEEN %5 AND %20 </b> : Kontrol edilip, disk eklenmeli veya gereksiz dosyalar taşınmalı/silinmelidir.
		<li class="list-group-item"><b>Free Space > %20 </b> : Disklerde yeterli yer olduğundan müdahale gerekmemektedir.
	</ul>
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Disk','Latency','
	<br><h4>Disk Latency</h4>
	<p>Disk gecikme oranlarını kontrol ettiğimiz bu kısımdaki değerlerimiz;
	<br>
	<ul class="list-group">
		<li class="list-group-item"><b>Latency > 100 </b>: Veritabanı üzerindeki sorgular, indeksler vs. incelenmeli ve gerekli önlemler alınmalıdır.</li>
		<li class="list-group-item"><b>Latency BETWEEN 50 AND 100 </b>: Kabul edilebilir bir değer olmasına rağmen sorgu, indeks vs. incelemesi gerekmektedir.</li>
		<li class="list-group-item"><b>Latency < 50 </b>: Disk performansı sağlıklı olarak kabul edilmektedir.</li>
	</ul>
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Performance','Wait Types','
	<br><h4>Performance - Wait Types</h4>
	<p>SQL Server üzerinde gözlemenen bekleme türleri aşağıdaki gibidir. Bekleme türlerinin incelenmesi ve gerekirse optimize edilmesi gerekmektedir.</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Index Definition','Unused Indexes','
		'


	


	UNION
	SELECT /*BEGIN*/ 'Index Definition','Fill Factor','
	<br><h4>Index - Fill Factor Kontrolleri</h4>
	<p>Page''lerdeki boşluk oranlarının ayarlanması SQL Server Instance seviyesi dışında Index''ler üzerinden de ayarlanabilmektedir. Page''lerde Fill Factor seviyesi ayarlanması Index''lerin Fragmante olmasını geciktirir. Bu kısımda Fill Factor 0 ile 80 arasında olan Index''leri kontrol etmekteyiz.
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Index Definition','Heap Table','
	<br><h4>Index - Heap Table Kontrolleri</h4>
	<p>SQL Server’da sıralı olmayan ve clustered indeks atılmamış tablolara HEAP TABLE denilmektedir. Bu tablolara sorguların çekilmesinde performans olarak kayıplara neden olma ihtimali bulunmasından dolayı bu tablolar tespit edilip indeks atılıp atılmayacağına karar verilmelidir.
	</p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'Index Definition','Non-Indexed ForeignKeys','
	<br><h4>Index - Non-Indexed ForeignKeys Kontrolleri</h4>
	<p>Üzerinde Index bulunmayan ForeignKey''ler kontrol edilmektedir. Foreign Key''ler üzerinde index oluşturulması performansı iyi yönde etkileyecektir.
	</p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'Index Definition','Indexes Lock Options','
	<br><h4>Index - Indexes Lock Options</h4>
	<p>Index üzerinde Page ve Row Lock izinleri kontrol edilmektedir. Kapalı olması durumunda locklanmalara sebep olmaktadır.
	</p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'Table Configurations','Table nvarchar/varchar Max Columns','
	<br><h4>Table Configurations - Table nvarchar/varchar Max Columns</h4>
	<p>Tablolar üzerindeki kolonların uzunlukları MAX olanlar kontrol edilir.
	</p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'Table Configurations','Identity INT column max value','
	<br><h4>Table Configurations - Identity INT column max value</h4>
	<p>Tablolar üzerindeki Identity INT kolonların değerleri INT data tipinin max değerine yakınlığı kontrol edilir.
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Backup','Full Backup Operations','
	<br><h4>Backup - Full Backup Operations</h4>
	<p>Veri tabanları kurumlar için kritik verilerinin olduğu ve kullanılan sistemlerin veri tabanları ile çalışması sebebi ile yedekleme planlarının olması hayati önem arz etmektedir. Yapılan yedekleme planlarının çalışıp çalışmadığı kontrolleri ve yedekleme planlarının Best Practice’lere göre oluşturup oluşturulmadığı kontrol edilmektedir. 
	</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Backup','FULL Recovery Model & Log Backup Operations','
	<br><h4>Backup - FULL Recovery Model & Log Backup Operations</h4>
	<p></p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Backup','Log Backup Operations','
	<br><h4>Backup - Log Backup Operations</h4>
	<p></p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Backup','Warning Backup Operations','
	<br><h4>Backup - Warning Backup Operations</h4>
	<p></p>
	<table class="table table-bordered">'





	UNION
	SELECT /*BEGIN*/ 'Data Corruption','Suspect Pages','
	<br><h4>Data Corruption</h4>
	<p>Veritabanlarında [msdb].[dbo].[suspect_pages] üzerine kayıt edilmiş bozuk sayfa olup olmadığı kontrol edilmektedir.
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Data Integrity','Last Good Check DB','
	<br><h4>Data Integrity - Last Good Check DB</h4>
	<p>Bütünlük kontrolü veritabanları üzerinde belirli aralıklarla yapılması gereken, oluşabilecek corruption''lara karşı önlem alınabilmesi alınabilmesi adına önem taşımaktadır. Bu kısımda son yapılan başarılı CHECKDB operasyonunu kontrol etmekteyiz.
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Login and User','Orphaned user','
	<br><h4>Orphaned user</h4>
	<p>Herhangi bir Login''e bağlı olmayan User''lara orphaned user denilmektedir. Bu kullanıcıların kontrol edilip düzenlenmesi gerekmektedir. </p>
	<small>*Nasıl düzeltebileceğinize <a href="https://yunusuyanik.com/sql-login-ve-user-mapping-orphaned-users/">göz atın</a>.</small>
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Login and User','sysadmin','
	<br><h4>sysadmin</h4>
	<p>SQL Server üzerinde bulunan sysadmin sayısı gözlemlenmektedir. sysadmin yetkisine sahip kullanıcılar gözden geçirilmelidir.
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Jobs','Failed','
	<br><h4>Jobs</h4>
	<p>Aşağıdaki Job''ların hata aldığı gözlemlenmiştir.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Jobs','Retry','
	<br><h4>Jobs</h4>
	<p>Aşağıdaki Job''lar yeniden çalışmayı denemiştir.</p>
	<table class="table table-bordered">'
	UNION
	SELECT /*BEGIN*/ 'Jobs','Canceled','
	<br><h4>Jobs</h4>
	<p>Aşağıdaki Job''lar durdurulmuştur.</p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'Jobs','Long Running','
	<br><h4>Jobs - Long Running</h4>
	<p></p>
	<table class="table table-bordered">'

	UNION
	SELECT /*BEGIN*/ 'msdb','History Purge','
	<br><h4>msdb - History Purge</h4>
	<p></p>
	<table class="table table-bordered">'





	UNION
	SELECT /*BEGIN*/ 'Counters','Performance','
	<br><h4>Performans Counters</h4>
	<p>Kontrollerimiz sırasında ortalama SQL Server Performans sayaçları değerleridir.
	<br><b>Active Temp Tables </b>: tempdb üzerinde kullanılan aktif tablo sayısını göstermektedir.
	<br><b>Average Wait Time (ms) </b>: Ortalama bekleme süresini göstermektedir.                                                                                                       
	<br><b>Buffer cache hit ratio </b>: Araballekten okunan page sayısını yüzde olarak göstermektedir.
	<br><b>Free Memory (KB) </b>: Sunucu üzerinde kullanılmayan memory miktarını göstermektedir.
	<br><b>Memory Grants Pending </b>: Memory üzerindeki bekleyen isteklerin sayısını göstermektedir 0 veya 0''a yakın olması iyi olduğunu göstermektedir.
	<br><b>Page life expectancy </b>: Page''lerin memory üzerinde tutulduğu süreyi saniye cinsinden belirten değerdir. Minimum 300 (5dk) olması önerilmektedir. Yüksek olması performansın iyi yönde olduğunu göstermektedir.
	<br><b>Target Server Memory (KB) </b>: SQL Server''ın ihtiyacı olduğu memory miktarını göstermektedir.
	<br><b>Total Server Memory (KB)</b>: SQL Server''ın allocate ettiğigi memory''i göstermektedir.
	<br><b>User Connections </b>: Her dakika SQL Server üzerinde login olan kullanıcı sayısı bilgisini göstermektedir.
	<br><b>AVG CPU Values (Last 256 Min) </b>: Sunucu üzerinde SQL servis tarafından kullanılan CPU değerlerini göstermektedir.
	</p>
	<table class="table table-bordered">'










	UNION
	SELECT /*BEGIN*/ 'Always On','Info','
	<br><h4>Always On</h4>
	<p>AlwaysOn durumları gözlemlenmektedir. Son aktarım tarihinden 30 dakika geçmiş, aktarılacak kayıt sayısı (Queue Size) 1000''den fazla olup olmadığı kontrol edilmektedir.
	</p>
	<table class="table table-bordered">'


	UNION
	SELECT /*BEGIN*/ 'Lock Info','Deadlock','
	<br><h4>Deadlock</h4>
	<p>SQL Server üzerinde deadlock olup olmadığı kontrol edilmektedir. Eğer var ise sebep olan işlemler bulunup kontrol edilmelidir.
	</p>
	<table class="table table-bordered">'



	UNION
	SELECT /*BEGIN*/ 'Performance','Duplicate Query Plan','
	<br><h4>Performance - Duplicate Query Plan</h4>
	<p>Bazı durumlarda sorgulara ait birden fazla query plan oluşabilmektedir. Bu durum sunucu üzerinde CPU kullanımına, sorgunun süresinin uzamasına ve SQL Server query plan belleği üzerinde gereksiz yer kaplayan query planların oluşmasına sebep olmaktadır.
	</p>
	<table class="table table-bordered">'



		DECLARE @unsOrder INT 
		DECLARE @CheckGroup VARCHAR(max) 
		DECLARE @CheckSubGroup VARCHAR(max) 

		/** Last Result Of HTML **/
		SELECT DISTINCT CheckGroup,CheckSubGroup INTO #uns_Check FROM ##uns_DailyChecker  WHERE unsOrder>9
		DECLARE db_cursor CURSOR FOR 
		SELECT CheckGroup,CheckSubGroup FROM #uns_Check

		OPEN db_cursor  
		FETCH NEXT FROM db_cursor INTO @CheckGroup ,@CheckSubGroup 

		WHILE @@FETCH_STATUS = 0  
		BEGIN  
			  
			IF (SELECT COUNT(1) FROM ##uns_DailyChecker WHERE CheckGroup=@CheckGroup AND CheckSubGroup=@CheckSubGroup)>0
					BEGIN

						SET @unsOrder = (SELECT MIN(unsOrder) FROM ##uns_DailyChecker WHERE CheckGroup=@CheckGroup AND CheckSubGroup=@CheckSubGroup)

						INSERT INTO #uns_ResultHTML (unsOrder_HTML,HTMLValue)

						SELECT @unsOrder-1,HTMLValue FROM #uns_ResultHTML_Desc WHERE CheckGroup=@CheckGroup AND CheckSubGroup=@CheckSubGroup
						UNION
						SELECT unsOrder,
							'<tr '+
								CASE 
									WHEN Type=0 THEN 'class="table-info"' 
									WHEN Type=1 THEN 'class="table-success"' 
									WHEN Type=2 THEN 'class="table-warning"' 
									WHEN Type=3 THEN 'class="table-danger"' END+'><td>'+
								CASE 
									WHEN DatabaseName IS NULL 
									THEN CheckSubGroup ELSE DatabaseName  END +
									
										CASE 
											WHEN Details2 IS NULL THEN '</td><td>'+REPLACE(Details,'[br]','<br>')+'</td></tr>' 
											WHEN Details2 IS NOT NULL THEN '</td><td>'+REPLACE(Details,'[br]','<br>')+'<br>'+REPLACE(Details2,'[br]','<br>')+'</td></tr>' END 
										AS HTMLValue
						FROM ##uns_DailyChecker
						WHERE CheckGroup=@CheckGroup AND CheckSubGroup=@CheckSubGroup
						UNION
						SELECT @unsOrder+1,'</table>' HTMLValue

					END

			FETCH NEXT FROM db_cursor INTO @CheckGroup ,@CheckSubGroup  
		END 

		CLOSE db_cursor  
		DEALLOCATE db_cursor 

	/*Result of HTML*/ 
	--SELECT (SELECT HTMLValue+' ' from #uns_ResultHTML ORDER BY unsOrder_HTML FOR XML PATH(''), TYPE).value('.', 'varchar(max)');
	SELECT HTMLValue from #uns_ResultHTML ORDER BY unsOrder_HTML

		IF @SendMail = 1
		BEGIN
			DECLARE @mailsubject varchar(MAX) = 'usp_DailyChecker Result - '+CONVERT(varchar(max),GETDATE(),102);
			DECLARE @body varchar(MAX);

			SET @body = ((SELECT HTMLValue+' ' from #uns_ResultHTML ORDER BY unsOrder_HTML FOR XML PATH(''), TYPE).value('.', 'varchar(max)'));

			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @profilename, @body = @body, @body_format = 'HTML', @recipients = @to, @subject = @mailsubject;
		END

	END


	IF @ResultHTML=0
	BEGIN
		SELECT unsOrder,CheckGroup,CheckSubGroup,DatabaseName,REPLACE(Details,'[br]',' - ') Details,Details2,Comment,Type,CreateTSQL,DropTSQL,DefinitionTSQL FROM ##uns_DailyChecker
		ORDER BY unsOrder,CheckGroup,CheckSubGroup
	END

	IF OBJECT_ID('tempdb..##uns_DailyChecker') IS NOT NULL DROP TABLE ##uns_DailyChecker;
	IF OBJECT_ID('tempdb..##uns_UnusedIndexes') IS NOT NULL DROP TABLE ##uns_UnusedIndexes;
	IF OBJECT_ID('tempdb..##uns_NonIndexedForeignKey') IS NOT NULL DROP TABLE ##uns_NonIndexedForeignKey;
	IF OBJECT_ID('tempdb..##uns_DailyCheckeuns_FillFactorGroupCountsr') IS NOT NULL DROP TABLE ##uns_FillFactorGroupCounts;
	IF OBJECT_ID('tempdb..##uns_HeapTableCounts') IS NOT NULL DROP TABLE ##uns_HeapTableCounts;
	IF OBJECT_ID('tempdb..##uns_Orphanedusers') IS NOT NULL DROP TABLE ##uns_Orphanedusers;


	
		