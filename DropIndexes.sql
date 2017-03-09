
SELECT 
    'DROP INDEX [' + i.Name  + '] ON [' + s.Name + '].[' + t.NAME + ']' AS TableName,
    (SUM(a.total_pages) * 8) / 1024  AS TotalSpaceKB,
	p.rows,
	i.name
FROM 
	sys.tables t
	INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
    AND i.OBJECT_ID > 255 
	AND i.is_primary_key = 0
	AND i.is_unique_constraint = 0
	AND i.Name is not null
GROUP BY 
    t.Name, s.Name, p.rows, i.name
ORDER BY  SUM(a.total_pages) * 8 DESC



