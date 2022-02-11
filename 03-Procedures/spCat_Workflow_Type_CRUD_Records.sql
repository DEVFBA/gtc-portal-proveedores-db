USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Workflow_Type_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Workflow_Type_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Workflow_Type_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spCat_Workflow_Type_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Workflow_Type | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spCat_Workflow_Type_CRUD_Records @pvOptionCRUD = 'C', @pvIdWorkflowType = 'WF-CP' , @pvShortDesc = 'Workflow Carta Porte', @pvLongDesc = 'Workflow para el proceso de la Carta Porte de los clientes',  @pvTableIdentifier = 'Carta_Porte', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Workflow_Type_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Workflow_Type_CRUD_Records @pvOptionCRUD = 'R', @pvIdWorkflowType = 'WF-CP'
			spCat_Workflow_Type_CRUD_Records @pvOptionCRUD = 'R', @pvShortDesc = 'Workflow Carta Porte' 
			spCat_Workflow_Type_CRUD_Records @pvOptionCRUD = 'U', @pvIdWorkflowType = 'WF-CP' , @pvShortDesc = 'Workflow Carta Porte', @pvLongDesc = 'Workflow para el proceso de la Carta Porte de los clientes',  @pvTableIdentifier = 'Carta_Porte', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Workflow_Type_CRUD_Records @pvOptionCRUD = 'D'

*/
CREATE PROCEDURE [dbo].spCat_Workflow_Type_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdWorkflowType	Varchar(50)	= '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
@pvTableIdentifier	Varchar(255)= '',
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
	DECLARE @vDescription		Varchar(255)	= 'Cat_Workflow_Type - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_Workflow_Type_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdWorkflowType = '" + ISNULL(CAST(@pvIdWorkflowType AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "',  @pvTableIdentifier = '" + ISNULL(@pvTableIdentifier,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Workflow_Type WHERE Id_Workflow_Type = @pvIdWorkflowType)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Cat_Workflow_Type 
			   (Id_Workflow_Type,
				Short_Desc,
				Long_Desc,
				Status,
				Table_Identifier,
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@pvIdWorkflowType,
				@pvShortDesc,
				@pvLongDesc,
				@pbStatus,
				@pvTableIdentifier,
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
		Id_Catalog = Id_Workflow_Type,
		Short_Desc,
		Long_Desc,
		[Status],
		Table_Identifier,
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM Cat_Workflow_Type 
		WHERE 
			(@pvIdWorkflowType	= '' OR Id_Workflow_Type = @pvIdWorkflowType) AND
			(@pvShortDesc	= '' OR Short_Desc LIKE '%' +  @pvShortDesc + '%')	
		ORDER BY  Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Workflow_Type
		SET Short_Desc			= @pvShortDesc,
			Long_Desc			= @pvLongDesc,
			Table_Identifier	= @pvTableIdentifier,
			[Status]			= @pbStatus,
			Modify_By			= @pvUser,
			Modify_Date			= GETDATE(),
			Modify_IP			= @pvIP
		WHERE Id_Workflow_Type = @pvIdWorkflowType
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