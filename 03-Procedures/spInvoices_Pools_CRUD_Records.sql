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

        INSERT INTO @udtInvoicesPools VALUES ('COMMENTS','2e58a46a-88bd-4bce-aceb-5f8b727e7cd1',284)
        INSERT INTO @udtInvoicesPools VALUES ('COMMENTS','15f95f6a-3451-4530-a3e1-8eb95381d180',285)
		--SELECT * FROM @udtInvoicesPools



        EXEC spInvoices_Pools_CRUD_Records	@pvOptionCRUD 				= 'C', 
                                            @pudtInvoicesPools 			= @udtInvoicesPools,
                                            @piIdCompany				= 1,
											@piIdVendor					= 1,
											@fTotalInvoices				= 1000,
											@fTotalAmount				= 2000,
											@pvIdWorkflowType			= 'WF-POOL',
											@piIdWorkflowStatus			= 100,
											@piIdWorkflowStatusChange	= 100,
											@pvUser 					= 'AZEPEDA', 
                                            @pvIP 						='192.168.1.254'
        
        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'R'  

        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'R', @piIdInvoicePool = 27

        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'U'
        
        EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'D'

		EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD = 'G', @piIdInvoicePool = 21

        SELECT * FROM Invoices_Pools_Header
		SELECT * FROM Invoices_Pools_Detail
		SELECT * FROM workflow where Id_workflow in (497,498,502)


