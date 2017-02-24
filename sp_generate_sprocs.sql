CREATE PROCEDURE sp_generate_sprocs
(
	@TABLENAME VARCHAR(255),
	@USERNAME VARCHAR(255)
)
AS
/*********************************************************************'
** Name              : sp_generate_sprocs
** Created by        : Ian Patterson (Muo Limited)
** Version			 : 0.5
** Date              : 29/11/2004
** Purpose           : Automatically generate the base insert, update
**                   : delete and select sprocs for a table given the 
**                   : table name and the user. 
*********************************************************************/
SET NOCOUNT ON 

--Variables 
DECLARE @cNAME VARCHAR(255)
DECLARE @cTYPE VARCHAR(25) 
DECLARE @cLENGTH INT 
DECLARE @cPRECISION INT 
DECLARE @cSCALE INT
DECLARE @cISIDENTITY INT
DECLARE @cISPRIMARYKEY INT 

DECLARE @IDENTITYCOUNT INT 
DECLARE @cPARAMTERCOUNT INT
DECLARE @COUNTER INT 

DECLARE @TEMPSTRING VARCHAR(8000)

DECLARE @DATE DATETIME 
DECLARE @IND VARCHAR(255)

	/*******************************************************
	*******              Validation 		********
	*******************************************************/	
	IF NOT EXISTS(SELECT NAME FROM SYSOBJECTS WHERE NAME = @TABLENAME AND TYPE = 'u')
	BEGIN
		RAISERROR('The table does not exist within this schema', 16, -1)
		RETURN
	END 

	/*******************************************************
	*******              Setup 			********
	*******************************************************/	

	SET @DATE = GETDATE() --todays date 
	SET @IND = CHAR(9)  --The indentation 
		
	CREATE TABLE #PARAMETERS
	(
		[name] VARCHAR(255),
		[type] VARCHAR(25),
		length INT,
		[precision] INT, 
		[scale] INT,
		[isIdentity] BIT,
		[isPrimaryKey] BIT
	)

	--Populate it with the parameters 
	--Insert the parameters 

	INSERT INTO #PARAMETERS
	SELECT 
		sc.name, 
		st.name,
		sc.length,
		sc.xprec,
		sc.xscale,
		CASE 
			WHEN sc.colstat & 1 = 1 THEN 1
			ELSE 0
		END,
		CASE 
			WHEN sik.indid IS NOT NULL THEN 1
			ELSE 0
		END 
	FROM 
		sysobjects so
		INNER JOIN syscolumns sc ON so.id = sc.id 
		INNER JOIN systypes st ON sc.xtype = st.xtype  and st.name <> 'sysname'
		LEFT OUTER JOIN sysobjects so2 ON so2.parent_obj = so.id and so2.xtype ='PK'
		LEFT OUTER JOIN sysindexes si ON so.id = si.id and si.name = so2.name
		LEFT OUTER JOIN sysindexkeys sik ON so.id = sik.id and sc.colid = sik.colid and sik.indid = si.indid
	WHERE
		so.name = @TABLENAME
	ORDER BY 
		sc.colorder

	/*******************************************************
	*******              INSERT SPROC  		********
	*******************************************************/	
	PRINT 'IF EXISTS (SELECT name  FROM   sysobjects  WHERE  name = N''' + @TABLENAME + '_insert'' 	   AND 	  type = ''P'')'
	PRINT 'DROP PROCEDURE ' + @TABLENAME + '_insert' 
	PRINT 'GO'
	PRINT 'CREATE PROCEDURE ' + @TABLENAME + '_insert'
	PRINT '('
	
	-- Add the parameters to the sproc		
	
	SELECT @IDENTITYCOUNT = COUNT(*) FROM #PARAMETERS WHERE isIdentity = 1 
	SELECT @cPARAMTERCOUNT = COUNT(*) - @IDENTITYCOUNT FROM #PARAMETERS
	
	SET @COUNTER = 0 	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		SET @TEMPSTRING = @IND + '@' + UPPER(@cNAME) + ' ' + UPPER(@cTYPE) 

		--Add type specific data
		IF UPPER(@cTYPE) = 'VARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END

		IF UPPER(@cTYPE) = 'NVARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 

		IF UPPER(@cTYPE) = 'CHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 		
		
		IF UPPER(@cTYPE) = 'DECIMAL'
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cPRECISION AS VARCHAR(10)) + ',' + CAST(@cSCALE AS VARCHAR(10)) + ')'
		END 

		IF @cISIDENTITY = 1 
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ' OUTPUT'
		END 

		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT + @IDENTITYCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ','
		END

		PRINT @TEMPSTRING
		
		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT ')'
	PRINT 'AS'
	PRINT '/*********************************************************************'
	PRINT '** Name              : ' + @TABLENAME + '_insert'
	PRINT '** Created by        : ' + @USERNAME
	PRINT '** Date              : ' + CAST(@DATE as VARCHAR(17))
	PRINT '** Purpose           : ' + 'The purpose of this procedure is to insert a ' 
	PRINT '**                   : ' + 'new record into the ' + @TABLENAME + ' table. '
	PRINT '**                   : ' + 'This procedure was automatically generated'
	PRINT '*********************************************************************/'
	PRINT 'SET NOCOUNT ON ' 
	PRINT ''	

	PRINT @IND + 'INSERT INTO ' + @TABLENAME 	
	PRINT @IND + @IND + '(' 	

	--Add the insert into columns 
	SET @COUNTER = 0 	
	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF @cISIDENTITY = 0
		BEGIN 
			SET @TEMPSTRING = @IND + @IND + UPPER(@cNAME)
		
			SET @COUNTER = @COUNTER + 1 
			IF @COUNTER <> 	@cPARAMTERCOUNT
			BEGIN
				SET @TEMPSTRING = @TEMPSTRING + ',' 
			END
			
			PRINT @TEMPSTRING
		END 
		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT @IND + @IND + ')' 
	PRINT @IND + 'VALUES' 
	PRINT @IND + @IND + '('		

	--Add the paramters 
	SET @COUNTER = 0 	
	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		IF @cISIDENTITY = 0
		BEGIN 
			SET @TEMPSTRING = @IND + @IND + '@' + UPPER(@cNAME)
	 
			SET @COUNTER = @COUNTER + 1 
			IF @COUNTER <> 	@cPARAMTERCOUNT
			BEGIN
				SET @TEMPSTRING = @TEMPSTRING + ',' 
			END
			
			PRINT @TEMPSTRING
		END 
		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT @IND + @IND + ')'
	PRINT ''

	--If there is an identity column then we want to return the identity.
	--other wise just return 0 
	IF (SELECT COUNT(name) FROM #PARAMETERS WHERE isIdentity = 1) > 0
	BEGIN
		--Get the parameter name  	
		SELECT @cNAME = [name] FROM #PARAMETERS WHERE isIdentity = 1
			
		PRINT @IND + 'SELECT @' + UPPER(@cNAME) + ' = SCOPE_IDENTITY()'	
	END 

	PRINT 'GO'

	/*******************************************************
	*******              Update Sproc 		********
	*******************************************************/	
	PRINT 'IF EXISTS (SELECT name  FROM   sysobjects  WHERE  name = N''' + @TABLENAME + '_update_byid'' 	   AND 	  type = ''P'')'
	PRINT 'DROP PROCEDURE ' + @TABLENAME + '_update_byid' 
	PRINT 'GO'

	PRINT 'CREATE PROCEDURE ' + @TABLENAME + '_update_byid'
	PRINT '('
	
	-- Add the parameters to the sproc		
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS
	SET @COUNTER = 0 	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @TEMPSTRING = @IND + '@' + UPPER(@cNAME) + ' ' + UPPER(@cTYPE) 

		--Add type specific data
		IF UPPER(@cTYPE) = 'VARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 

		IF UPPER(@cTYPE) = 'NVARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 

		IF UPPER(@cTYPE) = 'CHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 			

		IF UPPER(@cTYPE) = 'DECIMAL'
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cPRECISION AS VARCHAR(10)) + ',' + CAST(@cSCALE AS VARCHAR(10)) + ')'
		END 

		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ','
		END

		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT ')'
	PRINT 'AS'
	PRINT '/*********************************************************************'
	PRINT '** Name              : ' + @TABLENAME + '_update_byid'
	PRINT '** Created by        : ' + @USERNAME
	PRINT '** Date              : ' + CAST(@DATE as VARCHAR(17))
	PRINT '** Purpose           : ' + 'The purpose of this procedure is to update a '
	PRINT '**                   : ' + 'record in the ' + @TABLENAME + ' table by its primary key. '
	PRINT '**                   : ' + 'This procedure was automatically generated'
	PRINT '*********************************************************************/'
	PRINT 'SET NOCOUNT ON ' 
	PRINT ''	

	PRINT @IND + 'UPDATE ' + @TABLENAME		
	PRINT @IND + 'SET'	

	--Set the values 
	SET @COUNTER = 0
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS WHERE isPrimaryKey = 0	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 
		WHERE
   			isPrimaryKey = 0

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @TEMPSTRING =  @IND + @IND + UPPER(@cNAME) + ' = @'  + UPPER(@cNAME)
	
		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ','
		END
			
		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT @IND + 'WHERE'

	--Use the primary keys to update the table. 
	SET @COUNTER = 0 	
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS WHERE isPrimaryKey = 1

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 
		WHERE 
			isPrimaryKey = 1

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN

		SET @TEMPSTRING = @IND + @IND + UPPER(@cNAME) + ' = @' + UPPER(@cNAME)
 
		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ' and '
		END

		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT ''

	PRINT 'GO'

	/*******************************************************
	*******              Delete Sproc 		********
	*******************************************************/	
	PRINT 'IF EXISTS (SELECT name  FROM   sysobjects  WHERE  name = N''' + @TABLENAME + '_delete'' 	   AND 	  type = ''P'')'
        PRINT 'DROP PROCEDURE ' + @TABLENAME + '_delete'
	PRINT 'GO'
	PRINT 'CREATE PROCEDURE ' + @TABLENAME + '_delete'
	PRINT '('
	
	-- Add the parameters to the sproc		
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS WHERE isPrimaryKey = 1 	
	SET @COUNTER = 0 	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 
		WHERE 
			isPrimaryKey = 1 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @TEMPSTRING = @IND + '@' + UPPER(@cNAME) + ' ' + UPPER(@cTYPE) 

		--Add type specific data
		IF UPPER(@cTYPE) = 'VARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 

		IF UPPER(@cTYPE) = 'NVARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 

		IF UPPER(@cTYPE) = 'CHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 	

		IF UPPER(@cTYPE) = 'DECIMAL'
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cPRECISION AS VARCHAR(10)) + ',' + CAST(@cSCALE AS VARCHAR(10)) + ')'
		END 		

		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ','
		END

		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT ')'
	PRINT 'AS'
	PRINT '/*********************************************************************'
	PRINT '** Name              : ' + @TABLENAME + '_delete'
	PRINT '** Created by        : ' + @USERNAME
	PRINT '** Date              : ' + CAST(@DATE as VARCHAR(17))
	PRINT '** Purpose           : ' + 'The purpose of this procedure is to delete a '
	PRINT '**                   : ' + 'record from the ' + @TABLENAME + ' table using its primary key. '
	PRINT '**                   : ' + 'This procedure was automatically generated'
	PRINT '*********************************************************************/'
	PRINT 'SET NOCOUNT ON ' 
	PRINT ''	

	PRINT @IND + 'DELETE FROM ' + @TABLENAME		
	PRINT @IND + 'WHERE'	

	--Set the values 
	SET @COUNTER = 0
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS WHERE isPrimaryKey = 1	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 
		WHERE
   			isPrimaryKey = 1

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @TEMPSTRING =  @IND + @IND + UPPER(@cNAME) + ' = @'  + UPPER(@cNAME)
	
		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ' and '
		END
			
		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT ''

	PRINT 'GO'

	/*******************************************************
	*******              Select Sproc 		********
	*******************************************************/	
	PRINT 'IF EXISTS (SELECT name  FROM   sysobjects  WHERE  name = N''' + @TABLENAME + '_select_byid'' 	   AND 	  type = ''P'')'
        PRINT 'DROP PROCEDURE ' + @TABLENAME + '_select_byid'
	PRINT 'GO'
	PRINT ''
	
	PRINT 'CREATE PROCEDURE ' + @TABLENAME + '_select_byid'
	PRINT '('
	
	-- Add the parameters to the sproc		
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS WHERE isPrimaryKey = 1 
	SET @COUNTER = 0 	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 
		WHERE
			isPrimaryKey = 1 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @TEMPSTRING = @IND + '@' + UPPER(@cNAME) + ' ' + UPPER(@cTYPE) 

		--Add type specific data
		IF UPPER(@cTYPE) = 'VARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 

		IF UPPER(@cTYPE) = 'NVARCHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 

		IF UPPER(@cTYPE) = 'CHAR'
		BEGIN 
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cLENGTH AS VARCHAR(10)) + ')'
		END 			

		IF UPPER(@cTYPE) = 'DECIMAL'
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + '(' + CAST(@cPRECISION AS VARCHAR(10)) + ',' + CAST(@cSCALE AS VARCHAR(10)) + ')'
		END 

		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ','
		END

		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT ')'
	PRINT 'AS'
	PRINT '/*********************************************************************'
	PRINT '** Name              : ' + @TABLENAME + '_select_byid'
	PRINT '** Created by        : ' + @USERNAME
	PRINT '** Date              : ' + CAST(@DATE as VARCHAR(17))
	PRINT '** Purpose           : ' + 'The purpose of this procedure is to select a '
	PRINT '**                   : ' + 'record in the ' + @TABLENAME + ' table by its primary key. '
	PRINT '**                   : ' + 'This procedure was automatically generated'
	PRINT '*********************************************************************/'
	PRINT 'SET NOCOUNT ON ' 
	PRINT ''	

	PRINT @IND + 'SELECT' 

	--Set the values 
	SET @COUNTER = 0
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @TEMPSTRING =  @IND + @IND + UPPER(@cNAME)
	
		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ','
		END
			
		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT @IND + 'FROM'
	PRINT @IND + @IND + @TABLENAME
	PRINT @IND + 'WHERE'

	--Use the primary keys to update the table. 
	SET @COUNTER = 0 	
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS WHERE isPrimaryKey = 1

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 
		WHERE 
			isPrimaryKey = 1

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN

		SET @TEMPSTRING = @IND + @IND + UPPER(@cNAME) + ' = @' + UPPER(@cNAME)
 
		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ' and '
		END

		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT ''

	PRINT 'GO'

	/*******************************************************
	*******              Select All Sproc	 		********
	*******************************************************/	
	PRINT 'IF EXISTS (SELECT name  FROM   sysobjects  WHERE  name = N''' + @TABLENAME + '_select_all'' 	   AND 	  type = ''P'')'
        PRINT 'DROP PROCEDURE ' + @TABLENAME + '_select_all'
	PRINT 'GO'
	PRINT 'CREATE PROCEDURE ' + @TABLENAME + '_select_all'
	PRINT 'AS'
	PRINT '/*********************************************************************'
	PRINT '** Name              : ' + @TABLENAME + '_select_all'
	PRINT '** Created by        : ' + @USERNAME
	PRINT '** Date              : ' + CAST(@DATE as VARCHAR(17))
	PRINT '** Purpose           : ' + 'The purpose of this procedure is to select all '
	PRINT '**                   : ' + 'records in the ' + @TABLENAME
	PRINT '**                   : ' + 'This procedure was automatically generated'
	PRINT '*********************************************************************/'
	PRINT 'SET NOCOUNT ON ' 
	PRINT ''	

	PRINT @IND + 'SELECT' 

	--Set the values 
	SET @COUNTER = 0
	SELECT @cPARAMTERCOUNT = COUNT(*) FROM #PARAMETERS	

	DECLARE parameter_cursor CURSOR FAST_FORWARD READ_ONLY FOR 
		SELECT 
			[name],
			[type],
			length,
			[precision], 
			[scale],
			[isIdentity],
			[isPrimaryKey]
		FROM #PARAMETERS 

	OPEN parameter_cursor 
	
	FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		SET @TEMPSTRING =  @IND + @IND + UPPER(@cNAME)
	
		SET @COUNTER = @COUNTER + 1 
		IF @COUNTER <> 	@cPARAMTERCOUNT
		BEGIN
			SET @TEMPSTRING = @TEMPSTRING + ','
		END
			
		PRINT @TEMPSTRING

		FETCH NEXT FROM parameter_cursor INTO @cNAME,@cTYPE,@cLENGTH,@cPRECISION,@cSCALE,@cISIDENTITY,@cISPRIMARYKEY		
	END 

	CLOSE parameter_cursor
	DEALLOCATE parameter_cursor

	PRINT @IND + 'FROM'
	PRINT @IND + @IND + @TABLENAME

	PRINT ''

	PRINT 'GO'

	/**************** CLEAN UP *********************/

	DROP TABLE #PARAMETERS

SET NOCOUNT OFF