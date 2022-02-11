USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSAT_Cat_Payment_Methods_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSAT_Cat_Payment_Methods_CRUD_Records'

IF OBJECT_ID('[dbo].[spSAT_Cat_Payment_Methods_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSAT_Cat_Payment_Methods_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		SAT_Cat_Payment_Methods | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spSAT_Cat_Payment_Methods_CRUD_Records @pvOptionCRUD = 'C', @pvIdCatalog = '001' , @pvShortDesc = 'ShortDesc 001', @pvLongDesc = 'LongDesc 001',  @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSAT_Cat_Payment_Methods_CRUD_Records @pvOptionCRUD = 'R'
			spSAT_Cat_Payment_Methods_CRUD_Records @pvOptionCRUD = 'R', @pvIdCatalog = '001'
			spSAT_Cat_Payment_Methods_CRUD_Records @pvOptionCRUD = 'R', @pvShortDesc = 'ShortDesc' 
			spSAT_Cat_Payment_Methods_CRUD_Records @pvOptionCRUD = 'U', @pvIdCatalog = '001' , @pvShortDesc = 'ShortDesc 001', @pvLongDesc = 'LongDesc 001',  @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSAT_Cat_Payment_Methods_CRUD_Records @pvOptionCRUD = 'D'
*/
CREATE PROCEDURE [dbo].spSAT_Cat_Payment_Methods_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdCatalog		Varchar(50)	= '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
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
	DECLARE @vDescription		Varchar(255)	= 'SAT_Cat_Payment_Methods - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spSAT_Cat_Payment_Methods_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdCatalog = '" + ISNULL(CAST(@pvIdCatalog AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "',  @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM SAT_Cat_Payment_Methods WHERE Id_Payment_Method = @pvIdCatalog)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don´t Exists
		BEGIN
			INSERT INTO SAT_Cat_Payment_Methods 
			   (Id_Payment_Method,
				Short_Desc,
				Long_Desc,
				Status,
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@pvIdCatalog,
				@pvShortDesc,
				@pvLongDesc,
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
		Id_Catalog = Id_Payment_Method,
		Short_Desc,
		Long_Desc,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM SAT_Cat_Payment_Methods 
		WHERE 
			(@pvIdCatalog	= '' OR Id_Payment_Method = @pvIdCatalog) AND
			(@pvShortDesc	= '' OR Short_Desc LIKE '%' +  @pvShortDesc + '%')	
		ORDER BY  Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE SAT_Cat_Payment_Methods
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_By	= @pvUser,
			Modify_Date = GETDATE(),
			Modify_IP	= @pvIP
		WHERE Id_Payment_Method = @pvIdCatalog
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