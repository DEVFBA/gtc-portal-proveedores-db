USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spRole_Account_Type_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spRole_Account_Type_CRUD_Records'

IF OBJECT_ID('[dbo].[spRole_Account_Type_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spRole_Account_Type_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Role_Account_Type | Create - Read - Upadate - Delete 
Date:		04/09/2021
Example:


			EXEC spRole_Account_Type_CRUD_Records	@pvOptionCRUD = 'C', 
													@pvIdAccountType = '',
													@pvIdRole = '',
													@pbStatus = 1
													@pvUser = 'AZEPEDA', 
													@pvIP ='192.168.1.254'
			
			EXEC spRole_Account_Type_CRUD_Records @pvOptionCRUD = 'R'

			EXEC spRole_Account_Type_CRUD_Records @pvOptionCD = 'R', @pvIdAccountType = ''
			
			EXEC spRole_Account_Type_CRUD_Records @pvOptionCRUD = 'R', @pvIdAccountType = '', @pvIdRole = ''

			EXEC spRole_Account_Type_CRUD_Records @pvOptionCRUD = 'U', 
												  @pvIdAccountType = '', 
												  @pvIdRole = '', 
												  @pbStatus = 1,
												  @pvUser = 'AZEPEDA', 
												  @pvIP ='192.168.1.254'
			
			EXEC spRole_Account_Type_CRUD_Records @pvOptionCRUD = 'D'

			SELECT * FROM Role_Account_Type


*/
CREATE PROCEDURE [dbo].spRole_Account_Type_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvIdAccountType			Varchar(10) = '',
@pvIdRole					Varchar(10)	= '',
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
	DECLARE @vDescription		Varchar(255)	= 'Role_Account_Type - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spRole_Account_Type_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdAccountType = '" + ISNULL(CAST(@pvIdAccountType AS VARCHAR),'NULL') + "', @pvIdRole = '" + ISNULL(CAST(@pvIdRole AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Get Id Request
		IF EXISTS (SELECT * FROM Role_Account_Type WHERE Id_Account_Type = @pvIdAccountType AND Id_Role = @pvIdRole)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')	
		END
		ELSE
		BEGIN 			
			--Insert
			INSERT INTO Role_Account_Type (
					Id_Account_Type,
					Id_Role,
					[Status],
					Modify_By,
					Modify_Date,
					Modify_IP)

			VALUES (@pvIdAccountType,
					@pvIdRole,
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
		SELECT  AR.Id_Account_Type,
				Account_Type_Desc = A.Short_Desc,
				AR.Id_Role,
				Rol_Desc = R.Short_Desc,
				AR.[Status],
				AR.Modify_By,
				AR.Modify_Date,
				AR.Modify_IP
		FROM Role_Account_Type AR

		INNER JOIN Cat_Account_Types A ON 
		AR.Id_Account_Type = A.Id_Account_Type

		INNER JOIN Security_Roles R ON 
		AR.Id_Role = R.Id_Role


		WHERE 
		(@pvIdAccountType	= ''	 OR AR.Id_Account_Type = @pvIdAccountType) AND
		(@pvIdRole	= '' OR AR.Id_Role = @pvIdRole)
		ORDER BY  AR.Id_Account_Type,AR.Id_Role 		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN

		UPDATE Role_Account_Type
		SET [Status]		= @pbStatus,
			Modify_By		= @pvUser,
			Modify_Date		= GETDATE(),
			Modify_IP		= @pvIP
		WHERE 
		Id_Account_Type	= @pvIdAccountType AND
		Id_Role	= @pvIdRole
		
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
        SET @iCode	= dbo.fnGetCodes('Invalid Option')	
	END

	--------------------------------------------------------------------
	--Invalid Option
	--------------------------------------------------------------------
	IF @vDescOperationCRUD = 'N/A'
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