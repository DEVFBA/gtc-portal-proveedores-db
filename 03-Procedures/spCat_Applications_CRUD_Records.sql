USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_Applications_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_Applications_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_Applications_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_Applications_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_Applications | Create - Read - Upadate - Delete 
Date:		12/02/2022
Example:
			spCat_Applications_CRUD_Records @pvOptionCRUD			= 'C', 
											@piIdApplication		= 1,  
											@pvShortDesc			= 'Aplicacion de prueba', 
											@pvLongDesc				= 'Aplicacion de prueba Long', 
											@pvVersion				= 2.0,
											@pvTechnicalDescription	= 'decripcion tecnica',
											@pvType					= 'Server',
											@pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Applications_CRUD_Records @pvOptionCRUD = 'R'
			spCat_Applications_CRUD_Records @pvOptionCRUD = 'R', @piIdApplication = 2 

			spCat_Applications_CRUD_Records @pvOptionCRUD			= 'U', 
											@piIdApplication		= 1,  
											@pvShortDesc			= 'Aplicacion de prueba XX', 
											@pvLongDesc				= 'Aplicacion de prueba Long XX', 
											@pvVersion				= 2.2,
											@pvTechnicalDescription	= 'decripcion tecnica',
											@pvType					= 'Server',
											@pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'

			spCat_Applications_CRUD_Records @pvOptionCRUD = 'D'

*/
CREATE PROCEDURE [dbo].spCat_Applications_CRUD_Records
@pvOptionCRUD			Varchar(1),
@piIdApplication		Smallint	= 0,
@pvShortDesc			Varchar(50)	= '',
@pvLongDesc				Varchar(255)= '',
@pvVersion				Varchar(10)	= '',
@pvTechnicalDescription	Varchar(MAX)= '',
@pvType					Varchar(50)	= '',
@pbStatus				Bit			= 1,
@pvUser					Varchar(50) = '',
@pvIP					Varchar(20) = ''
AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Cat_Applications - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spCat_Applications_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdApplication = " + ISNULL(CAST(@piIdApplication AS VARCHAR),'NULL') + ", @pvShortDesc = '" + ISNULL(@pvShortDesc,'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvVersion = '" + ISNULL(@pvVersion,'NULL') + "', @pvTechnicalDescription = '" + ISNULL(@pvTechnicalDescription,'NULL') + "', @pvType = '" + ISNULL(@pvType,'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
			-- Validate if the record already exists
		IF EXISTS(SELECT * FROM Cat_Applications WHERE Short_Desc = @pvShortDesc)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')		
		END
		ELSE -- Don�t Exists
		BEGIN
			
			SET @piIdApplication = (SELECT ISNULL(MAX(Id_Application),0) + 1 FROM Cat_Applications)

			INSERT INTO Cat_Applications 
			   (Id_Application,
				Short_Desc,
				Long_Desc,
				[Version],
				Technical_Description,
				[Type],
				[Status],
				Modify_By,
				Modify_Date,
				Modify_IP)
			VALUES 
			   (@piIdApplication,
				@pvShortDesc,
				@pvLongDesc,
				@pvVersion,
				@pvTechnicalDescription,
				@pvType,
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
			Id_Catalog = A.Id_Application,
			A.Short_Desc,
			A.Long_Desc,
			A.[Version],
			A.Technical_Description,
			A.[Type],
			A.[Status],
			A.Modify_By,
			A.Modify_Date,
			A.Modify_IP
		FROM Cat_Applications A

		WHERE 
			(@piIdApplication	= '' OR A.Id_Application = @piIdApplication) AND
			(@pvShortDesc		= '' OR A.Short_Desc LIKE '%' +  @pvShortDesc + '%')	
		ORDER BY  Id_Catalog
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_Applications
		SET 
			Short_Desc				= @pvShortDesc,
			Long_Desc				= @pvLongDesc,
			[Version]				= @pvVersion,
			Technical_Description	= @pvTechnicalDescription,
			[Type]					= @pvType,
			[Status]				= @pbStatus,
			Modify_By				= @pvUser,
			Modify_Date				= GETDATE(),
			Modify_IP				= @pvIP
		WHERE Id_Application = @piIdApplication 
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