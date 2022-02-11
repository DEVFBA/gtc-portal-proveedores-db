USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Notifications_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Notifications_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Notifications_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spCat_Notifications_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Notifications | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spCat_Notifications_CRUD_Records @pvOptionCRUD = 'C', @piIdNotification = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Notifications_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Notifications_CRUD_Records @pvOptionCRUD = 'R', @piIdNotification = 1
			spCat_Notifications_CRUD_Records @pvOptionCRUD = 'U', @piIdNotification = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Notifications_CRUD_Records @pvOptionCRUD = 'D'

*/
CREATE PROCEDURE [dbo].spCat_Notifications_CRUD_Records
@pvOptionCRUD		Varchar(1),
@piIdNotification	Int = -1,
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
	DECLARE @vDescription		Varchar(255)	= 'Cat_Notifications - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_Notifications_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdFileType = '" + ISNULL(CAST(@piIdNotification AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		SET @iCode	= dbo.fnGetCodes('Invalid Option')	
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		Id_Notification,
		Short_Desc,
		[Subject],
		Template_Path,
		Images_Path,
		Specific_Frequency = isnull(Specific_Frequency,''),
		[Status]
		FROM Cat_Notifications 
		WHERE  (@piIdNotification = -1  OR Id_Notification = @piIdNotification) 
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