USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spWorkflow_Notifications_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spWorkflow_Notifications_CRUD_Records'

IF OBJECT_ID('[dbo].[spWorkflow_Notifications_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spWorkflow_Notifications_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Workflow_Notifications | Create - Read - Upadate - Delete 
Date:		20/12/2021
Example:
			spWorkflow_Notifications_CRUD_Records @pvOptionCRUD = 'C', @piIdWorkflow = 81, @piIdNotification = 1, @pvTo= 'kelberoz@hotmail.com', @pvCC = 'al3j4ndr0.z3p3d4@gmail.com', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spWorkflow_Notifications_CRUD_Records @pvOptionCRUD = 'R'
			spWorkflow_Notifications_CRUD_Records @pvOptionCRUD = 'R', @pnIdMailNotification =1, @piIdWorkflow = 81, @piIdNotification = 'PDFINV'
			spWorkflow_Notifications_CRUD_Records @pvOptionCRUD = 'U', @pnIdMailNotification =1
		
			SELECT * FROM Workflow
			SELECT * FROM Cat_File_Types
*/
CREATE PROCEDURE [dbo].spWorkflow_Notifications_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pnIdMailNotification	numeric		= 0,
@piIdWorkflow			numeric		= 0,
@piIdNotification		Int			= 0,
@pvTo					varchar(255)= '',
@pvCC					varchar(255)= '',
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY

	DECLARE @bNotificationSend		bit			= 0
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Workflow_Notifications - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spWorkflow_Notifications_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @pnIdMailNotification = '" + ISNULL(CAST(@pnIdMailNotification AS VARCHAR),'NULL') + "',  @piIdWorkflow = '" + ISNULL(CAST(@piIdWorkflow AS VARCHAR),'NULL') + "', @piIdNotification = '" + ISNULL(CAST(@piIdNotification AS VARCHAR),'NULL') + "', @pvTo = '" + ISNULL(@pvTo,'NULL') + "',  @pvCC = '" + ISNULL(@pvCC,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			INSERT INTO Workflow_Notifications 
			   (Id_Workflow,
			    Id_Notification,
				[To],
				CC,
				Register_Date,
				Notification_Send)
			VALUES 
			   (@piIdWorkflow,
			    @piIdNotification,
				@pvTo,
				@pvCC,
				GETDATE(),
				@bNotificationSend)
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			WF.Id_Mail_Notification,
			WF.Id_Workflow,
			WF.Id_Notification,
			[Notification] = C.Short_Desc,
			WF.[To],
			WF.CC,
			WF.Register_Date,
			WF.Notification_Date,
			WF.Notification_Send
		FROM Workflow_Notifications WF 
		INNER JOIN Cat_Notifications C ON 
		WF.Id_Notification = C.Id_Notification AND 
		C.[Status] = 1

		WHERE 
			(@pnIdMailNotification	= 0 OR WF.Id_Mail_Notification = @pnIdMailNotification) AND
			(@piIdWorkflow			= 0 OR WF.Id_Workflow = @piIdWorkflow) AND
			(@piIdNotification		= 0 OR WF.Id_Notification = @piIdNotification) 
			
		ORDER BY  Id_Mail_Notification
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET @bNotificationSend = 1

		UPDATE Workflow_Notifications
		SET Notification_Date = GETDATE(),
			Notification_Send = @bNotificationSend
		WHERE Id_Mail_Notification = @pnIdMailNotification
		
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