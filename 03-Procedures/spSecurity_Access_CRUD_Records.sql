USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Access_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Access_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_Access_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Access_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Security_Access | Create - Read - Upadate - Delete 
Date:		13/01/2021
Example:

			DECLARE  @udtSecurityAccess  UDT_Security_Access 

			INSERT INTO @udtSecurityAccess
			SELECT * FROM Security_Access
			WHERE Id_Customer = 1 AND Id_Role = 'GTCADMIN' 

			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'C', @pvIdRole = 'ADMIN' , @pudtSecurityAccess = @udtSecurityAccess , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'R', @pvIdRole = 'ADMIN' 
			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'U', @pvIdRole = 'ADMIN' , @pudtSecurityAccess = @udtSecurityAccess , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'D', @pvIdRole = 'ADMIN' , @pudtSecurityAccess = @udtSecurityAccess , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD = 'X', @pvIdRole = 'ADMIN' , @pudtSecurityAccess = @udtSecurityAccess , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

*/
CREATE PROCEDURE [dbo].[spSecurity_Access_CRUD_Records]
@pvOptionCRUD			Varchar(1),
@pvIdRole				Varchar(10),
@pudtSecurityAccess		UDT_Security_Access Readonly,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
WITH ENCRYPTION
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Security_Access - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spSecurity_Access_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		DELETE Security_Access WHERE Id_Role = @pvIdRole

		INSERT INTO Security_Access(
			Id_Role,
			Id_Module,
			Id_SubModule,
			Component_Module,
			Layout_Module,
			Order_Module,
			Component_Submodule,
			Layout_SubModule,
			Order_Submodule,
			Url,
			Status,
			Modify_By,
			Modify_Date,
			Modify_IP)
		SELECT 
			Id_Role,
			Id_Module,
			Id_SubModule,
			Component_Module,
			Layout_Module,
			Order_Module,
			Component_Submodule,
			Layout_SubModule,
			Order_Submodule,
			Url,
			Status,
			Modify_By	= @pvUser,
			Modify_Date = GETDATE(),
			Modify_IP	= @pvIP
		FROM @pudtSecurityAccess
		WHERE 
		Id_Role = @pvIdRole AND 
		[Status] = 1

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT	
				Id_Role = @pvIdRole,
				SYSC.Id_Module,
				Module_Desc = M.Short_Desc,
				SYSC.Id_SubModule,
				SubModule_Desc = SM.Short_Desc,
				SYSC.Component_Module,
				SYSC.Layout_Module,
				M.Icon,
				M.[State],
				SA.Order_Module,
				SYSC.Component_Submodule,
				SYSC.Layout_SubModule,
				SA.Order_Submodule,
				SYSC.[Url],
				[Status] = ISNULL(SA.[Status],0),
				SA.Modify_By,
				SA.Modify_Date,
				SA.Modify_IP 		
		FROM Security_Access SYSC 


		LEFT OUTER JOIN Security_Access SA ON 
		SYSC.Id_Module		= SA.Id_Module AND 
		SYSC.Id_SubModule	= SA.Id_SubModule AND 
		SA.Id_Role			= @pvIdRole 

		INNER JOIN Security_Modules M ON
		SYSC.Id_Module = M.Id_Module

		INNER JOIN Security_SubModules SM ON 
		SYSC.Id_SubModule = SM.Id_SubModule

		WHERE SYSC.Id_Role = 'SYS_CONFIG'
		ORDER BY SA.Order_Module, SA.Order_Submodule
		
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