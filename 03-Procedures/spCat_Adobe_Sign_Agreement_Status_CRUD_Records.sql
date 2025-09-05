USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Adobe_Sign_Agreement_Status_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Adobe_Sign_Agreement_Status_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Adobe_Sign_Agreement_Status_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Adobe_Sign_Agreement_Status_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Adobe_Sign_Agreement_Status | Create - Read - Upadate - Delete 
Date:		24/03/2022
Example:
			spCat_Adobe_Sign_Agreement_Status_CRUD_Records @pvOptionCRUD = 'C', @pvIdAgreementStatus = '001' , @pvShortDesc = 'ShortDesc 001', @pvLongDesc = 'LongDesc 001',  @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Adobe_Sign_Agreement_Status_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Adobe_Sign_Agreement_Status_CRUD_Records @pvOptionCRUD = 'R', @pvIdAgreementStatus = '001'
			spCat_Adobe_Sign_Agreement_Status_CRUD_Records @pvOptionCRUD = 'R', @pvShortDesc = 'ShortDesc' 
			spCat_Adobe_Sign_Agreement_Status_CRUD_Records @pvOptionCRUD = 'U', @pvIdAgreementStatus = '001', @pvShortDesc = 'ShortDesc 001', @pvLongDesc = 'LongDesc 001',  @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Adobe_Sign_Agreement_Status_CRUD_Records @pvOptionCRUD = 'D'

			SELECT * FROM Cat_Adobe_Sign_Agreement_Status			
*/
CREATE PROCEDURE [dbo].spCat_Adobe_Sign_Agreement_Status_CRUD_Records
@pvOptionCRUD			Varchar(1),
@pvIdAgreementStatus	Varchar	(10)='',
@pvShortDesc			Varchar(50) = '',
@pvLongDesc				Varchar(255)= '',
@pbStatus				Bit			= 1,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Cat_Adobe_Sign_Agreement_Status - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_Adobe_Sign_Agreement_Status_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdAgreementStatus = '" + ISNULL(CAST(@pvIdAgreementStatus AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "',  @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Adobe_Sign_Agreement_Status WHERE Id_Agreement_Status = @pvIdAgreementStatus)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don't Exists
		BEGIN
			INSERT INTO Cat_Adobe_Sign_Agreement_Status 
			   (Id_Agreement_Status,
				Short_Desc,
				Long_Desc,
				Status,
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@pvIdAgreementStatus,
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
		Id_Catalog = Id_Agreement_Status,
		Short_Desc,
		Long_Desc,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM Cat_Adobe_Sign_Agreement_Status 
		WHERE 
			(@pvIdAgreementStatus	= '' OR Id_Agreement_Status = @pvIdAgreementStatus) AND
			(@pvShortDesc	= '' OR Short_Desc LIKE '%' +  @pvShortDesc + '%')	
		ORDER BY  Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Adobe_Sign_Agreement_Status
		SET Short_Desc	= @pvShortDesc,
			Long_Desc	= @pvLongDesc,
			[Status]	= @pbStatus,
			Modify_By	= @pvUser,
			Modify_Date = GETDATE(),
			Modify_IP	= @pvIP
		WHERE Id_Agreement_Status = @pvIdAgreementStatus
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