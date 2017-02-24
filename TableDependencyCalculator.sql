SET NOCOUNT ON 
/*
Created by 		: Ian Patterson (Muo Limited)
Usage 			: Run the script and the table orders will be displayed 
What it does	: works out the order that the tables depend upon each other
*/
if ( OBJECT_ID('tempdb..#fkeys') IS NOT NULL)
BEGIN
	DROP TABLE #fkeys
END 

if ( OBJECT_ID('tempdb..#rkeys') IS NOT NULL)
BEGIN
	DROP TABLE #rkeys
END 

if ( OBJECT_ID('tempdb..#ForeignKeys') IS NOT NULL)
BEGIN
	DROP TABLE #ForeignKeys
END 

if ( OBJECT_ID('tempdb..#TableOrder') IS NOT NULL)
BEGIN
	DROP TABLE #TableOrder
END 

select 
	sr.constid,
	CASE
		WHEN sr.fkey16 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name + ',' + sc14.name + ',' + sc15.name + ',' + sc16.name
		WHEN sr.fkey15 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name + ',' + sc14.name + ',' + sc15.name
		WHEN sr.fkey14 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name + ',' + sc14.name
		WHEN sr.fkey13 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name
		WHEN sr.fkey12 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name
		WHEN sr.fkey11 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name
		WHEN sr.fkey10 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name
		WHEN sr.fkey9 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name 
		WHEN sr.fkey8 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name
		WHEN sr.fkey7 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name
		WHEN sr.fkey6 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name
		WHEN sr.fkey5 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name
		WHEN sr.fkey4 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name
		WHEN sr.fkey3 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name
		WHEN sr.fkey2 <> 0 THEN sc1.name + ',' + sc2.name
		WHEN sr.fkey1 <> 0 THEN sc1.name
	END as foreignkeycolumns
into 
	#fkeys
from 
	sys.sysreferences sr 
	left outer join sys.columns sc1 on sr.fkeyid = sc1.Object_id and sc1.Column_Id = sr.fkey1
	left outer join sys.columns sc2 on sr.fkeyid = sc2.Object_id and sc2.Column_Id = sr.fkey2
	left outer join sys.columns sc3 on sr.fkeyid = sc3.Object_id and sc3.Column_Id = sr.fkey3
	left outer join sys.columns sc4 on sr.fkeyid = sc4.Object_id and sc4.Column_Id = sr.fkey4
	left outer join sys.columns sc5 on sr.fkeyid = sc5.Object_id and sc5.Column_Id = sr.fkey5
	left outer join sys.columns sc6 on sr.fkeyid = sc6.Object_id and sc6.Column_Id = sr.fkey6
	left outer join sys.columns sc7 on sr.fkeyid = sc7.Object_id and sc7.Column_Id = sr.fkey7
	left outer join sys.columns sc8 on sr.fkeyid = sc8.Object_id and sc8.Column_Id = sr.fkey8
	left outer join sys.columns sc9 on sr.fkeyid = sc9.Object_id and sc9.Column_Id = sr.fkey9
	left outer join sys.columns sc10 on sr.fkeyid = sc10.Object_id and sc10.Column_Id = sr.fkey10
	left outer join sys.columns sc11 on sr.fkeyid = sc11.Object_id and sc11.Column_Id = sr.fkey11
	left outer join sys.columns sc12 on sr.fkeyid = sc12.Object_id and sc12.Column_Id = sr.fkey12
	left outer join sys.columns sc13 on sr.fkeyid = sc13.Object_id and sc13.Column_Id = sr.fkey13
	left outer join sys.columns sc14 on sr.fkeyid = sc14.Object_id and sc14.Column_Id = sr.fkey14
	left outer join sys.columns sc15 on sr.fkeyid = sc15.Object_id and sc15.Column_Id = sr.fkey15
	left outer join sys.columns sc16 on sr.fkeyid = sc16.Object_id and sc16.Column_Id = sr.fkey16


