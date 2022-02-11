USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spWorkflow_Tracker_Roles_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spWorkflow_Tracker_Roles_CRUD_Records'

IF OBJECT_ID('[dbo].[spWorkflow_Tracker_Roles_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spWorkflow_Tracker_Roles_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Workflow_Tracker_Roles | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD = 'C', @pvIdRole = 'ADMIN', @piIdWorkflowTracker = 1, @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD = 'R'
			spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'ADMIN'
			spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'ADMIN', @pvIdWorkflowType = 'WF-CP', @piIdWorkflowStatus = 100
			spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'ADMIN', @piIdWorkflowTracker = 1

			spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD = 'U', @pvIdRole = 'ADMIN', @piIdWorkflowTracker = 1, @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP = '0.0.0.0'
			spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD = 'D', @pvIdRole = 'ADMIN', @piIdWorkflowTracker = 1, @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP = '0.0.0.0'

			me puede
*/
CREATE PROCEDURE [dbo].spWorkflow_Tracker_Roles_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvIdRole					Varchar(10)	= '',
@piIdWorkflowTracker		Int			= 0,
@pvIdWorkflowType			Varchar(50)	= '',
@piIdWorkflowStatus			SmallInt	= 0,
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
	DECLARE @vDescription		Varchar(255)	= 'Workflow_Tracker_Roles - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spWorkflow_Tracker_Roles_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @pvIdRole =  '" + ISNULL(@pvIdRole,'NULL') + "', @piIdWorkflowTracker = '" + ISNULL(CAST(@piIdWorkflowTracker AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN

			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Workflow_Tracker_Roles WHERE Id_Role = @pvIdRole AND Id_Workflow_Tracker = @piIdWorkflowTracker )
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN

			INSERT INTO Workflow_Tracker_Roles 
				(Id_Role,
				Id_Workflow_Tracker,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
				(@pvIdRole,
				@piIdWorkflowTracker,
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
		    WR.Id_Role, 
			Id_Role_Desc = R.Short_Desc,
			W.Id_Workflow_Tracker,
			W.Id_Workflow_Type,
			Workflow_Type_Desc = WT.Short_Desc,
			W.Id_Workflow_Status,
			Workflow_Status_Desc = ST.Short_Desc,
			W.Id_Workflow_Status_Change,
			Workflow_Status_Change_Desc = STC.Short_Desc,
			WR.[Status],
			W.Modify_Date,
			W.Modify_By,
			W.Modify_IP
		
		FROM Workflow_Tracker_Roles WR

		INNER JOIN Security_Roles R ON
		WR.Id_Role = R.Id_Role 

		INNER JOIN Workflow_Tracker W ON 
		WR.Id_Workflow_Tracker = W.Id_Workflow_Tracker

		INNER JOIN Cat_Workflow_Type WT ON 
		W.Id_Workflow_Type = WT.Id_Workflow_Type


		INNER JOIN Cat_Workflow_Status ST ON 
		W.Id_Workflow_Status = ST.Id_Workflow_Status AND
		W.Id_Workflow_Type = ST.Id_Workflow_Type 

		INNER JOIN Cat_Workflow_Status STC ON 
		W.Id_Workflow_Status_Change = STC.Id_Workflow_Status AND
		W.Id_Workflow_Type = STC.Id_Workflow_Type 

		WHERE 
			(@piIdWorkflowTracker	= 0	 OR WR.Id_Workflow_Tracker= @piIdWorkflowTracker)	AND
			(@pvIdRole				= '' OR WR.Id_Role	 = @pvIdRole) AND
			(@pvIdWorkflowType		= '' OR W.Id_Workflow_Type	 = @pvIdWorkflowType) AND
			(@piIdWorkflowStatus	= 0  OR W.Id_Workflow_Status = @piIdWorkflowStatus)	AND 
			(W.Id_Workflow_Status_Change <> @piIdWorkflowStatus) 
		ORDER BY  WR.Id_Role, W.Id_Workflow_Type,Id_Workflow_Status,Id_Workflow_Status_Change
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
	
			UPDATE Workflow_Tracker_Roles 
			SET	[Status]	= @pbStatus, 
				Modify_By	= @pvUser,
				Modify_Date	= GETDATE(),
				Modify_IP	= @pvIP
			WHERE 
				Id_Role = @pvIdRole AND Id_Workflow_Tracker = @piIdWorkflowTracker

	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
			DELETE Workflow_Tracker_Roles 
			WHERE Id_Role = @pvIdRole AND Id_Workflow_Tracker = @piIdWorkflowTracker
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