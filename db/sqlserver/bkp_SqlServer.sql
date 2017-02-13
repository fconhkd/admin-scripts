DECLARE @name VARCHAR(150) -- Nome do Database  
DECLARE @path VARCHAR(256) -- Caminho do arquivo de backup
DECLARE @fileName VARCHAR(256) -- Arquivo do backup  
DECLARE @data VARCHAR(10)

-- Data de hoje YYYY.MM.DD
SET @data = (select CONVERT(VARCHAR(10), GETDATE(), 104))
-- Define caminho de destino do backup
SET @path = 'D:\MSSQL\Backup\'  

-- Cria um cursor para selecionar todas as databases,  
--  excluindo model, msdb e tempdb
DECLARE db_cursor CURSOR FOR  
   SELECT name 
     FROM master.dbo.sysdatabases 
    WHERE name NOT IN ('model','msdb','tempdb')  

-- Abre o cursor e faz a primeira leitura 
OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

-- Loop de leitura das databases selecionadas
WHILE @@FETCH_STATUS = 0   
BEGIN   
   SET @fileName = @path + @data +'_'+@name + '.BAK'  
   -- Executa o backup para o database
   BACKUP DATABASE @name TO DISK = @fileName WITH FORMAT;  

   FETCH NEXT FROM db_cursor INTO @name   
END   

-- Libera recursos alocados pelo cursor
CLOSE db_cursor   
DEALLOCATE db_cursor 

--HISTADIN D renite, irritado, corrisa