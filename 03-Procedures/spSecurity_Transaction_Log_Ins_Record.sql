USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Transaction_Log_Ins_Record
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Transaction_Log_Ins_Record'

IF OBJECT_ID('[dbo].[spSecurity_Transaction_Log_Ins_Record]','P') IS NOT NULL
       DROP PROCEDURE [dbo].[spSecurity_Transaction_Log_Ins_Record]
GO

/*
Author:		Alejandro Zepeda
Desc:		Register Log
Date:		23/10/2021
Example:	
			DECLARE @nIdTransacLog NUMERIC
			EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription	= 'Security_Access - Read Records', 
														@pvExecCommand	= 'EXEC spSecurity_Access_CRUD_Records ',
														@piCode	= 1200, 
														@pvExceptionMessage = '',
														@pvUser			= 'AZEPEDA', 
														@pnIdTransacLog	= @nIdTransacLog OUTPUT
			SELECT @nIdTransacLog
			
			select * from Security_Transaction_Log 
*/
CREATE PROCEDURE [dbo].[spSecurity_Transaction_Log_Ins_Record]
@pvDescription		VARCHAR(255),
@pvExecCommand		VARCHAR(MAX),
@piCode				Smallint,
@pvExceptionMessage	VARCHAR(MAX),
@pvUser				VARCHAR(20),
@pnIdTransacLog		NUMERIC OUTPUT
WITH ENCRYPTION
AS
SET NOCOUNT ON

	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @vCodeClassification	Varchar(50)
	DECLARE	@vCodeType				Varchar(30)
	DECLARE	@vCodeMessage			Varchar(MAX)
	DECLARE	@bCodeSuccessful		Bit

	--------------------------------------------------------------------
	--Get Code Properties 
	--------------------------------------------------------------------
	SELECT	@vCodeClassification = CodeClassification.Short_Desc,
			@vCodeType			 = CodeTypes.Short_Desc,
			@vCodeMessage		 = Code.[Description_User],
			@bCodeSuccessful	 = CodeTypes.Successful
	FROM Security_Codes Code
	
	INNER JOIN Security_Code_Types CodeTypes ON
	Code.Id_Code_Type = CodeTypes.Id_Code_Type

	INNER JOIN Security_Code_Classification CodeClassification ON
	Code.Id_Code_Classification = CodeClassification.Id_Code_Classification

	WHERE Code = @piCode 


	--------------------------------------------------------------------
	--Insert Transaction Log
	--------------------------------------------------------------------
	INSERT INTO Security_Transaction_Log(
			[Description],
			Register_Date,
			Exec_Command,
			Code,
			Code_Classification,
			Code_Type,
			Code_Message,
			Code_Successful,
			Exception_Message,
			[User])
			
	VALUES(	@pvDescription,
			GETDATE(),
			@pvExecCommand,
			@piCode,
			@vCodeClassification,
			@vCodeType,
			@vCodeMessage,
			@bCodeSuccessful,
			@pvExceptionMessage,
			@pvUser)
		
			
	SET @pnIdTransacLog =  @@IDENTITY

RETURN
