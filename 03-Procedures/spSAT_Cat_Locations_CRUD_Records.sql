USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSAT_Cat_Locations_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSAT_Cat_Locations_CRUD_Records'

IF OBJECT_ID('[dbo].[spSAT_Cat_Locations_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSAT_Cat_Locations_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		SAT_Cat_Locations | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD = 'C', @pvIdCountry = '', @pvIdState = '', @pvIdLocation = '', @pvDescription = 'Desc 001',  @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD = 'R'
			spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX'
			spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX', @pvIdState = 'MEX'
			spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX', @pvIdState = 'MEX', @pvIdLocation = '03'
			spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD = 'U', @pvIdCountry = '', @pvIdState = '',@pvDescription = 'Desc 001',  @pbStatus = 1, @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD = 'D'
			
*/
CREATE PROCEDURE [dbo].spSAT_Cat_Locations_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdCountry		Varchar(50)	= '',
@pvIdState			Varchar(10)	= '',
@pvIdLocation		Varchar(10)	= '',
@pvDescription		Varchar(50) = '',
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
	DECLARE @vDescription		Varchar(255)	= 'SAT_Cat_Locations - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spSAT_Cat_Locations_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdCountry = '" + ISNULL(CAST(@pvIdCountry AS VARCHAR),'NULL') + "', @pvIdState = '" + ISNULL(@pvIdState,'NULL') + "', @pvIdLocation = '" + ISNULL(@pvIdLocation,'NULL') + "', @pvDescription = '" + ISNULL(@pvDescription,'NULL') + "',  @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		SET @iCode	= dbo.fnGetCodes('Invalid Option')	
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT 
		L.Id_Country,
		Country_Desc = C.Short_Desc,
		L.Id_State,
		State_Desc = S.[Description],
		L.Id_Location,
		Location_Desc = L.[Description],
		L.[Status],
		L.Modify_By,
		L.Modify_Date,
		L.Modify_IP
		FROM SAT_Cat_Locations L
		
		INNER JOIN SAT_Cat_Countries C ON 
		L.Id_Country = C.Id_Country AND
		C.[Status] = 1

		INNER JOIN SAT_CAT_States S ON 
		L.Id_Country = S.Id_Country AND
		L.Id_State = S.Id_State AND
		S.[Status] = 1
		
		WHERE 
			(@pvIdCountry		= '' OR L.Id_Country = @pvIdCountry) AND
			(@pvIdState			= '' OR L.Id_State = @pvIdState) AND
			(@pvIdLocation	= ''	 OR L.Id_Location = @pvIdLocation) AND
			(@pvDescription		= '' OR L.[Description] LIKE '%' +  @pvDescription + '%')	
		ORDER BY  S.Id_Country,S.Id_State
		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		SET @iCode	= dbo.fnGetCodes('Invalid Option')	
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