select 
	sr.constid,
	CASE
		WHEN sr.rkey16 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name + ',' + sc14.name + ',' + sc15.name + ',' + sc16.name
		WHEN sr.rkey15 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name + ',' + sc14.name + ',' + sc15.name
		WHEN sr.rkey14 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name + ',' + sc14.name
		WHEN sr.rkey13 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name + ',' + sc13.name
		WHEN sr.rkey12 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name + ',' + sc12.name
		WHEN sr.rkey11 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name + ',' + sc11.name
		WHEN sr.rkey10 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name + ',' + sc10.name
		WHEN sr.rkey9 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name + ',' + sc9.name 
		WHEN sr.rkey8 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name + ',' + sc8.name
		WHEN sr.rkey7 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name + ',' + sc7.name
		WHEN sr.rkey6 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name + ',' + sc6.name
		WHEN sr.rkey5 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name + ',' + sc5.name
		WHEN sr.rkey4 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name + ',' + sc4.name
		WHEN sr.rkey3 <> 0 THEN sc1.name + ',' + sc2.name + ',' + sc3.name
		WHEN sr.rkey2 <> 0 THEN sc1.name + ',' + sc2.name
		WHEN sr.rkey1 <> 0 THEN sc1.name
	END as referencekeycolumns
into 
	#rkeys
from 
	sys.sysreferences sr 
	left outer join sys.columns sc1 on sr.rkeyid = sc1.Object_id and sc1.Column_Id = sr.rkey1
	left outer join sys.columns sc2 on sr.rkeyid = sc2.Object_id and sc2.Column_Id = sr.rkey2
	left outer join sys.columns sc3 on sr.rkeyid = sc3.Object_id and sc3.Column_Id = sr.rkey3
	left outer join sys.columns sc4 on sr.rkeyid = sc4.Object_id and sc4.Column_Id = sr.rkey4
	left outer join sys.columns sc5 on sr.rkeyid = sc5.Object_id and sc5.Column_Id = sr.rkey5
	left outer join sys.columns sc6 on sr.rkeyid = sc6.Object_id and sc6.Column_Id = sr.rkey6
	left outer join sys.columns sc7 on sr.rkeyid = sc7.Object_id and sc7.Column_Id = sr.rkey7
	left outer join sys.columns sc8 on sr.rkeyid = sc8.Object_id and sc8.Column_Id = sr.rkey8
	left outer join sys.columns sc9 on sr.rkeyid = sc9.Object_id and sc9.Column_Id = sr.rkey9
	left outer join sys.columns sc10 on sr.rkeyid = sc10.Object_id and sc10.Column_Id = sr.rkey10
	left outer join sys.columns sc11 on sr.rkeyid = sc11.Object_id and sc11.Column_Id = sr.rkey11
	left outer join sys.columns sc12 on sr.rkeyid = sc12.Object_id and sc12.Column_Id = sr.rkey12
	left outer join sys.columns sc13 on sr.rkeyid = sc13.Object_id and sc13.Column_Id = sr.rkey13
	left outer join sys.columns sc14 on sr.rkeyid = sc14.Object_id and sc14.Column_Id = sr.rkey14
	left outer join sys.columns sc15 on sr.rkeyid = sc15.Object_id and sc15.Column_Id = sr.rkey15
	left outer join sys.columns sc16 on sr.rkeyid = sc16.Object_id and sc16.Column_Id = sr.rkey16

select
	ss.Name as SchemaName, 
	sa.Name as TableName,
	so.name as FKName,
	fk.foreignkeycolumns,
	ss2.Name as ReferenceSchemaName,
	so3.name as ReferenceTableName, 
	rk.referencekeycolumns as ReferencedColumn
into 
	 #FOREIGNKEYS
from
	sys.Schemas ss  
	inner join sys.objects sa ON sa.Schema_id = ss.Schema_id 
	left outer join sys.objects so ON so.parent_object_id = sa.Object_id and so.Type = 'F'
	left outer join sys.sysreferences sr on sr.constid = so.Object_id
	left outer join #fkeys fk on sr.constid = fk.constid
	left outer join #rkeys rk on sr.constid = rk.constid
	left outer join sys.objects so2 on sr.fkeyid = so2.Object_id
	left outer join sys.objects so3 on sr.rkeyid = so3.Object_id
	left outer join sys.schemas ss2 ON so3.Schema_Id = ss2.Schema_Id
