USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCarta_Porte_Requests_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCarta_Porte_Requests_CRUD_Records'

IF OBJECT_ID('[dbo].[spCarta_Porte_Requests_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spCarta_Porte_Requests_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Carta_Porte_Requests | Create - Read - Upadate - Delete 
Date:		10/02/2022
Example:
			spCarta_Porte_Requests_CRUD_Records @pvOptionCRUD = 'C', @piIdCompany = 1 , @pvUUID = 'D48F641F-E656-4B35-AAF6-DBAEA5D61F54',  @piRequestNumber = 123456, @pvPath = 'C:\', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCarta_Porte_Requests_CRUD_Records @pvOptionCRUD = 'R'
			spCarta_Porte_Requests_CRUD_Records @pvOptionCRUD = 'R', @piIdCompany = 1
			spCarta_Porte_Requests_CRUD_Records @pvOptionCRUD = 'R', @pvUUID = 'D48F641F-E656-4B35-AAF6-DBAEA5D61F54'
			spCarta_Porte_Requests_CRUD_Records @pvOptionCRUD = 'U', @piIdCompany = 1, @piRequestNumber = 6, @pvUUID = 'D48F641F-E656-4B35-AAF6-DBAEA5D61F54'
			spCarta_Porte_Requests_CRUD_Records @pvOptionCRUD = 'D'

*/
CREATE PROCEDURE [dbo].spCarta_Porte_Requests_CRUD_Records
@pvOptionCRUD		Varchar(1),
@piIdCompany		Int			= 0,
@pvUUID				Varchar(50) = '',
@piRequestNumber	Int			= 0,
@pvPath				Varchar(255)= '',
@pvUser				Varchar(50) = '',
@pvIP				Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE @bStatus Bit = 1
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Carta_Porte_Requests - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCarta_Porte_Requests_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "',@piIdCompany = '" + ISNULL(CAST(@piIdCompany AS VARCHAR),'NULL') + "',  @pvUUID = '" + ISNULL(@pvUUID,'NULL') + "', @piRequestNumber = " + ISNULL(CAST(@piRequestNumber AS VARCHAR),'NULL') + ", @pvPath = '" + ISNULL(@pvPath,'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		
		IF EXISTS (SELECT * FROM Carta_Porte_Requests WHERE Id_Company = @piIdCompany AND Request_Number = @piRequestNumber AND [Status] = 1)
		BEGIN
			UPDATE Carta_Porte_Requests
			SET [Status] = 0,
				Modify_Date = GETDATE()
			WHERE Id_Company = @piIdCompany AND Request_Number = @piRequestNumber AND [Status] = 1
		END
		
		INSERT INTO Carta_Porte_Requests 
			(Id_Company,
			UUID,
			Request_Number,
			[Path],
			Register_Date,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP)
		VALUES 
			(@piIdCompany,
			@pvUUID,
			@piRequestNumber,
			@pvPath,
			GETDATE(),
			@bStatus,
			@pvUser,
			GETDATE(),
			@pvIP)
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
			Id_Request_CP,
			Id_Company,
			UUID,
			Request_Number,
			[Path],
			Register_Date,
			[Status],
			Modify_By,
			Modify_Date,
			Modify_IP
		FROM Carta_Porte_Requests 
		WHERE 
			(@piIdCompany	= 0  OR Id_Company = @piIdCompany) AND
			(@pvUUID		= '' OR UUID = @pvUUID)
		ORDER BY  Id_Request_CP
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		IF EXISTS (SELECT * FROM Carta_Porte_Requests WHERE Id_Company = @piIdCompany AND Request_Number = @piRequestNumber AND [Status] = 1)
		BEGIN
			UPDATE Carta_Porte_Requests
			SET UUID = @pvUUID
			WHERE Id_Company = @piIdCompany AND Request_Number = @piRequestNumber AND [Status] = 1
		END
		ELSE
			SET @iCode	= dbo.fnGetCodes('Request Number - Not Exists')			
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