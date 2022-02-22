USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_File_Types_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_File_Types_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_File_Types_CRUD_Records]','P') IS NOT NULL 
       DROP PROCEDURE [dbo].spCat_File_Types_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_File_Types | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spCat_File_Types_CRUD_Records @pvOptionCRUD = 'C', @pvIdFileType = 'PDFINV',  @pvShortDesc = 'Factura PDF', @pvLongDesc = 'Factura PDF', @pvFileNamePrefix ='Prefix' , @pvPath ='c:\' , @pvExtension = 'PDF', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_File_Types_CRUD_Records @pvOptionCRUD = 'R'
			spCat_File_Types_CRUD_Records @pvOptionCRUD = 'R', @pvIdFileType = 'PDFINV'
			spCat_File_Types_CRUD_Records @pvOptionCRUD = 'R', @pvShortDesc = 'PDF' 
			spCat_File_Types_CRUD_Records @pvOptionCRUD = 'U', @pvIdFileType = 'PDFINV',  @pvShortDesc = 'Factura PDF', @pvLongDesc = 'Factura PDF', @pvFileNamePrefix ='Prefix' , @pvPath ='c:\',  @pvExtension = 'pdf', @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_File_Types_CRUD_Records @pvOptionCRUD = 'D'

*/
CREATE PROCEDURE [dbo].spCat_File_Types_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdFileType		Varchar(10)	= '',
@pvShortDesc		Varchar(50) = '',
@pvLongDesc			Varchar(255)= '',
@pvFileNamePrefix	Varchar(50)	= '',
@pvPath				Varchar(255)= '',
@pvExtension		Varchar(3) 	= '',
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
	DECLARE @vDescription		Varchar(255)	= 'Cat_File_Types - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_File_Types_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdFileType = '" + ISNULL(CAST(@pvIdFileType AS VARCHAR),'NULL') + "', @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvFileNamePrefix = '" + ISNULL(@pvFileNamePrefix,'NULL') + "', @pvPath = '" + ISNULL(@pvPath,'NULL') + "', @pvExtension = '" + ISNULL(@pvExtension,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_File_Types WHERE Id_File_Type = @pvIdFileType )
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don�t Exists
		BEGIN
			INSERT INTO Cat_File_Types 
			   (Id_File_Type,
				Short_Desc,
				Long_Desc,
				File_Name_Prefix,
				[Path],
				Extension,
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@pvIdFileType,
				@pvShortDesc,
				@pvLongDesc,
				@pvFileNamePrefix,
				@pvPath,
				@pvExtension,
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
		Id_Catalog = Id_File_Type,
		Short_Desc,
		Long_Desc,
		Extension,
		File_Name_Prefix,
		[Path],
		[Status],
		Modify_Date,
		Modify_By,
		Modify_IP
		FROM Cat_File_Types 


		WHERE 
			(@pvIdFileType	= '' OR Id_File_Type = @pvIdFileType) AND
			(@pvExtension	= '' OR Extension = @pvExtension) AND			
			(@pvShortDesc	= '' OR Short_Desc LIKE '%' +  @pvShortDesc + '%')	
		ORDER BY  Id_File_Type
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_File_Types
		SET Short_Desc			= @pvShortDesc,
			Long_Desc			= @pvLongDesc,
			File_Name_Prefix	= @pvFileNamePrefix,
			[Path]				= @pvPath,
			Extension			= @pvExtension,
			[Status]			= @pbStatus,
			Modify_By			= @pvUser,
			Modify_Date			= GETDATE(),
			Modify_IP			= @pvIP
		WHERE Id_File_Type = @pvIdFileType
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