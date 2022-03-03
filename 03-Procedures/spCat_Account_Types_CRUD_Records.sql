USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Account_Types_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Account_Types_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Account_Types_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Account_Types_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Account_Types | Create - Read - Upadate - Delete 
Date:		16/02/2022
Example:
			spCat_Account_Types_CRUD_Records @pvOptionCRUD = 'C', @pvIdAccountType = 'RETFLECOM' , @pvShortDesc = 'Desc Short Desc', @pvLongDesc = 'Desc Long Desc', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Account_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdAccountType = 'RETFLECOM' 
			spCat_Account_Types_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Account_Types_CRUD_Records @pvOptionCRUD = 'U', @pvIdAccountType = 'RETFLECOM' , @pvShortDesc = 'Desc Short Desc', @pvLongDesc = 'Desc Long Desc', @pbStatus = 0, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Account_Types_CRUD_Records @pvOptionCRUD = 'D', @pvIdAccountType = 'RETFLECOM' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Account_Types_CRUD_Records @pvOptionCRUD = 'X', @pvIdAccountType = 'RETFLECOM' , @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

*/
CREATE PROCEDURE [dbo].spCat_Account_Types_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdAccountType	Varchar(10) = '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
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
	DECLARE @vDescription		Varchar(255)	= 'Cat_Account_Types - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Account_Types_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdAccountType = '" + ISNULL(@pvIdAccountType,'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
    IF EXISTS(SELECT * FROM Cat_Account_Types WHERE Id_Account_Type = @pvIdAccountType)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don't Exists
        BEGIN
            INSERT INTO Cat_Account_Types(
                Id_Account_Type,
                Short_Desc,
                Long_Desc,
                [Status],
                Modify_Date,
                Modify_By,
                Modify_IP)
            VALUES (
                @pvIdAccountType, 
                @pvShortDesc,
                @pvLongDesc,
                @pbStatus,
                GETDATE(),
                @pvUser,
                @pvIP)
        END 

	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		Id_Account_Type,
		Short_Desc,
		Long_Desc,
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM Cat_Account_Types 
		WHERE @pvIdAccountType = '' OR Id_Account_Type = @pvIdAccountType
		ORDER BY  Id_Account_Type
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
        UPDATE Cat_Account_Types
        SET Short_Desc  = @pvShortDesc,
            Long_Desc   = @pvLongDesc,
            [Status]    = @pbStatus,
            Modify_Date = GETDATE(),
            Modify_By   = @pvUser,
            Modify_IP   = @pvIP
        WHERE Id_Account_Type = @pvIdAccountType
    
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