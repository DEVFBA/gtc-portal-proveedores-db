USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSecurity_Roles_Companies_Vendors_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSecurity_Roles_Companies_Vendors_CRUD_Records'

IF OBJECT_ID('[dbo].[spSecurity_Roles_Companies_Vendors_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSecurity_Roles_Companies_Vendors_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Access Get Validate User
Date:		27/10/2021
Example:
			spSecurity_Roles_Companies_Vendors_CRUD_Records	
														@pvOptionCRUD		='C',
														@pvIdRole			= 'ADMIN',
														@piIdCompany		= 1,
														@piIdVendor			= 1 , 
														@pbStatus			= 1,
														@pvUser				= 'ALZEPEDA', 
														@pvIP				='192.168.1.254'

			spSecurity_Roles_Companies_Vendors_CRUD_Records	@pvOptionCRUD	= 'R',
														@pvIdRole			= 'ADMIN',
														@piIdCompany		= 1,
														@piIdVendor			= 0  
			

		spSecurity_Roles_Companies_Vendors_CRUD_Records	
														@pvOptionCRUD		='U',
														@pvIdRole			= 'ADMIN',
														@piIdCompany		= 1,
														@piIdVendor			= 1 , 
														@pbStatus			= 1,
														@pvUser				= 'ALZEPEDA', 
														@pvIP				='192.168.1.254'


			spSecurity_Roles_Companies_Vendors_CRUD_Records	@pvOptionCRUD		= 'D',
														@piIdCustomer		= 2,
														@pIdApplication		= 1,
														@pvIdUser			= 'Cremeria' , 
														@pvUser				= 'ALZEPEDA', 
														@pvIP				='192.168.1.254'
			
			
*/
CREATE PROCEDURE [dbo].spSecurity_Roles_Companies_Vendors_CRUD_Records
@pvOptionCRUD			Varchar(5),
@pvIdRole				Varchar(10)	= '',
@piIdCompany			Int			= 0,
@piIdVendor				Smallint	= -1,
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
	DECLARE @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Security_Access - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spSecurity_Roles_Companies_Vendors_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdRole = '" + ISNULL(CAST(@pvIdRole AS VARCHAR),'NULL') + "', @piIdCompany = '" + ISNULL(CAST(@piIdCompany AS VARCHAR),'NULL') + "', @piIdVendor = '" + ISNULL(CAST(@piIdVendor AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Security_Roles_Companies_Vendors WHERE Id_Role = @pvIdRole AND Id_Company = @piIdCompany AND Id_Vendor = @piIdVendor)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO Security_Roles_Companies_Vendors (
				Id_Role,
				Id_Company,
				Id_Vendor,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES (
				@pvIdRole,
				@piIdCompany,
				@piIdVendor,
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
		CAU.Id_Role,
		Role_Desc		= SR.Short_Desc,
		CAU.Id_Company,
		Company_Desc	= C.[Name],
		CAU.Id_Vendor,
		Vendor_Desc		= V.[Name],
		CAU.Modify_Date,
		CAU.Modify_By,
		CAU.Modify_IP
		FROM Security_Roles_Companies_Vendors CAU

		INNER JOIN Companies C ON 
		CAU.Id_Company = C.Id_Company 
		
		INNER JOIN Cat_Vendors V ON
		CAU.Id_Vendor = V.Id_Vendor 

		INNER JOIN Security_Roles SR ON 
		CAU.Id_Role = SR.Id_Role 

		INNER JOIN Companies_Vendors CV ON 
		CAU.Id_Company = CV.Id_Company AND
		CAU.Id_Vendor  = CV.Id_Vendor 

		WHERE 
		(@pvIdRole		= ''	 OR CAU.Id_Role = @pvIdRole) AND
		(@piIdCompany	= 0	 OR CAU.Id_Company = @piIdCompany) AND
		(@piIdVendor	= -1 OR CAU.Id_Vendor = @piIdVendor)
		ORDER BY Role_Desc,Company_Desc,Vendor_Desc
		RETURN
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Security_Roles_Companies_Vendors
		SET [Status] = @pbStatus
		WHERE
		Id_Role = @pvIdRole AND 
		Id_Company = @piIdCompany AND 
		Id_Vendor = @piIdVendor
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D'
	BEGIN
		DELETE Security_Roles_Companies_Vendors 		
		WHERE
		Id_Role = @pvIdRole AND 
		Id_Company = @piIdCompany AND 
		Id_Vendor = @piIdVendor
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