USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Users_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Users_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_Users_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Users_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Security_Users | Create - Read - Upadate - Delete 
Date:		24/08/2021
Example:
			spSecurity_Users_CRUD_Records	@pvOptionCRUD			= 'C',											
											@pvIdUser				= 'alejandro.zepeda@gmail.com' , 
											@pvIdRole				= 'ADMIN', 
											@pvIdDepartment			= '001',
											@piIdVendor				= 2,
											@pvPassword				= '6c690c09caf5abbab6178e980881cbf5568481e48cd344e4b726c34c6e81be57', 
											@pvName					= 'Alejandro Zepeda', 
											@pbTempPassword			= 0, 
											@pvFinalEffectiveDate	= NULL, 
											@pvProfilePicPath       = 'C:\Imagen.jpg',
											@pvEmail				= 'correo@example.com',
											@pbStatus				= 1, 
											@pvUser					= 'ALZEPEDA', 
											@pvIP					='192.168.1.254'

			spSecurity_Users_CRUD_Records	@pvOptionCRUD = 'R'
			spSecurity_Users_CRUD_Records	@pvOptionCRUD = 'R', @piIdVendor = 2,
			spSecurity_Users_CRUD_Records	@pvOptionCRUD = 'R', @pvIdRole = 'ADMIN' 
			spSecurity_Users_CRUD_Records	@pvOptionCRUD = 'R', @piIdVendor = 2, @pvIdRole = 'CUSAPPLI', @pvIdUser = 'jorgemauricio.morales@cremeria-americana.com.mx'
			
			spSecurity_Users_CRUD_Records	@pvOptionCRUD			= 'VA',	
											@pvIdUser				= 'ahernandez@gtcta.mx' , 
											@pvPassword				= '062e99247edbe5cd47f3bafb90e38786bf38d42cbd9e1dea8a3c1b3b78921bf3', 
											@pvUser					= 'ALZEPEDA', 
											@pvIP					='192.168.1.254'

			spSecurity_Users_CRUD_Records	@pvOptionCRUD			= 'U',	
											@pvIdUser				= 'alejandro.zepeda@gmail.com' , 
											@pvIdRole				= 'ADMIN',
											@pvIdDepartment			= '001',
											@piIdVendor				= 2,
											@pvPassword				= '', 
											@pvName					= 'Alejandro Zepeda', 
											@pvFinalEffectiveDate	= '', 
											@pbTempPassword			= 0, 
											@pvProfilePicPath       = 'C:\Imagen.jpg',
											@pvEmail				= 'correo@example.com',
											@pbStatus				= 1, 
											@pvUser					= 'ALZEPEDA', 
											@pvIP					='192.168.1.254'

			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'D'
			spSecurity_Users_CRUD_Records @pvOptionCRUD = 'X'
			
