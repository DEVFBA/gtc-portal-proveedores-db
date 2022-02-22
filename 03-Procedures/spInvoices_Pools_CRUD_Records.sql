USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spInvoices_Pools_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spInvoices_Pools_CRUD_Records'

IF OBJECT_ID('[dbo].[spInvoices_Pools_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spInvoices_Pools_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Invoices_Pools | Create - Read - Upadate - Delete 
Date:		20/02/2022
Example:

        DECLARE  @udtInvoicesPools	    UDT_Invoices_Pools

        INSERT INTO @udtInvoicesPools VALUES ('COMENTS','9124af96-d208-4e23-8543-d92e6440fc0b',152)
        INSERT INTO @udtInvoicesPools VALUES ('COMENTS','051e098d-d468-4480-852b-fb2f29f1330d',153)
		SELECT * FROM @udtInvoicesPools


        EXEC spInvoices_Pools_CRUD_Records	@pvOptionCRUD = 'C', 
                                            @pudtInvoicesPools = @udtInvoicesPools,
                                            @pvUser = 'AZEPEDA', 
                                            @pvIP ='192.168.1.254'
        
        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'R'  

        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'R', @piIdInvoicePoole = 1

        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'U'
        
        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'D'

        SELECT * FROM Invoices_Pools


*/
CREATE PROCEDURE [dbo].spInvoices_Pools_CRUD_Records
@pvOptionCRUD			Varchar(1),
@piIdInvoicePoole       Numeric = 0,
@pudtInvoicesPools	    UDT_Invoices_Pools Readonly,
@pvUser					Varchar(50) = '',
@pvIP				    Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
    DECLARE @iNumRegistros		Int			= (SELECT COUNT(*) FROM @pudtInvoicesPools)
	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Invoices_Pools - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdInvoicePoole = '" + ISNULL(CAST(@piIdInvoicePoole AS VARCHAR),'NULL') + "', @pudtInvoicesPools = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
    --------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN	
            -----------------------		
			--Insert Header
            -----------------------
			INSERT INTO Invoices_Pools_Header (
                Comments,
                Modify_By,
                Modify_Date,
                Modify_IP)

			
            SELECT DISTINCT 
                Comments,
                @pvUser,
                GETDATE(),
                @pvIP
            FROM @pudtInvoicesPools
            
            --Obtine el Id_Invoice_Pool
            SET @piIdInvoicePoole = @@IDENTITY

            -----------------------		
			--Insert Detail
            -----------------------
            INSERT INTO Invoices_Pools_Detail (
                Id_Invoice_Pool,
                UUID,
                Id_Workflow)

            SELECT 
                @piIdInvoicePoole,
                UUID,
                Id_Workflow
            FROM @pudtInvoicesPools   
	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT  PH.Id_Invoice_Pool,
                PH.Comments,
                PD.UUID,
                PD.Id_Workflow,
				PH.Modify_By,
				PH.Modify_Date,
				PH.Modify_IP
		FROM Invoices_Pools_Header PH

		INNER JOIN Invoices_Pools_Detail PD ON 
		PH.Id_Invoice_Pool = PD.Id_Invoice_Pool

		WHERE 
		(@piIdInvoicePoole	= 0	 OR PH.Id_Invoice_Pool = @piIdInvoicePoole) 
		ORDER BY  PH.Id_Invoice_Pool, PD.UUID	
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
	--Invalid Option
	--------------------------------------------------------------------
	IF @vDescOperationCRUD = 'N/A'
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