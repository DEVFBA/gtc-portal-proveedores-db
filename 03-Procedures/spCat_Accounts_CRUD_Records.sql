USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Accounts_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Accounts_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Accounts_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Accounts_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Accounts | Create - Read - Upadate - Delete 
Date:		16/02/2022
Example:
			spCat_Accounts_CRUD_Records @pvOptionCRUD = 'C', @pvIdAccountType = 'RETFLECOM' ,@pvBusinessUnit = '', @pvObjectAccount = '', @pvSubsidiary = '', @pvAccount_Name = '', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Accounts_CRUD_Records @pvOptionCRUD = 'R', @piIdAccount = 1
			spCat_Accounts_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Accounts_CRUD_Records @pvOptionCRUD = 'U',  @piIdAccount = 1, @pvIdAccountType = 'RETFLECOM' , @pvBusinessUnit = 'x', @pvObjectAccount = 'y', @pvSubsidiary = '', @pvAccount_Name = '', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_Accounts_CRUD_Records @pvOptionCRUD = 'D' --No Aplica

*/
CREATE PROCEDURE [dbo].spCat_Accounts_CRUD_Records
@pvOptionCRUD		Varchar(1),
@piIdAccount	    Int = 0,
@pvIdAccountType	Varchar(10) = '',
@pvBusinessUnit		Varchar(15) = '',
@pvObjectAccount	Varchar(15) = '',
@pvSubsidiary       Varchar(15) = '',
@pvAccount_Name     Varchar(50) = '',
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
	DECLARE @vDescription		Varchar(255)	= 'Cat_Accounts - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_Accounts_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdAccount = '" + ISNULL(CAST(@piIdAccount AS VARCHAR),'NULL') + "', @pvIdAccountType = '" + ISNULL(@pvIdAccountType,'NULL') + "', @pvBusinessUnit = '" + ISNULL(@pvBusinessUnit,'NULL') + "', @pvObjectAccount = '" + ISNULL(@pvObjectAccount,'NULL') + "', @pvAccount_Name = '" + ISNULL(@pvAccount_Name,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
    IF EXISTS(SELECT * FROM Cat_Accounts WHERE Id_Account = @piIdAccount)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don't Exists
        BEGIN
            INSERT INTO Cat_Accounts (
				Id_Account_Type,
				Business_Unit,
				Object_Account,
				Subsidiary,
				Account_Name,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
            VALUES (
				@pvIdAccountType,
                @pvBusinessUnit, 
                @pvObjectAccount,
                @pvSubsidiary,
                @pvAccount_Name,
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
		A.Id_Account, 
		A.Id_Account_Type,
		Account_Type_Desc = T.Short_Desc,
		A.Business_Unit,
		A.Object_Account,
		A.Subsidiary,
		A.Account_Name,
		A.[Status],
		A.Modify_By,
		A.Modify_Date,
		A.Modify_IP
		FROM Cat_Accounts A
		INNER JOIN Cat_Account_Types T ON
		A.Id_Account_Type = T.Id_Account_Type		
		WHERE 
		(@piIdAccount = '' OR A.Id_Account = @piIdAccount) AND
		(@pvIdAccountType = '' OR A.Id_Account_Type = @pvIdAccountType)
		ORDER BY  Id_Account_Type
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
        UPDATE Cat_Accounts
        SET Id_Account_Type	= @pvIdAccountType,
			Business_Unit	= @pvBusinessUnit,
			Object_Account	= @pvObjectAccount,
			Subsidiary		= @pvSubsidiary,
			Account_Name	= @pvAccount_Name,
			[Status]		= @pbStatus,
			Modify_By		= @pvUser,
			Modify_Date		= GETDATE(),
			Modify_IP		= @pvIP
		
        WHERE Id_Account = @piIdAccount
    
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