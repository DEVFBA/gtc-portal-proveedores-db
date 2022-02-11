USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spWorkflow_Files_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spWorkflow_Files_CRUD_Records'

IF OBJECT_ID('[dbo].[spWorkflow_Files_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spWorkflow_Files_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Workflow_Files | Create - Read - Upadate - Delete 
Date:		20/12/2021
Example:
			spWorkflow_Files_CRUD_Records @pvOptionCRUD = 'C', @piIdWorkflow = 81, @pvIdFileType = 'PDFINV', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spWorkflow_Files_CRUD_Records @pvOptionCRUD = 'R'
			spWorkflow_Files_CRUD_Records @pvOptionCRUD = 'R', @piIdWorkflow = 81, @pvIdFileType = 'PDFINV'
			
			SELECT * FROM Workflow
			SELECT * FROM Cat_File_Types
*/
CREATE PROCEDURE [dbo].spWorkflow_Files_CRUD_Records
@pvOptionCRUD		 Varchar(1),
@piIdWorkflow		 Numeric		 = 0,
@pvIdFileType		 Varchar(10) = '',
@pvUser				 Varchar(50) = '',
@pvIP				 Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Workflow_Files - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spWorkflow_Files_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @piIdWorkflow = '" + ISNULL(CAST(@piIdWorkflow AS VARCHAR),'NULL') + "', @pvIdFileType = '" + ISNULL(CAST(@pvIdFileType AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Workflow_Files WHERE Id_Workflow = @piIdWorkflow AND Id_File_Type = @pvIdFileType )
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Workflow_Files 
			   (Id_Workflow,
			    Id_File_Type)
			VALUES 
			   (@piIdWorkflow,
			    @pvIdFileType)

		END 
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		WF.Id_Workflow,
		WF.Id_File_Type,
		File_Type = C.Short_Desc
		FROM Workflow_Files WF 
		INNER JOIN Cat_File_Types C ON 
		WF.Id_File_Type = C.Id_File_Type AND 
		C.[Status] = 1

		WHERE 
			(@piIdWorkflow	= 0  OR WF.Id_Workflow = @piIdWorkflow) AND
			(@pvIdFileType	= '' OR WF.Id_File_Type = @pvIdFileType) 
			
		ORDER BY  Id_File_Type
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET @iCode	= dbo.fnGetCodes('Invalid Option')			
	END
	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		SET @iCode	= dbo.fnGetCodes('Invalid Option')		
	END

	--------------------------------------------------------------------
	--Register Transaction Log
	--------------------------------------------------------------------
	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription		= @vDescription, 
												@pvExecCommand		= @vExecCommand,
												@piCode				= @iCode, 
												@pvExceptionMessage = @vExceptionMessage,
												@pvUser				= @pvUser, 
												@pnIdTransacLog		= @nIdTransacLog OUTPUT
	
	SET NOCOUNT OFF
	
	IF @pvOptionCRUD <> 'R'
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog FROM vwSecurityCodes WHERE Code = @iCode

END TRY
BEGIN CATCH
	--------------------------------------------------------------------
	-- Exception Handling
	--------------------------------------------------------------------
	SET @iCode					= dbo.fnGetCodes('Generic Error')
	SET @vExceptionMessage		= dbo.fnGetTransacErrorBD()

	EXEC spSecurity_Transaction_Log_Ins_Record	@pvDescription		= @vDescription, 
												@pvExecCommand		= @vExecCommand,
												@piCode				= @iCode, 
												@pvExceptionMessage = @vExceptionMessage,
												@pvUser				= @pvUser, 
												@pnIdTransacLog		= @nIdTransacLog OUTPUT
	
	SET NOCOUNT OFF
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog FROM vwSecurityCodes WHERE Code = @iCode
		
END CATCH