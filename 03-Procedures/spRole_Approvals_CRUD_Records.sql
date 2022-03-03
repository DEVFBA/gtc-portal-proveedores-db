USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spRole_Approvals_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spRole_Approvals_CRUD_Records'

IF OBJECT_ID('[dbo].[spRole_Approvals_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spRole_Approvals_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Role_Approvals | Create - Read - Upadate - Delete 
Date:		24/08/2021
Example:
			spRole_Approvals_CRUD_Records	@pvOptionCRUD			= 'C',		
											@pvIdRole				= 'VENDOR', 									
											@pvIdUser				= 'agutierrez@gtcta.mx' , 
											@pvIdApprovalType		= 'SOL',
											@pbApplySign			= 0, 
											@piOrderSign			= 10, 
											@pbStatus				= 1, 
											@pvUser					= 'ALZEPEDA', 
											@pvIP					='192.168.1.254'

			spRole_Approvals_CRUD_Records	@pvOptionCRUD = 'R'
			spRole_Approvals_CRUD_Records	@pvOptionCRUD = 'R', @pvIdRole = 'VENDOR' 
			spRole_Approvals_CRUD_Records	@pvOptionCRUD = 'R', @pvIdUser = 'agutierrez@gtcta.mx'
			spRole_Approvals_CRUD_Records	@pvOptionCRUD = 'R', @pvIdApprovalType = 'SOL'
			spRole_Approvals_CRUD_Records	@pvOptionCRUD = 'R', @pvIdRole = 'ADMIN', @pvIdUser = 'agutierrez@gtcta.mx'

			spRole_Approvals_CRUD_Records	@pvOptionCRUD			= 'U',	
											@pvIdRole				= 'VENDOR', 									
											@pvIdUser				= 'agutierrez@gtcta.mx' , 
											@pvIdApprovalType		= 'SOL',
											@pbApplySign			= 1, 
											@piOrderSign			= 10, 
											@pbStatus				= 0, 
											@pvUser					= 'ALZEPEDA', 
											@pvIP					='192.168.1.254'

			spRole_Approvals_CRUD_Records 	@pvOptionCRUD = 'D',
											@pvIdRole				= 'VENDOR', 									
											@pvIdUser				= 'agutierrez@gtcta.mx'
			
*/
CREATE PROCEDURE [dbo].spRole_Approvals_CRUD_Records
@pvOptionCRUD			Varchar(5),
@pvIdRole				Varchar(10)	= '', 
@pvIdUser				Varchar(60)	= '',
@pvIdApprovalType		Varchar(10)	= '', 
@pbApplySign			Bit			= 0,	
@piOrderSign			Int 		= 0,
@pbStatus				Bit			= 1,
@pvUser					Varchar(50)	= '',
@pvIP					Varchar(20)	= ''
WITH ENCRYPTION AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
	DECLARE @piValidUser SmallInt = 0

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Security_Access - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spRole_Approvals_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "', @pvIdUser = '" + ISNULL(@pvIdUser,'NULL') + "', @pvIdApprovalType = '" + ISNULL(CAST(@pvIdApprovalType AS VARCHAR),'NULL') + "', @pbApplySign = '" + ISNULL(CAST(@pbApplySign AS VARCHAR),'NULL') + "', @piOrderSign = '" + ISNULL(CAST(@piOrderSign AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Role_Approvals WHERE [User] = @pvIdUser)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don't Exists
		BEGIN			
			INSERT INTO Role_Approvals (
				Id_Role,
				[User],
				Id_Approval_Type,
				Apply_Sign,
				Order_Sign,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES (
				@pvIdRole,
				@pvIdUser,
				@pvIdApprovalType,
				@pbApplySign,
				@piOrderSign,
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
		RA.Id_Role,
		Role_Desc = R.Short_Desc,
		RA.[User],
		U.[Name],
		RA.Id_Approval_Type,
		Approval_Type_Desc = T.Short_Desc,
		RA.Apply_Sign,
		RA.Order_Sign,
		RA.[Status],
		RA.Modify_Date,
		RA.Modify_By,
		RA.Modify_IP
		FROM Role_Approvals RA

		INNER JOIN Security_Roles R ON 
		RA.Id_Role = R.Id_Role

		INNER JOIN Security_Users U ON 
		RA.[User] = U.[User]

		INNER JOIN Cat_Approval_Types T ON 
		RA.Id_Approval_Type = T.Id_Approval_Type
		
		WHERE 
		(@pvIdRole			= ''	OR RA.Id_Role = @pvIdRole) AND 
		(@pvIdUser			= ''	OR RA.[User] = @pvIdUser) AND
		(@pvIdApprovalType	= ''	OR RA.Id_Approval_Type = @pvIdApprovalType) 
		  
		
		ORDER BY Order_Sign, [User]
		RETURN
	END


	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN

		UPDATE Role_Approvals 
		SET 
			Id_Approval_Type	= @pvIdApprovalType,
			Apply_Sign			= @pbApplySign,
			Order_Sign			= @piOrderSign,
			[Status]			= @pbStatus,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP
		WHERE Id_Role = @pvIdRole AND [User] = @pvIdUser
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		DELETE Role_Approvals
		WHERE 
		Id_Role = @pvIdRole AND [User] = @pvIdUser
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