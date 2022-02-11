USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spWorkflow_Tracker_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spWorkflow_Tracker_CRUD_Records'

IF OBJECT_ID('[dbo].[spWorkflow_Tracker_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spWorkflow_Tracker_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Workflow_Tracker | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spWorkflow_Tracker_CRUD_Records @pvOptionCRUD = 'C', @pvIdWorkflowType = 'WF-CP', @piIdWorkflowStatus = 5, @piIdWorkflowStatusChange = 10, @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spWorkflow_Tracker_CRUD_Records @pvOptionCRUD = 'R'
			spWorkflow_Tracker_CRUD_Records @pvOptionCRUD = 'R', @piIdWorkflowTracker = 1
			spWorkflow_Tracker_CRUD_Records @pvOptionCRUD = 'R', @pvIdWorkflowType = 'WF-CP',@piIdWorkflowStatus = 10
			spWorkflow_Tracker_CRUD_Records @pvOptionCRUD = 'R', @piIdWorkflowStatus = 5, @piIdWorkflowStatusChange = 10
			spWorkflow_Tracker_CRUD_Records @pvOptionCRUD = 'U', @piIdWorkflowTracker = 1, @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP = '0.0.0.0'
			spWorkflow_Tracker_CRUD_Records @pvOptionCRUD = 'D', @piIdWorkflowTracker = 1, @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP = '0.0.0.0'

*/
CREATE PROCEDURE [dbo].spWorkflow_Tracker_CRUD_Records
@pvOptionCRUD				Varchar(1),
@piIdWorkflowTracker		Int			= 0,
@pvIdWorkflowType			Varchar(50)	= '',
@piIdWorkflowStatus			SmallInt	= 0,
@piIdWorkflowStatusChange	SmallInt	= 0,
@pbStatus					Bit			= 1,
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Workflow_Tracker - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spWorkflow_Tracker_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @piIdWorkflowTracker = '" + ISNULL(CAST(@piIdWorkflowTracker AS VARCHAR),'NULL') + "', @pvIdWorkflowType = '" + ISNULL(CAST(@pvIdWorkflowType AS VARCHAR),'NULL') + "', @piIdWorkflowStatus = '" + ISNULL(CAST(@piIdWorkflowStatus AS VARCHAR),'NULL') + "', , @piIdWorkflowStatusChange = '" + ISNULL(CAST(@piIdWorkflowStatusChange AS VARCHAR),'NULL') + "',  @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Workflow_Tracker WHERE Id_Workflow_Type = @pvIdWorkflowType AND Id_Workflow_Status = @piIdWorkflowStatus AND Id_Workflow_Status_Change = @piIdWorkflowStatusChange)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN

			SET @piIdWorkflowTracker = (SELECT ISNULL(MAX(Id_Workflow_Tracker),0) + 1 FROM Workflow_Tracker)

			INSERT INTO Workflow_Tracker 
				(Id_Workflow_Tracker,
				Id_Workflow_Type,
				Id_Workflow_Status,
				Id_Workflow_Status_Change,
				Status,
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
				(@piIdWorkflowTracker,
				@pvIdWorkflowType,
				@piIdWorkflowStatus,
				@piIdWorkflowStatusChange,
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
			W.Id_Workflow_Tracker,
			W.Id_Workflow_Type,
			Workflow_Type_Desc = WT.Short_Desc,
			W.Id_Workflow_Status,
			Workflow_Status_Desc = ST.Short_Desc,
			W.Id_Workflow_Status_Change,
			Workflow_Status_Change_Desc = STC.Short_Desc,
			W.[Status],
			W.Modify_Date,
			W.Modify_By,
			W.Modify_IP
		
		FROM Workflow_Tracker W

		INNER JOIN Cat_Workflow_Type WT ON 
		W.Id_Workflow_Type = WT.Id_Workflow_Type

		INNER JOIN Cat_Workflow_Status ST ON 
		W.Id_Workflow_Status = ST.Id_Workflow_Status

		INNER JOIN Cat_Workflow_Status STC ON 
		W.Id_Workflow_Status_Change = STC.Id_Workflow_Status


		WHERE 
			(@piIdWorkflowTracker	= 0	 OR W.Id_Workflow_Tracker= @piIdWorkflowTracker)	AND
			(@pvIdWorkflowType		= '' OR W.Id_Workflow_Type	 = @pvIdWorkflowType) AND
			(@piIdWorkflowStatus	= 0  OR W.Id_Workflow_Status = @piIdWorkflowStatus)			
			
		ORDER BY  W.Id_Workflow_Type,Id_Workflow_Status,Id_Workflow_Status_Change
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
	
			UPDATE Workflow_Tracker 
			SET [Status]	= @pbStatus, 
				Modify_By	= @pvUser,
				Modify_Date	= GETDATE(),
				Modify_IP	= @pvIP
			WHERE Id_Workflow_Tracker = @piIdWorkflowTracker

	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
			DELETE Workflow_Tracker 
			WHERE Id_Workflow_Tracker = @piIdWorkflowTracker
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