USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Vendors_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Vendors_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Vendors_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Vendors_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Vendors | Create - Read - Upadate - Delete 
Date:		29/08/2021
Example:


			EXEC spCat_Vendors_CRUD_Records	@pvOptionCRUD		= 'C', 
											@pvIdCountry		= 'MEX',
											@pvName				= 'Vendor SA de CV',
											@pvTaxId			= 'RFCCLIENTE12',
											@pvStreet			= 'AV. Reforma',
											@pvState			= '222',
											@pvPhone1			= '555500000',
											@pvPhone2			= '555500001',
											@pvWebPage			= 'Vendor.com',
											@pbStatus			= 1,
											@pvUser				= 'AZEPEDA', 
											@pvIP				= '192.168.1.254'
			
			EXEC spCat_Vendors_CRUD_Records @pvOptionCRUD = 'R'
			EXEC spCat_Vendors_CRUD_Records @pvOptionCRUD = 'R', @piIdVendor = 3			
			EXEC spCat_Vendors_CRUD_Records @pvOptionCRUD = 'R', @pvName = 'vendor'
			
			EXEC spCat_Vendors_CRUD_Records	@pvOptionCRUD = 'U', 
											@piIdVendor = 3, 	
											@pvIdCountry		= 'MEX',
											@pvName				= 'Vendors SA de CV',
											@pvTaxId			= 'RFCCLIENTE12',
											@pvStreet			= 'AV. Reforma',
											@pvState			= 'MEX',
											@pvPhone1			= '555500000',
											@pvPhone2			= '555500001',
											@pvWebPage			= 'Vendor.com',
											@pbStatus			= 1,
											@pvUser				= 'AZEPEDA', 
											@pvIP				= '192.168.1.254'
			

			EXEC spCat_Vendors_CRUD_Records @pvOptionCRUD = 'D' 


*/
CREATE PROCEDURE [dbo].spCat_Vendors_CRUD_Records
@pvOptionCRUD		Varchar(1),
@piIdVendor			Int			 = -1,
@pvIdCountry		Varchar(50)  = '',	
@pvName				Varchar(255) = '',
@pvTaxId			Varchar(20)  = '',
@pvStreet			Varchar(100) = '',
@pvState			Varchar(50)  = '',
@pvPhone1			Varchar(20)  = '',
@pvPhone2			Varchar(20)  = '',
@pvWebPage			Varchar(255) = '',
@pbStatus			Bit			 = 1,
@pvUser				Varchar(50)  = '',
@pvIP				Varchar(20)  = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Cat_Vendors - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_Vendors_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdVendor = '" + ISNULL(CAST(@piIdVendor AS VARCHAR),'NULL') + "', @pvIdCountry = '" + ISNULL(@pvIdCountry,'NULL') + "', @pvName = '" + ISNULL(@pvName,'NULL') + "', @pvTaxId = '" + ISNULL(@pvTaxId,'NULL') + "', @pvStreet = '" + ISNULL(@pvStreet,'NULL') + "', @pvState = '" + ISNULL(@pvState,'NULL') + "', @pvPhone1 = '" + ISNULL(@pvPhone1,'NULL') + "', @pvPhone2 = '" + ISNULL(@pvPhone2,'NULL') + "', @pvWebPage = '" + ISNULL(@pvWebPage,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Vendors WHERE Id_Country = @pvIdCountry AND Tax_Id = @pvTaxId)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN
		SET @piIdVendor = (SELECT MAX(Id_Vendor) + 1 FROM Cat_Vendors)

			--Insert Application Settings
			INSERT INTO Cat_Vendors(
					Id_Vendor,
					Id_Country,
					[Name],
					Tax_Id,
					Street,
					[State],
					Phone_1,
					Phone_2,
					Web_Page,
					[Status],
					Modify_By,
					Modify_Date,
					Modify_IP)

			VALUES (@piIdVendor,
					@pvIdCountry,
					@pvName,
					@pvTaxId,
					@pvStreet,
					@pvState,
					@pvPhone1,
					@pvPhone2,
					@pvWebPage,
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
		SELECT  Id_Vendor,
				[Name],
				Country.Id_Country,
				Country_Desc = Country.Short_Desc,
				Tax_Id,
				Street,
				[State],
				Phone_1,
				Phone_2,
				Web_Page,
				Vendor.[Status],
				Vendor.Modify_By,
				Vendor.Modify_Date,
				Vendor.Modify_IP
		FROM Cat_Vendors Vendor
		INNER JOIN SAT_Cat_Countries Country ON 
		Vendor.Id_Country = Country.Id_Country
		WHERE 
		(@piIdVendor	= -1 OR Id_Vendor = @piIdVendor) AND 
		(@pvName		= '' OR Name LIKE '%' + @pvName + '%')
		
		ORDER BY  Id_Vendor
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
	
		UPDATE Cat_Vendors
		SET 	Id_Country		= @pvIdCountry,
				[Name]			= @pvName,
				Tax_Id			= @pvTaxId,
				Street			= @pvStreet,
				[State]			= @pvState,
				Phone_1			= @pvPhone1,
				Phone_2			= @pvPhone2,
				Web_Page		= @pvWebPage,
				[Status]		= @pbStatus,
				Modify_By		= @pvUser,
				Modify_Date		= GETDATE(),
				Modify_IP		= @pvIP
		WHERE 
		Id_Vendor		= @piIdVendor
		
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