*/
CREATE PROCEDURE [dbo].spSecurity_Users_CRUD_Records
@pvOptionCRUD			Varchar(5),
@pvIdUser				Varchar(60)	= '',
@pvIdRole				Varchar(10)	= '', 
@pvIdDepartment	    	Varchar	(10)='',
@piIdVendor				Int			= -1,
@pvPassword				Varchar(255)= '',
@pvName					Varchar(255)= '',
@pbTempPassword			Bit			= 0,	
@pvFinalEffectiveDate	Varchar(8)	= NULL,
@pvProfilePicPath		Varchar(255)= '',
@pvEmail				Varchar(255)= NULL,
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
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spSecurity_Users_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdUser = '" + ISNULL(@pvIdUser,'NULL') + "', @pvIdRole = '" + ISNULL(@pvIdRole,'NULL') + "', @pvIdDepartment = '" + ISNULL(CAST(@pvIdDepartment AS VARCHAR),'NULL') + "', @piIdVendor = '" + ISNULL(CAST(@piIdVendor AS VARCHAR),'NULL') + "', @pvPassword = '" + ISNULL(@pvPassword,'NULL') + "', @pvName = '" + ISNULL(@pvName,'NULL') + "', @pbTempPassword = '" + ISNULL(CAST(@pbTempPassword AS VARCHAR),'NULL') + "', @pvFinalEffectiveDate = '" + ISNULL(@pvFinalEffectiveDate,'NULL') + "', @pvProfilePicPath = '" + ISNULL(@pvProfilePicPath,'NULL') + "',  @pvEmail = '" + ISNULL(@pvEmail,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Security_Users WHERE [User] = @pvIdUser)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don't Exists
		BEGIN
			IF @pvFinalEffectiveDate = '' SET @pvFinalEffectiveDate = NULL

			INSERT INTO Security_Users (
				[User],
				Id_Role,
				Id_Department,
				Id_Vendor,
				[Password],
				[Name],
				Temporal_Password,
				Final_Effective_Date,
				Profile_Pic_Path,
				Email,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES (
				@pvIdUser,
				@pvIdRole,
				@pvIdDepartment,
				@piIdVendor,
				@pvPassword,
				@pvName,
				@pbTempPassword,
				@pvFinalEffectiveDate,
				@pvProfilePicPath,
				@pvEmail,
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
		U.[User],
		U.Id_Role,
		Role_Desc = R.Short_Desc,
		U.Id_Department, 
		Department_Desc = D.Short_Desc, 
		U.Id_Vendor,
		Vendor = V.[Name],
		U.[Password],
		U.[Name],
		Temporal_Password,
		Final_Effective_Date,
		Profile_Pic_Path,
		U.Email,
		U.[Status],
		U.Modify_Date,
		U.Modify_By,
		U.Modify_IP
		FROM Security_Users U

		INNER JOIN Security_Roles R ON 
		U.Id_Role = R.Id_Role

		INNER JOIN Cat_Vendors V ON 
		U.Id_Vendor = V.Id_Vendor

		LEFT OUTER JOIN Cat_Departments D ON
		U.Id_Department = D.Id_Department

		WHERE 
		
		(@pvIdRole		= ''	OR U.Id_Role = @pvIdRole) AND 
		(@pvIdUser		= ''	OR U.[User] = @pvIdUser) AND
		(@piIdVendor	= -1	OR U.Id_Vendor = @piIdVendor) AND
		(@pvIdDepartment	= ''	OR U.Id_Department = @pvIdDepartment)  
		  
		
		ORDER BY [User]
		RETURN
	END

	--------------------------------------------------------------------
	--Validate User
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'VA'
	BEGIN
		SET @piValidUser = (SELECT COUNT(*) 
		
							FROM Security_Users U

							WHERE 
							(@pvIdUser		= ''	OR U.[User] = @pvIdUser) AND
							(@pvPassword	= ''	OR U.[Password] = @pvPassword) AND
							U.[Status] = 1
						  )
		
		IF @piValidUser = 0
			SET @iCode	= dbo.fnGetCodes('VA - Invalid User')	
		ELSE
			SET @iCode	= dbo.fnGetCodes('VA - Valid User')	

	END
	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN

		UPDATE Security_Users 
		SET 
			Id_Role				= @pvIdRole,
			Id_Department		= @pvIdDepartment,
			[Password]			= (CASE WHEN @pvPassword = '' THEN [Password] ELSE @pvPassword END) ,
			[Name]				= @pvName,
			Temporal_Password	= @pbTempPassword,
			Final_Effective_Date= (CASE WHEN @pvFinalEffectiveDate = '' THEN Final_Effective_Date ELSE @pvFinalEffectiveDate END),
			Profile_Pic_Path	= (CASE WHEN @pvProfilePicPath = '' THEN Profile_Pic_Path ELSE @pvProfilePicPath END),
			Email				= (CASE WHEN @pvEmail IS NULL THEN Email ELSE @pvEmail END),
			[Status]			= @pbStatus,
			Modify_Date			= GETDATE(),
			Modify_By			= @pvUser,
			Modify_IP			= @pvIP
		WHERE [User]			= @pvIdUser 
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