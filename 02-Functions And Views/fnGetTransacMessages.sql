USE PortalProveedores

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
/* ==================================================================================*/
-- fnGetTransacMessages
/* ==================================================================================*/	
PRINT 'Crea fnGetTransacMessages'

IF OBJECT_ID('[dbo].[fnGetTransacMessages]','FN') IS NOT NULL
       DROP FUNCTION [dbo].fnGetTransacMessages
GO

/*
Author:		Alejandro Zepeda
Desc:		Gets the type of Messages
Creation:	23-10-2021
Return 
			@vTransacMessage Varchar(255)
Example:	
			Declare @vTransacMessage Varchar(50)
			SET @vTransacMessage = dbo.fnGetTransacMessages(1101)
			SELECT @vTransacMessage
*/
CREATE FUNCTION [dbo].[fnGetTransacMessages](@piCode Int )
RETURNS VARCHAR(Max)
WITH ENCRYPTION AS
BEGIN
	Declare @vTransacMessage Varchar(255)
	
	SET @vTransacMessage = (SELECT Description_User FROM Security_Codes WHERE Code = @piCode )
	
	RETURN @vTransacMessage
END
GO

