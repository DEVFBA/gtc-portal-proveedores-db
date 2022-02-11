USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spSAT_Cat_Zip_Codes_Counties_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spSAT_Cat_Zip_Codes_Counties_CRUD_Records'

IF OBJECT_ID('[dbo].[spSAT_Cat_Zip_Codes_Counties_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spSAT_Cat_Zip_Codes_Counties_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		SAT_Cat_Zip_Codes_Counties | Create - Read - Upadate - Delete 
Date:		05/09/2021
Example:
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'C'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R', @pvZip_Code = '52765'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX', @pvIdState = 'MEX'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX', @pvIdState = 'MEX',  @pvIdMunicipality = '005'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX', @pvIdState = 'MEX',  @pvIdMunicipality = '003', @pvIdLocation = '03'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R', @pvIdCountry = 'MEX', @pvIdState = 'MEX',  @pvIdMunicipality = '003', @pvIdCounty = '03'

			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'U'
			spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'D's
			select * from SAT_Cat_Zip_Codes_Counties

			EXEC spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD = 'R', @pvZip_Code = '72810', @pvIdCountry = 'MEX', 
											   @pvIdState = 'PUE', @pvIdLocation = '07', @pvIdMunicipality = '119';
*/
CREATE PROCEDURE [dbo].spSAT_Cat_Zip_Codes_Counties_CRUD_Records
@pvOptionCRUD		Varchar(1),
@pvIdCountry		Varchar(50)	= '',
@pvIdState			Varchar(10)	= '',
@pvIdMunicipality	Varchar(10)	= '',
@pvIdLocation		Varchar(10)	= '',
@pvZip_Code			Varchar(10)	= '',
@pvIdCounty			Varchar(10)	= '',
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
	DECLARE @vDescription		Varchar(255)	= 'SAT_Cat_Zip_Codes_Counties - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spSAT_Cat_Zip_Codes_Counties_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvIdCountry = '" + ISNULL(CAST(@pvIdCountry AS VARCHAR),'NULL') + "', @pvIdState = '" + ISNULL(@pvIdState,'NULL') + "', @pvIdMunicipality = '" + ISNULL(@pvIdMunicipality,'NULL') + "', @pvIdLocation = '" + ISNULL(@pvIdLocation,'NULL') + "', @pvZip_Code = '" + ISNULL(@pvZip_Code,'NULL') + "', @pvIdCounty = '" + ISNULL(@pvIdCounty,'NULL') + "', @pvDescription = '" + ISNULL(@pvDescription,'NULL') + "',  @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
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
		ZC.Id_Country,
		Country_Desc = C.Short_Desc,
		ZC.Id_State,
		State_Desc = S.[Description],
		ZC.Id_Municipality,
		Municipality_Desc = M.[Description],
		ZC.Id_Location,
		Location_Desc = L.[Description],
		ZC.Zip_Code,
		ZC.Id_County,
		ZC.[Description],
		ZC.[Status],
		ZC.Modify_By,
		ZC.Modify_Date,
		ZC.Modify_IP
		FROM SAT_Cat_Zip_Codes_Counties ZC
		
		INNER JOIN SAT_Cat_Countries C ON 
		ZC.Id_Country = C.Id_Country AND
		C.[Status] = 1

		INNER JOIN SAT_CAT_States S ON 
		ZC.Id_Country = S.Id_Country AND
		ZC.Id_State = S.Id_State AND
		S.[Status] = 1

		INNER JOIN SAT_Cat_Municipalities M ON 
		ZC.Id_Country = M.Id_Country AND
		ZC.Id_State = M.Id_State AND
		ZC.Id_Municipality = M.Id_Municipality AND
		M.[Status] = 1

		INNER JOIN SAT_Cat_Locations L ON 
		ZC.Id_Country = L.Id_Country AND
		ZC.Id_State = L.Id_State AND
		ZC.Id_Location = L.Id_Location AND
		L.[Status] = 1

		WHERE 
			(@pvIdCountry		= '' OR ZC.Id_Country = @pvIdCountry) AND
			(@pvIdState			= '' OR ZC.Id_State = @pvIdState) AND
			(@pvIdMunicipality	= '' OR ZC.Id_Municipality = @pvIdMunicipality) AND
			(@pvIdLocation		= '' OR ZC.Id_Location = @pvIdLocation) AND
			(@pvZip_Code		= '' OR ZC.Zip_Code = @pvZip_Code) AND
			(@pvIdCounty		= '' OR ZC.Id_County = @pvIdCounty) AND
			(@pvDescription		= '' OR ZC.[Description] LIKE '%' +  @pvDescription + '%')	
		ORDER BY  ZC.Id_Country,ZC.Id_State,ZC.Id_Municipality,ZC.Id_Location,ZC.Zip_Code,zc.Id_County
		
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