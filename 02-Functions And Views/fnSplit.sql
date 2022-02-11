USE PortalProveedores

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- fnSplit
/* ==================================================================================*/	
PRINT 'Crea fnSplit'

IF OBJECT_ID('[dbo].[fnSplit]','TF') IS NOT NULL
       DROP FUNCTION [dbo].[fnSplit]
GO


/*
Author		: Alejandro Zepeda
Descrption	: Returns "n" records according to the assigned separato
Creation	: 23-10-2021

Example: fbSplit(Cadena,Delimitador)
Select VALOR from fnSplit('Valor1|Valor2|Valor3|','|')

Select * from fnSplit('FONDEO-BFI-S-210127-193845-2674144',',')
*/
CREATE FUNCTION [dbo].[fnSplit](
@sInputList VARCHAR(MAX),
@sDelimiter CHAR(1)  
) RETURNS @List TABLE (Id INT IDENTITY,Valor VARCHAR(MAX))
WITH ENCRYPTION AS
BEGIN
DECLARE @sItem VARCHAR(MAX)
WHILE CHARINDEX(@sDelimiter,@sInputList,0) <> 0
 BEGIN
 SELECT
  @sItem=RTRIM(LTRIM(SUBSTRING(@sInputList,1,CHARINDEX(@sDelimiter,@sInputList,0)-1))),
  @sInputList=RTRIM(LTRIM(SUBSTRING(@sInputList,CHARINDEX(@sDelimiter,@sInputList,0)+LEN(@sDelimiter),LEN(@sInputList))))
 
 IF LEN(@sItem) > 0
  INSERT INTO @List SELECT @sItem
 END

IF LEN(@sInputList) > 0
 INSERT INTO @List SELECT @sInputList 
RETURN
END
