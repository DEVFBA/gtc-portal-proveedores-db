USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Invoice_Types_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Invoice_Types_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Invoice_Types_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spCat_Invoice_Types_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Invoice_Types | Create - Read - Upadate - Delete 
Date:		02/02/2022
Example:
			spCat_Invoice_Types_CRUD_Records @pvOptionCRUD = 'C', @pvIdInvoiceType = 'ENG', @pvIdWorkflowType = 'WF-CP', @pvShortDesc = 'Invoice Type', @pvLongDesc = 'Invoice Type long', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Invoice_Types_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Invoice_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdInvoiceType = 'ENG'
			spCat_Invoice_Types_CRUD_Records @pvOptionCRUD = 'R', @pvShortDesc = 'Invoice' 
			spCat_Invoice_Types_CRUD_Records @pvOptionCRUD = 'U', @pvIdInvoiceType = 'ENG', @pvIdWorkflowType = 'WF-CP', @pvShortDesc = 'InvoiceType', @pvLongDesc = 'InvoiceType long', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Invoice_Types_CRUD_Records @pvOptionCRUD = 'D'

*/
CREATE PROCEDURE [dbo].spCat_Invoice_Types_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdInvoiceType	Varchar(10)	= '',
@pvIdWorkflowType	Varchar(10)	= '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
@pbStatus			Bit			= 1,
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Cat_Invoice_Types - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_Invoice_Types_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',@pvIdInvoiceType = '" + ISNULL(CAST(@pvIdInvoiceType AS VARCHAR),'NULL') + "',  @pvIdWorkflowType = '" + ISNULL(CAST(@pvIdWorkflowType AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Invoice_Types WHERE Id_Invoice_Type = @pvIdWorkflowType)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don�t Exists
		BEGIN
			INSERT INTO Cat_Invoice_Types 
			   (Id_Invoice_Type,
				Id_Workflow_Type,
				Short_Desc,
				Long_Desc,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@pvIdInvoiceType,
				@pvIdWorkflowType,
				@pvShortDesc,
				@pvLongDesc,
				@pbStatus,
				@pvUser,
				GETDATE(),
				@pvIP)

		END 
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		WS.Id_Workflow_Type,
		Workflow_Type_Desc = WT.Short_Desc,
		WS.Id_Invoice_Type,
		WS.Short_Desc,
		WS.Long_Desc,
		WS.[Status],
		WS.Modify_Date,
		WS.Modify_By,
		WS.Modify_IP
		FROM Cat_Invoice_Types WS

		INNER JOIN Cat_Workflow_Type WT ON 
		WS.Id_Workflow_Type = WT.Id_Workflow_Type

		WHERE 
			(@pvIdInvoiceType	= '' OR WS.Id_Invoice_Type = @pvIdInvoiceType) AND
			(@pvIdWorkflowType= 0  OR WS.Id_Workflow_Type = @pvIdWorkflowType) AND			
			(@pvShortDesc		= '' OR WS.Short_Desc LIKE '%' +  @pvShortDesc + '%')	
		ORDER BY  WS.Id_Invoice_Type, WS.Id_Workflow_Type
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Invoice_Types
		SET Id_Workflow_Type	= @pvIdWorkflowType,
			Short_Desc			= @pvShortDesc,
			Long_Desc			= @pvLongDesc,
			[Status]			= @pbStatus,
			Modify_By			= @pvUser,
			Modify_Date			= GETDATE(),
			Modify_IP			= @pvIP
		WHERE Id_Invoice_Type = @pvIdInvoiceType
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