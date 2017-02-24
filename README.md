# sql-server-useful-scripts
A repository for useful Microsoft SQL Server Scripts

## Stored Procudures 

### sp_generate_sprocs 

A stored procedure that generates CRUD stored procedures for a table. To use install in your master DB and then 
in the database you are interested in run:

```
sp_generate_sprocs '<your table>', '<your name'

sp_generate_sprocs 'Customer', 'Rick Sanchez' 
```

The output is printed. 

### sp_helpcol

A stored procudure that looks for instances of a column name within the database and then prints a list of tables
that have that column name. Useful for navigating a database where the foreign keys may not exist. Install in 
your master db. Then run:

```
sp_helpcol '<column name>' 

sp_helpcol 'CustomerId'
```

It is also useful to wire into you commands list in SQL Server Management Studio


## Scripts

### Table Dependency Calculator

A script which will work out the order in which tables in your database can be deleted from. It is usefull for creating 
delete scripts that without having to drop foreign keys. Simply run the script and you will get a list of all your tables
in the correct order you can delete from them. 
