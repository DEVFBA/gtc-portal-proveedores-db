USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Catalogs_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Catalogs_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Catalogs_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Catalogs_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Catalogs | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spCat_Catalogs_CRUD_Records @pvOptionCRUD = 'C', @piIdCatalogType = 1 , @pvShortDesc = 'ShortDesc 001', @pvLongDesc = 'LongDesc 001',  @pvCRUDReferences = '', @pvComponent = '', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Catalogs_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Catalogs_CRUD_Records @pvOptionCRUD = 'R', @piIdCatalogType = 1
			spCat_Catalogs_CRUD_Records @pvOptionCRUD = 'R', @pvShortDesc = 'ShortDesc' 
			spCat_Catalogs_CRUD_Records @pvOptionCRUD = 'U', @piIdCatalog = 19,  @pvShortDesc = 'ShortDesc 001', @pvLongDesc = 'LongDesc 001',  @pvCRUDReferences = '', @pvComponent = '', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Catalogs_CRUD_Records @pvOptionCRUD = 'D'

		
*/
CREATE PROCEDURE [dbo].spCat_Catalogs_CRUD_Records
@pvOptionCRUD		Varchar(1),
@piIdCatalog		SmallInt	= 0,
@piIdCatalogType	SmallInt	= 0,
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
@pvCRUDReferences	Varchar(255)= '',
@pvComponent		Varchar(50) = '',
@pbStatus			Bit			= 1,
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
WITH ENCRYPTION AS
SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Cat_Catalogs - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_Catalogs_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdCatalogType = '" + ISNULL(CAST(@piIdCatalogType AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "',  , @pvCRUDReferences = '" + ISNULL(@pvCRUDReferences,'NULL') + "' , @pvComponent = '" + ISNULL(@pvComponent,'NULL') + "' @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Catalogs WHERE Short_Desc = @pvShortDesc)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN

			SET @piIdCatalog = (SELECT ISNULL(MAX(Id_Catalog),0) + 1 FROM Cat_Catalogs)

			INSERT INTO Cat_Catalogs 
			   (Id_Catalog_Type,
				Id_Catalog,
				Short_Desc,
				Long_Desc,
				CRUD_References,
				Component,
				Status,
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@piIdCatalogType,
				@piIdCatalog,
				@pvShortDesc,
				@pvLongDesc,
				@pvCRUDReferences,
				@pvComponent,
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
		C.Id_Catalog_Type,
		Catalog_Type_Desc = CT.Short_Desc,
		Id_Catalog,
		C.Short_Desc,
		C.Long_Desc,
		C.CRUD_References,
		C.Component,
		C.[Status],
		C.Modify_Date,
		C.Modify_By,
		C.Modify_IP
		FROM Cat_Catalogs C
		INNER JOIN Cat_Catalog_Types CT ON
		C.Id_Catalog_Type = CT.Id_Catalog_Type
		WHERE 
			(@piIdCatalogType	= '' OR C.Id_Catalog_Type = @piIdCatalogType) AND
			(@piIdCatalog		= '' OR C.Id_Catalog = @piIdCatalog) AND
			(@pvShortDesc		= '' OR C.Short_Desc LIKE '%' +  @pvShortDesc + '%')	
		ORDER BY  C.Id_Catalog_Type, Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Catalogs
		SET Short_Desc		= @pvShortDesc,
			Long_Desc		= @pvLongDesc,
			CRUD_References = @pvCRUDReferences,
			Component		= @pvComponent,
			[Status]		= @pbStatus,
			Modify_By		= @pvUser,
			Modify_Date		= GETDATE(),
			Modify_IP		= @pvIP
		WHERE Id_Catalog_Type = @piIdCatalog
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