USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCompanies_Vendors_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCompanies_Vendors_CRUD_Records'

IF OBJECT_ID('[dbo].[spCompanies_Vendors_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCompanies_Vendors_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Companies_Vendors | Create - Read - Upadate - Delete 
Date:		04/09/2021
Example:


			EXEC spCompanies_Vendors_CRUD_Records	@pvOptionCRUD = 'C', 
													@piIdCompany = 2,
													@piIdVendor = 1,
													@pbStatus = 1
													@pvUser = 'AZEPEDA', 
													@pvIP ='192.168.1.254'
			
			EXEC spCompanies_Vendors_CRUD_Records @pvOptionCRUD = 'R'

			EXEC spCompanies_Vendors_CRUD_Records @pvOptionCD = 'R', @piIdCompany = 2
			
			EXEC spCompanies_Vendors_CRUD_Records @pvOptionCRUD = 'R', @piIdCompany = 2, @piIdVendor = 1

			EXEC spCompanies_Vendors_CRUD_Records @pvOptionCRUD = 'U', 
												  @piIdCompany = 2, 
												  @piIdVendor = 1, 
												  @pbStatus = 1,
												  @pvUser = 'AZEPEDA', 
												  @pvIP ='192.168.1.254'
			
			EXEC spCompanies_Vendors_CRUD_Records @pvOptionCRUD = 'D', @piIdCompany = 2, @piIdVendor = 1

			SELECT * FROM Companies_Vendors


*/
CREATE PROCEDURE [dbo].spCompanies_Vendors_CRUD_Records
@pvOptionCRUD				Varchar(1),
@piIdCompany				Int			= 0,
@piIdVendor					Int			= -1,
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
	DECLARE @vDescription		Varchar(255)	= 'Companies_Vendors - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCompanies_Vendors_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdCompany = '" + ISNULL(CAST(@piIdCompany AS VARCHAR),'NULL') + "', @piIdVendor = '" + ISNULL(CAST(@piIdVendor AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Get Id Request
		IF EXISTS (SELECT * FROM Companies_Vendors WHERE Id_Company = @piIdCompany AND Id_Vendor = @piIdVendor)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')	
		END
		ELSE
		BEGIN 			
			--Insert
			INSERT INTO Companies_Vendors (
					Id_Company,
					Id_Vendor,
					[Status],
					Modify_By,
					Modify_Date,
					Modify_IP)

			VALUES (@piIdCompany,
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
		SELECT  CV.Id_Company,
				Company = C.Name,
				Company_Status = C.Status,
				CV.Id_Vendor,
				Vendor = V.Name,
				Vendorn_Status = V.Status,
				CV.[Status],
				CV.Modify_By,
				CV.Modify_Date,
				CV.Modify_IP
		FROM Companies_Vendors CV

		INNER JOIN Companies C ON 
		CV.Id_Company = C.Id_Company

		INNER JOIN Cat_Vendors V ON 
		CV.Id_Vendor = V.Id_Vendor


		WHERE 
		(@piIdCompany	= 0	 OR CV.Id_Company = @piIdCompany) AND
		(@piIdVendor	= -1 OR CV.Id_Vendor = @piIdVendor)
		ORDER BY  Id_Company,Id_Vendor 		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN

		UPDATE Companies_Vendors
		SET [Status]		= @pbStatus,
			Modify_By		= @pvUser,
			Modify_Date		= GETDATE(),
			Modify_IP		= @pvIP
		WHERE 
		Id_Company	= @piIdCompany AND
		Id_Vendor	= @piIdVendor
		
	END

	--------------------------------------------------------------------
	--Delete Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'D' OR @vDescOperationCRUD = 'N/A'
	BEGIN
		DELETE Companies_Vendors
		WHERE 
		Id_Company		= @piIdCompany AND
		Id_Vendor	= @piIdVendor
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