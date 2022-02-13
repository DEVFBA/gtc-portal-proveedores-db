USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spApplication_Settings_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spApplication_Settings_CRUD_Records'

IF OBJECT_ID('[dbo].[spApplication_Settings_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spApplication_Settings_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Application_Settings | Create - Read - Upadate - Delete 
Date:		12/02/2022
Example:


			EXEC spApplication_Settings_CRUD_Records	@pvOptionCRUD = 'C', 
														@piIdApplication = 1,
														@pvSettingsKey = 'SMTPServer',
														@pvSettingsValue = 'smtp-mail.outlook.com',
														@pvUser = 'AZEPEDA', 
														@pvIP ='192.168.1.254'
			
			EXEC spApplication_Settings_CRUD_Records @pvOptionCRUD = 'R', @piIdApplication = 1

			EXEC spApplication_Settings_CRUD_Records @pvOptionCRUD = 'R', @piIdApplication = 1, @pvUse = 'User'
			
			EXEC spApplication_Settings_CRUD_Records @pvOptionCRUD = 'R', @piIdApplication = 1, @pvSettingsKey = 'SMTPServer'
			
			EXEC spApplication_Settings_CRUD_Records @pvOptionCRUD = 'U', @piIdApplication = 1, @pvSettingsKey = 'SMTPServer', @pvSettingsValue ='smtp-mail.gamil.com', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			
			EXEC spApplication_Settings_CRUD_Records @pvOptionCRUD = 'D' --


*/
CREATE PROCEDURE [dbo].spApplication_Settings_CRUD_Records
@pvOptionCRUD				Varchar(1),
@piIdApplication			Int			= 0,
@pvSettingsKey				Varchar(50) = '',
@pvSettingsValue			Varchar(255)= '',
@pvUse						Varchar(30) = '',
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
	DECLARE @vDescription		Varchar(255)	= 'Application_Settings - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spApplication_Settings_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',  @piIdApplication = '" + ISNULL(CAST(@piIdApplication AS VARCHAR),'NULL') + "', @pvSettingsKey = '" + ISNULL(@pvSettingsKey,'NULL') + "', @pvSettingsValue = '" + ISNULL(@pvSettingsValue,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Get Id Request
		IF EXISTS (SELECT * FROM Application_Settings WHERE Id_Application = @piIdApplication AND Settings_Key = @pvSettingsKey)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')	
		END
		ELSE
		BEGIN 
			--Insert Application Settings
			INSERT INTO Application_Settings (
					Id_Application,
					Settings_Key,
					Settings_Value,
					Modify_By,
					Modify_Date,
					Modify_IP)

			VALUES (@piIdApplication,
					@pvSettingsKey,
					@pvSettingsValue,
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
		SELECT 	A.Id_Application,
				A.Settings_Key,
				S.Settings_Name,
				A.Settings_Value,
				S.Tooltip,
				S.[Use],
				A.Modify_By,
				A.Modify_Date,
				A.Modify_IP
		FROM Application_Settings A

		INNER JOIN Setting_Templates S ON 
		A.Id_Application = S.Id_Application AND
		A.Settings_Key = S.Settings_Key

		WHERE 		
		(@piIdApplication	= 0		OR A.Id_Application = @piIdApplication) AND
		(@pvSettingsKey		= ''	OR A.Settings_Key = @pvSettingsKey) AND 
		(@pvUse				= ''	OR S.[Use] = @pvUse)

		ORDER BY  A.Id_Application, A.Settings_Key 		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
	
		UPDATE Application_Settings
		SET Settings_Value	= @pvSettingsValue,
			Modify_By		= @pvUser,
			Modify_Date		= GETDATE(),
			Modify_IP		= @pvIP
		WHERE 
		Id_Application	= @piIdApplication AND
		Settings_Key	= @pvSettingsKey
		
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