where 
	sa.Type = 'U' 
order by 
	sa.Name

DECLARE @Count INT 
SELECT @Count = count(*) from #FOREIGNKEYS

CREATE TABLE #TABLEORDER ( Id INT NOT NULL IDENTITY(1,1), SchemaName VARCHAR(100) NOT NULL, TableName VARCHAR(100) NOT NULL) 

DECLARE @MaxCount INT 
DECLARE @Counter INT

SET @Counter = 0 
SET @MaxCount = 20
WHILE @Count > 0 AND @MaxCount > @Counter
BEGIN 
	
	DECLARE @TABLENAME VARCHAR(100)
	DECLARE @SCHEMANAME VARCHAR(100)
	DECLARE @QUERYSTRING VARCHAR(1000)

	DECLARE input_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			SchemaName,
			TableName
		FROM 
			#FOREIGNKEYS 

	--Open the cursor 
	OPEN input_cursor 

	--Fetch the values 
	FETCH NEXT FROM input_cursor INTO @SCHEMANAME, @TABLENAME
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		DECLARE @TABLEVAR TABLE(result INT)
		DECLARE @REFERENCECOUNT INT 		

		DELETE FROM @TABLEVAR
		SET @REFERENCECOUNT = 1000

		SET @QUERYSTRING = 'SELECT COUNT(1) FROM #FOREIGNKEYS WHERE REFERENCESCHEMANAME = ''' + @SCHEMANAME + ''' AND REFERENCETABLENAME = ''' + @TABLENAME + ''' AND TABLENAME <> ''' + @TABLENAME + ''''

		INSERT INTO @TABLEVAR
			EXECUTE (@QUERYSTRING)

		SELECT @REFERENCECOUNT = result FROM @TABLEVAR

		IF ( @REFERENCECOUNT = 0 )
		BEGIN 
			INSERT INTO #TABLEORDER (SchemaName , TableName) VALUES (@SCHEMANAME, @TABLENAME)
			DELETE FROM #FOREIGNKEYS WHERE SchemaName = @SCHEMANAME AND TableName = @TABLENAME
		END 

		FETCH NEXT FROM input_cursor INTO @SCHEMANAME, @TABLENAME
	END 

	CLOSE input_cursor
	DEALLOCATE input_cursor

	SELECT @Count = count(*) from #FOREIGNKEYS

	SET @Counter = @Counter  + 1 
END 

IF ( (SELECT COUNT(*) FROM #FOREIGNKEYS) <> 0 )
BEGIN
	PRINT 'Failed'
	SELECT * FROM #FOREIGNKEYS
	SELECT * FROM #TABLEORDER
END 
ELSE 
BEGIN 
	SELECT * FROM #TABLEORDER
END 
GO

/*
***********************************************************************************
** Test Script
**
** The purpose of this script is to test the ordering by deleting the information 
** in the database in the correct order. As we do not change foreign keys this is 
** an important test.
***********************************************************************************

DECLARE @TABLENAME VARCHAR(100)
DECLARE @SCHEMANAME VARCHAR(100)
DECLARE @QUERYSTRING VARCHAR(1000)

DECLARE input_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT 
		SchemaName,
		TableName
	FROM 
		#TABLEORDER

	--Open the cursor 
	OPEN input_cursor 

	--Fetch the values 
	FETCH NEXT FROM input_cursor INTO @SCHEMANAME, @TABLENAME
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @QUERYSTRING = 'DELETE FROM ' + @SCHEMANAME + '.' + @TABLENAME 

		PRINT @QUERYSTRING

		EXECUTE (@QUERYSTRING)

		FETCH NEXT FROM input_cursor INTO @SCHEMANAME, @TABLENAME
	END 

	CLOSE input_cursor
	DEALLOCATE input_cursor
GO
*/