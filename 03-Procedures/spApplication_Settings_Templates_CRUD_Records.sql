USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spApplication_Settings_Templates_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spApplication_Settings_Templates_CRUD_Records'

IF OBJECT_ID('[dbo].[spApplication_Settings_Templates_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spApplication_Settings_Templates_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Application_Settings | Create - Read - Upadate - Delete 
Date:		12/02/2022
Example:


			EXEC spApplication_Settings_Templates_CRUD_Records @pvOptionCRUD = 'C', @piIdApplication = 1, @pvSettingsKey = 'SMTPServer', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			EXEC spApplication_Settings_Templates_CRUD_Records @pvOptionCRUD = 'R', @piIdApplication = 1
			
			EXEC spApplication_Settings_Templates_CRUD_Records @pvOptionCRUD = 'R', @piIdApplication = 1, @pvSettingsKey = 'SMTPServer'
			
			EXEC spApplication_Settings_Templates_CRUD_Records @pvOptionCRUD = 'U'
			
			EXEC spApplication_Settings_Templates_CRUD_Records @pvOptionCRUD = 'D' 


*/
CREATE PROCEDURE [dbo].spApplication_Settings_Templates_CRUD_Records
@pvOptionCRUD				Varchar(1),
@piIdApplication			Int			= 0,
@pvSettingsKey				Varchar(50) = '',
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Application_Settings_Templates - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spApplication_Settings_Templates_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdApplication = '" + ISNULL(CAST(@piIdApplication AS VARCHAR),'NULL') + "', @pvSettingsKey = '" + ISNULL(@pvSettingsKey,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		SET @iCode	= dbo.fnGetCodes('Invalid Option')	
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT  S.Id_Application,
				Application_Desc = A.Short_Desc,
				S.Settings_Key,
				S.Settings_Name,
				S.Settings_Default_Value,
				S.Allow_Edit,
				S.[Required],
				S.[Use],
				S.Regular_Expression,
				S.Tooltip,
				S.Modify_By,
				S.Modify_Date,
				S.Modify_IP
		FROM Setting_Templates S
		INNER JOIN Cat_Applications A ON 
		S.Id_Application = A.Id_Application
		WHERE 
		(@piIdApplication	= 0		OR S.Id_Application = @piIdApplication) AND
		(@pvSettingsKey		= ''	OR S.Settings_Key = @pvSettingsKey)
		ORDER BY Id_Application, Settings_Key 		
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