*/
CREATE PROCEDURE [dbo].spInvoices_Pools_CRUD_Records
@pvOptionCRUD				Varchar(1),
@piIdInvoicePool        	Numeric = 0,
@pudtInvoicesPools	    	UDT_Invoices_Pools Readonly,
@piIdCompany				Int			= 0,
@piIdVendor					Int			= -1,
@fTotalInvoices				float		= 0,
@fTotalAmount				float		= 0,		
@pnIdWorkflow				Numeric		= 0,
@pvIdWorkflowType			Varchar(10) = '',
@piIdWorkflowStatus			Int			= 0, 
@piIdWorkflowStatusChange	Int			= 0,		
@pvUser						Varchar(50) = '',
@pvIP				    	Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY
	--------------------------------------------------------------------
	--Work Variables
	--------------------------------------------------------------------
    DECLARE @iNumRegistros	Int			= (SELECT COUNT(*) FROM @pudtInvoicesPools)
	DECLARE @TblResponse 	Table (Code smallint, Code_Classification Varchar(50), Code_Type Varchar(50), Code_Message_User Varchar(MAX) , Code_Successful Bit,  IdTransacLog Numeric , IdWorkflow Numeric) 
	DECLARE @vComments 		Varchar(MAX) = (SELECT TOP 1 Comments FROM @pudtInvoicesPools )

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	Declare @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Invoices_Pools - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spInvoices_Pools_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @piIdInvoicePool = '" + ISNULL(CAST(@piIdInvoicePool AS VARCHAR),'NULL') + "', @pudtInvoicesPools = '" + ISNULL(CAST(@iNumRegistros AS VARCHAR),'NULL') + " rows affected', @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	
    --------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN	

			
            -----------------------		
			--Insert Header
            -----------------------
			INSERT INTO Invoices_Pools_Header (
				Id_Company,
				Id_Vendor,
				Pool_Date,
				Total_Invoices,
				Total_Amount,
				Comments,
				Modify_By,
				Modify_Date,
				Modify_IP)

			
            VALUES(
				@piIdCompany,
				@piIdVendor,
				GETDATE(),
				@fTotalInvoices,
				@fTotalAmount,
                @vComments,
                @pvUser,
                GETDATE(),
                @pvIP)
      
            
            --Obtine el Id_Invoice_Pool
            SET @piIdInvoicePool = @@IDENTITY

            -----------------------		
			--Insert Detail
            -----------------------
            INSERT INTO Invoices_Pools_Detail (
                Id_Invoice_Pool,
                UUID,
                Id_Workflow)

            SELECT 
                @piIdInvoicePool,
                UUID,
                Id_Workflow
            FROM @pudtInvoicesPools   


			-- INSERTA WF
			INSERT INTO @TblResponse
			EXEC spWorkflow_CRUD_Records 
									@pvOptionCRUD 				= 'C', 
									@pvIdWorkflowType 			= @pvIdWorkflowType, 
									@piIdWorkflowStatus	 		= @piIdWorkflowStatus, 
									@piIdWorkflowStatusChange 	= @piIdWorkflowStatusChange,
									@pvRecordIdentifier 		= @piIdInvoicePool, 
									@pvComments 				= @vComments,  
									@pvUser 					= @pvUser, 
									@pvIP 						= @pvIP
	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT  --Headers
				PH.Id_Invoice_Pool,
				Header_Id_Company 		= PH.Id_Company,
				Header_Company 			= CH.Name,
				Header_Id_Vendor 		= PH.Id_Vendor,
				Header_Vendor 			= VH.Name,
				Header_Pool_Date 		= PH.Pool_Date,
				Header_Total_Invoices 	= PH.Total_Invoices,
				Header_Total_Amount 	= PH.Total_Amount,			
                Header_Comments 		= PH.Comments,
				Header_Id_Workflow 		= PH.Id_Workflow,
				Header_Id_Workflow_Status_Change = WF.Id_Workflow_Status_Change,
				Header_Workflow_Status_Change = WS.Short_Desc,
				--Details
                PD.UUID,
				I.Id_Company,
				Company = C.Name,
				I.Id_Vendor,
				Vendor = V.Name,
				I.Serie,
				I.Folio,
				I.SubTotal,
				I.Transferred_Taxes,
				I.Withholded_Taxes,
				I.Total,
                PD.Id_Workflow,
				PH.Modify_By,
				PH.Modify_Date,
				PH.Modify_IP
		FROM Invoices_Pools_Header PH

		INNER JOIN Invoices_Pools_Detail PD ON 
		PH.Id_Invoice_Pool = PD.Id_Invoice_Pool

		INNER JOIN Invoices I ON
		PD.UUID = I.UUID

		INNER JOIN Companies C ON 
		I.Id_Company = C.Id_Company AND
		C.[Status] = 1
		
		INNER JOIN Cat_Vendors V ON
		I.Id_Vendor = V.Id_Vendor AND
		V.[Status] = 1

		INNER JOIN Companies CH ON 
		PH.Id_Company = CH.Id_Company AND
		CH.[Status] = 1
		
		INNER JOIN Cat_Vendors VH ON
		PH.Id_Vendor = VH.Id_Vendor AND
		VH.[Status] = 1

		INNER JOIN Workflow WF ON 
		PH.Id_Workflow = WF.Id_Workflow

		INNER JOIN Cat_Workflow_Status WS ON 
		WF.Id_Workflow_Type = WS.Id_Workflow_Type AND 
		WF.Id_Workflow_Status_Change = WS.Id_Workflow_Status

		WHERE 
		(@piIdInvoicePool	= 0	 OR PH.Id_Invoice_Pool = @piIdInvoicePool) 
		ORDER BY  PH.Id_Invoice_Pool, PD.UUID	
	END

	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'G'
	BEGIN
	SET LANGUAGE Spanish
		SELECT 	[Month] 			= MONTH(I.Invoice_Date),
				[MonthName] 		= DATENAME(MONTH,I.Invoice_Date),
				SubTotal 			= SUM(SubTotal),
				Transferred_Taxes 	= SUM(Transferred_Taxes),
				Withholded_Taxes 	= SUM(Withholded_Taxes),
				Total				= SUM(Total)
		FROM Invoices_Pools_Detail PD
		INNER JOIN Invoices I ON
		PD.UUID = I.UUID
		WHERE Id_Invoice_Pool = @piIdInvoicePool
		GROUP BY MONTH(I.Invoice_Date), DATENAME(MONTH,I.Invoice_Date)
		ORDER BY MONTH(I.Invoice_Date)
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
	
	IF @pvOptionCRUD NOT IN('R','G')
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog, Id_Invoice_Pool = @piIdInvoicePool FROM vwSecurityCodes WHERE Code = @iCode

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
	SELECT Code, Code_Classification, Code_Type , Code_Message_User, Code_Successful,  IdTransacLog = @nIdTransacLog, Id_Invoice_Pool = @piIdInvoicePool FROM vwSecurityCodes WHERE Code = @iCode
		
END CATCH