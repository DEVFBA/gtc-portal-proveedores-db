USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spWorkflow_Tracker_Notifications_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spWorkflow_Tracker_Notifications_CRUD_Records'

IF OBJECT_ID('[dbo].[spWorkflow_Tracker_Notifications_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spWorkflow_Tracker_Notifications_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Workflow_Tracker_Notifications | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spWorkflow_Tracker_Notifications_CRUD_Records @pvOptionCRUD = 'C', @piIdWorkflowTracker = 1, @piIdNotification = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spWorkflow_Tracker_Notifications_CRUD_Records @pvOptionCRUD = 'R'
			spWorkflow_Tracker_Notifications_CRUD_Records @pvOptionCRUD = 'R', @piIdWorkflowTracker = 1, @piIdNotification = 1
			spWorkflow_Tracker_Notifications_CRUD_Records @pvOptionCRUD = 'U', @piIdWorkflowTracker = 1, @piIdNotification = 1
			spWorkflow_Tracker_Notifications_CRUD_Records @pvOptionCRUD = 'D', @piIdWorkflowTracker = 1, @piIdNotification = 1
			
			SELECT * FROM Workflow_Tracker
			SELECT * FROM Cat_Notifications
*/
CREATE PROCEDURE [dbo].spWorkflow_Tracker_Notifications_CRUD_Records
@pvOptionCRUD		 Varchar(1),
@piIdWorkflowTracker Numeric	 = 0,
@piIdNotification	 Int		 = 0,
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
	DECLARE @vDescription		Varchar(255)	= 'Workflow_Tracker_Notifications - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spWorkflow_Tracker_Notifications_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @piIdWorkflowTracker = '" + ISNULL(CAST(@piIdWorkflowTracker AS VARCHAR),'NULL') + "', @piIdNotification = '" + ISNULL(CAST(@piIdNotification AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Workflow_Tracker_Notifications WHERE Id_Workflow_Tracker = @piIdWorkflowTracker AND Id_Notification = @piIdNotification )
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Workflow_Tracker_Notifications 
			   (Id_Workflow_Tracker,
			    Id_Notification,
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@piIdWorkflowTracker,
			    @piIdNotification,
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
		WF.Id_Workflow_Tracker,
		WF.Id_Notification,
		[Notification] = C.Short_Desc,
		WF.Modify_Date,
		WF.Modify_By,
		WF.Modify_IP
		FROM Workflow_Tracker_Notifications WF 
		INNER JOIN Cat_Notifications C ON 
		WF.Id_Notification = C.Id_Notification AND 
		C.[Status] = 1

		WHERE 
			(@piIdWorkflowTracker	= 0  OR WF.Id_Workflow_Tracker = @piIdWorkflowTracker) AND
			(@piIdNotification		= '' OR WF.Id_Notification = @piIdNotification) 
			
		ORDER BY  Id_Notification
		
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
		DELETE Workflow_Tracker_Notifications
		WHERE Id_Workflow_Tracker = @piIdWorkflowTracker AND
		      Id_Notification = @piIdNotification
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