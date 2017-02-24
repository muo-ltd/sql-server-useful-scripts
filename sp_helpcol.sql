SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[sp_helpcol]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[sp_helpcol]
GO

CREATE PROCEDURE sp_helpcol
(
	@ColumnName NVARCHAR(50)
)
AS 
SET NOCOUNT ON 

	SELECT 
		st.name,
		(CASE 
			WHEN st.type = 'u' THEN 'Table'
			WHEN st.type = 'v' THEN 'View'
		 END)
		 as [type]
	FROM 
		syscolumns sc INNER JOIN sysobjects st ON sc.id = st.id  		
	WHERE 
		sc.name = @ColumnName
	and st.type in ('u', 'v')

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

