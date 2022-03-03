USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spWorkflow_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spWorkflow_CRUD_Records'

IF OBJECT_ID('[dbo].[spWorkflow_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spWorkflow_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Workflow | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spWorkflow_CRUD_Records @pvOptionCRUD = 'C', 
									@pvIdWorkflowType = 'WF-CP', 
									@piIdWorkflowStatus = 100, 
									@piIdWorkflowStatusChange = 100, 
									@pvRecordIdentifier = 'Fe0f83b46-a9d5-460e-818a-ae415a060af0', 
									@pvComments = 'prueba',  
									@pvUser = 'AZEPEDA', 
									@pvIP ='192.168.1.254'

			spWorkflow_CRUD_Records @pvOptionCRUD = 'R', @pvRecordIdentifier = 'b2cc07ec-647c-439f-bee8-17981a7cf0bf'
			spWorkflow_CRUD_Records @pvOptionCRUD = 'R', @piIdWorkflow = 97
			spWorkflow_CRUD_Records @pvOptionCRUD = 'R', @pvIdWorkflowType = 'WF-CP'
			spWorkflow_CRUD_Records @pvOptionCRUD = 'R', @piIdWorkflowStatus = 5, @piIdWorkflowStatusChange = 10
			
			spWorkflow_CRUD_Records @pvOptionCRUD = 'U'
			spWorkflow_CRUD_Records @pvOptionCRUD = 'D'

*/
CREATE PROCEDURE [dbo].spWorkflow_CRUD_Records
@pvOptionCRUD				Varchar(1),
@piIdWorkflow				Numeric     = 0,
@pvIdWorkflowType			Varchar(50)	= '',
@piIdWorkflowStatus			SmallInt	= 0,
@piIdWorkflowStatusChange	SmallInt	= 0,
@pvRecordIdentifier			Varchar(50) = '',
@pvComments					Varchar(MAX)= '',
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY

	--------------------------------------------------------------------
	--Variables for Work
	--------------------------------------------------------------------
	DECLARE @vTableIdentifier		VARCHAR(MAX) = (SELECT Table_Identifier FROM Cat_Workflow_Type WHERE Id_Workflow_Type = @pvIdWorkflowType)
	DECLARE @vQueryTableIdentifier	VARCHAR(MAX) = ''
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Workflow - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spWorkflow_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @piIdWorkflow = '" + ISNULL(CAST(@piIdWorkflow AS VARCHAR),'NULL') + "', @pvIdWorkflowType = '" + ISNULL(CAST(@pvIdWorkflowType AS VARCHAR),'NULL') + "', @piIdWorkflowStatus = '" + ISNULL(CAST(@piIdWorkflowStatus AS VARCHAR),'NULL') + "', , @piIdWorkflowStatusChange = '" + ISNULL(CAST(@piIdWorkflowStatusChange AS VARCHAR),'NULL') + "', @pvRecordIdentifier = '" + ISNULL(@pvRecordIdentifier,'NULL') + "', @pvComments = '" + ISNULL(@pvComments,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		INSERT INTO Workflow 
			(Id_Workflow_Type,
			Id_Workflow_Status,
			Id_Workflow_Status_Change,
			Record_Identifier,
			Comments,
			Register_Date,
			[User])
		VALUES 
			(@pvIdWorkflowType,
			@piIdWorkflowStatus,
			@piIdWorkflowStatusChange,
			@pvRecordIdentifier,
			@pvComments,
			GETDATE(),
			@pvUser)

		SET @piIdWorkflow = @@IDENTITY

		--Atualiza Tabla Referencia
		SET @vQueryTableIdentifier = REPLACE(@vTableIdentifier, '@piIdWorkflow', CAST(@piIdWorkflow AS VARCHAR))
		SET @vQueryTableIdentifier = REPLACE(@vQueryTableIdentifier, '@pvRecordIdentifier',@pvRecordIdentifier)
		PRINT @vQueryTableIdentifier
		EXECUTE(@vQueryTableIdentifier)

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			W.Id_Workflow,
			W.Id_Workflow_Type,
			Workflow_Type_Desc = WT.Short_Desc,
			W.Id_Workflow_Status,
			Workflow_Status_Desc = ST.Short_Desc,
			W.Id_Workflow_Status_Change,
			Workflow_Status_Change_Desc = STC.Short_Desc,
			W.Record_Identifier,
			W.Comments,
			W.Register_Date,
			W.[User]
		
		FROM Workflow W

		INNER JOIN Cat_Workflow_Type WT ON 
		W.Id_Workflow_Type = WT.Id_Workflow_Type

		INNER JOIN Cat_Workflow_Status ST ON 
		W.Id_Workflow_Status = ST.Id_Workflow_Status

		INNER JOIN Cat_Workflow_Status STC ON 
		W.Id_Workflow_Status_Change = STC.Id_Workflow_Status


		WHERE 
			(@piIdWorkflow				= 0  OR  W.Id_Workflow = @piIdWorkflow)	AND
			(@pvIdWorkflowType			= '' OR W.Id_Workflow_Type = @pvIdWorkflowType) AND
			(@piIdWorkflowStatus		= 0  OR W.Id_Workflow_Status = @piIdWorkflowStatus)	AND 
			(@piIdWorkflowStatusChange 	= 0  OR W.Id_Workflow_Status_Change = @piIdWorkflowStatusChange) AND 
			(@pvRecordIdentifier		= '' OR W.Record_Identifier = @pvRecordIdentifier)
			
			
		ORDER BY  W.Id_Workflow
		
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
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog, IdWorkflow = @piIdWorkflow FROM vwSecurityCodes WHERE Code = @iCode

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
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog, IdWorkflow = @piIdWorkflow FROM vwSecurityCodes WHERE Code = @iCode
		
END CATCH