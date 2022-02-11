USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Roles_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Roles_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_Roles_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Roles_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Security_Roles | Create - Read - Upadate - Delete 
Date:		28/08/2021
Example:
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'C', @pvIdRole = 'ADMIN' , @pvShortDesc = 'System Administrator', @pvLongDesc = 'System Administrator', @pbShowCustomers = 0, @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'ADMIN' 
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'R'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'U', @pvIdRole = 'ADMIN' , @pvShortDesc = 'System Administrator', @pvLongDesc = 'System Administrator', @pbShowCustomers = 1, @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'D', @pvIdRole = 'ADMIN' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSecurity_Roles_CRUD_Records @pvOptionCRUD = 'X', @pvIdRole = 'ADMIN' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

*/
CREATE PROCEDURE [dbo].spSecurity_Roles_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdRole			Varchar(10) = '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
@pbShowCustomers    Bit         = 0,
@pbStatus			Bit			= 1,
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
WITH ENCRYPTION
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Security_Roles - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spSecurity_Roles_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbShowCustomers = '" + ISNULL(CAST(@pbShowCustomers AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
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
		SELECT 
		Id_Role,
		Short_Desc,
		Long_Desc,
		Show_Customers,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM Security_Roles 
		WHERE @pvIdRole = '' OR Id_Role = @pvIdRole
		ORDER BY  Id_Role
		
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