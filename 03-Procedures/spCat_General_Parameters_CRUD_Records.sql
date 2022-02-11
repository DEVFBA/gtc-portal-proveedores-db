USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spCat_General_Parameters_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spCat_General_Parameters_CRUD_Records'

IF OBJECT_ID('[dbo].[spCat_General_Parameters_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spCat_General_Parameters_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Cat_General_Parameters | Create - Read - Upadate - Delete 
Date:		01/01/2021
Example:
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'C', @piIdParameter = 1 , @pvLongDesc = 'Allow Cost / Margin View', @pvValue = '0', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'R'
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'R', @pvType ='User'
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'R', @piIdParameter = 1
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'U', @piIdParameter = 1 , @pvLongDesc = 'Allow Cost / Margin View', @pvValue = '0', @pvUser = 'AZEPEDA', @pvIP ='192.168.1.254'
			spCat_General_Parameters_CRUD_Records @pvOptionCRUD = 'D', @piIdParameter = 1
			
*/
CREATE PROCEDURE [dbo].spCat_General_Parameters_CRUD_Records
@pvOptionCRUD		Varchar(1),
@piIdParameter		INT = 0,
@pvIdGrouper		Varchar(10) ='',
@pvLongDesc			Varchar(255)= '',
@pvValue			Varchar(MAX)= '',
@pvType				Varchar(50) = '',
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
	DECLARE @vDescription		Varchar(255)	= 'Cat_General_Parameters - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand	Varchar(Max)	= "EXEC spCat_General_Parameters_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdParameter = '" + ISNULL(CAST(@piIdParameter AS varchar),'NULL') + "', @pvLongDesc = '" + ISNULL(@pvLongDesc,'NULL') + "', @pvValue = '" + ISNULL(CAST(@pvValue AS VARCHAR),'NULL') + "', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
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
		Id_Catalog = P.Id_Parameter,
		P.Id_Grouper,
		Grouper_Desc = G.Short_Desc,
		P.Long_Desc,
		P.[Value],
		P.[Type],
		P.Data_Type,
		P.[Status],
		P.Modify_By,
		P.Modify_Date,
		P.Modify_IP
		FROM Cat_General_Parameters P
		LEFT OUTER JOIN Cat_Groupers G ON
		P.Id_Grouper = G.Id_Grouper
		WHERE (@piIdParameter = 0 OR P.Id_Parameter = @piIdParameter) AND  
			  (@pvIdGrouper = '' OR P.Id_Grouper = @pvIdGrouper) AND  
			  (@pvType = '' OR [Type] = @pvType)

		ORDER BY Id_Catalog,P.Id_Grouper

	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		UPDATE Cat_General_Parameters 
		SET 
			Long_Desc	= @pvLongDesc,
			[Value]		= @pvValue,
			Modify_Date	= GETDATE(),
			Modify_By	= @pvUser,
			Modify_IP	= @pvIP
		WHERE  Id_Parameter = @piIdParameter
	
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