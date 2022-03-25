USE PortalProveedores
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- spInvoices_CRUD_Records
/* ==================================================================================*/	
PRINT 'Crea Procedure: spInvoices_CRUD_Records'

IF OBJECT_ID('[dbo].[spInvoices_CRUD_Records]','P') IS NOT NULL
       DROP PROCEDURE [dbo].spInvoices_CRUD_Records
GO

/*
Autor:		Alejandro Zepeda
Desc:		Carta_Porte | Create - Read - Upadate - Delete 
Date:		04/09/2021
Example:

select newid()
			EXEC spInvoices_CRUD_Records	@pvOptionCRUD				= 'C', 
											@pvUUID						= 'D48F641F-E656-4B35-AAF6-DBAEA5D61F60',
											@pvIdInvoiceType			= 'ICP',
											@piIdCompany				= 1,
											@piIdVendor					= 1,
											@pvIdReceiptType			= 'I',
											@pvIdEntityType				= 'M',
											@pvIdCurrency				= 'MXN',
											@pvSerie					= 'Serie',
											@pvFolio					= 'Folio',
											@pvInvoiceDate				= '20211109',
											@pvXMLPath					= 'C:\repository\archivo.xml',
											@pvPDFPath					= 'C:\repository\archivo.pdf',
											@piRequestNumber			= 1234,
											@pvDueDate					= '',
											@pvPaymentDate				= '',
											@pvIdWorkflowType			= 'WF-CPAS',
											@piIdWorkflowStatus			= 100, 
											@piIdWorkflowStatusChange	= 900,
											@pvWorkflowComments			= 'Carga de archivo',
											@pfSubTotal					= 100,
											@pfTransferred_Taxes		= 200,
											@pfWithholded_Taxes			= 300,
											@pfTotal					= 400,	
											@pvIdAgreementStatus		= null,
											@pvDocumentId				= 'DocId',
											@pvAgreementId				= 'AgreementId',
											@pvNextSigner				= 'NextSigner',
											@pvUser				= 'AZEPEDA',
											@pvIP				= '0.0.0.0'

			EXEC spInvoices_CRUD_Records @pvOptionCRUD = 'R'

			EXEC spInvoices_CRUD_Records @pvOptionCRUD = 'R', 
											@pvUUID = 'AF1170EE62-8715-4FF1-883D-923FDBC59DF1', 
											@pvCompanyTaxId = 'IPM6203226B4', 
											@pvVendorTaxId = 'ACT6808066SA', 
											@pvSerie = 'A', 
											@pvFolio = '001', 
											@pvInvoiceDate='20211116', @pvInvoiceDateFinal = '20211116'

			EXEC spInvoices_CRUD_Records @pvOptionCRUD = 'R', @piIdWorkflowStatus = 5			
			EXEC spInvoices_CRUD_Records @pvOptionCRUD = 'R', @pvVendorTaxId= 'SA',
			EXEC spInvoices_CRUD_Records @pvOptionCRUD = 'R', @pvSerieFolio= 'SerieFolio'

			EXEC spInvoices_CRUD_Records @pvOptionCRUD	= 'U', 
											@pvUUID			= 'D48F641F-E656-4B35-AAF6-DBAEA5D61F54',
											@pbStatus		= 1,
											@pvDueDate		= '20220131',
											@pvPaymentDate	= '20220201',
											@pvUser			= 'AZEPEDA', 
											@pvIP			='192.168.1.254'
			
			EXEC spInvoices_CRUD_Records @pvOptionCRUD = 'D', @piIdCompany = 2, @piIdVendor = 1

select * from Invoices
select * from workflow where Record_Identifier = '79b8d399-5d14-477a-9ac5-a86286a8702c'
*/
CREATE PROCEDURE [dbo].spInvoices_CRUD_Records
@pvOptionCRUD				Varchar(1),
@pvUUID						Varchar(50) = '',
@pnIdWorkflow				Numeric		= 0,
@pvIdInvoiceType			Varchar(10) = '',
@piIdCompany				Int			= 0,
@pvCompanyTaxId				Varchar(20) = '',
@piIdVendor					Int			= -1,
@pvVendorTaxId				Varchar(20) = '',
@pvIdReceiptType			Varchar(10) = '',
@pvIdEntityType				Varchar(10) = '',
@pvIdCurrency				Varchar(50) = '',
@pvSerie					Varchar(50) = '',
@pvFolio					Varchar(50) = '',
@pvSerieFolio				Varchar(100) = '',
@pvInvoiceDate				Varchar(8) = '',
@pvInvoiceDateFinal			Varchar(8) = '',
@pvXMLPath					Varchar(255) = '',
@pvPDFPath					Varchar(255)= '',
@piRequestNumber			Int			= 0,
@pvDueDate					Varchar(8) = '',
@pvPaymentDate				Varchar(8) = '',
@pvIdWorkflowType			Varchar(10) = 'WF-CP',
@piIdWorkflowStatus			Int			= 0, 
@piIdWorkflowStatusChange	Int			= 0,
@pvWorkflowComments			Varchar(MAX)= '',
@pfSubTotal					Float 		= 0,
@pfTransferred_Taxes		Float 		= 0,
@pfWithholded_Taxes			Float 		= 0,
@pfTotal					Float 		= 0,
@pbStatus					Bit			= 1,
@pvUser						Varchar(50) = '',
@pvIP						Varchar(20) = ''
WITH ENCRYPTION AS

SET NOCOUNT ON
BEGIN TRY

	--------------------------------------------------------------------
	--Variables work
	--------------------------------------------------------------------
	DECLARE @TblResponse TABLE (Code smallint, Code_Classification Varchar(50), Code_Type Varchar(50), Code_Message_User Varchar(MAX) , Code_Successful Bit,  IdTransacLog Numeric , IdWorkflow Numeric) 

	--------------------------------------------------------------------
	--Variables for log control
	--------------------------------------------------------------------
	DECLARE	@nIdTransacLog		Numeric
	DECLARE @vDescOperationCRUD Varchar(50)		= dbo.fnGetOperationCRUD(@pvOptionCRUD)
	DECLARE @vDescription		Varchar(255)	= 'Invoices - ' + @vDescOperationCRUD 
	DECLARE @iCode				Int				= dbo.fnGetCodes(@pvOptionCRUD)	
	DECLARE @vExceptionMessage	Varchar(MAX)	= ''
	DECLARE @vExecCommand		Varchar(Max)	= "EXEC spInvoices_CRUD_Records @pvOptionCRUD =  '" + ISNULL(@pvOptionCRUD,'NULL') + "', @pvUUID =  '" + ISNULL(@pvUUID,'NULL') + "', @pnIdWorkflow = " + ISNULL(CAST(@pnIdWorkflow AS VARCHAR),'NULL') + ", @pvIdInvoiceType = '" + ISNULL(CAST(@pvIdInvoiceType AS VARCHAR),'NULL') + "', @piIdCompany = " + ISNULL(CAST(@piIdCompany AS VARCHAR),'NULL') + ", @piIdVendor = " + ISNULL(CAST(@piIdVendor AS VARCHAR),'NULL') + ", @pvIdReceiptType = '" + ISNULL(@pvIdReceiptType,'NULL') + "', @pvIdEntityType = '" + ISNULL(@pvIdEntityType,'NULL') + "', @pvIdCurrency = '" + ISNULL(@pvIdCurrency,'NULL') + "', @pvSerie = '" + ISNULL(@pvSerie,'NULL') + "', @pvFolio = '" + ISNULL(@pvFolio,'NULL') + "', @pvInvoiceDate = '" + ISNULL(@pvInvoiceDate,'NULL') + "', @pvXMLPath = '" + ISNULL(@pvXMLPath,'NULL') + "', @pvPDFPath = '" + ISNULL(@pvPDFPath,'NULL') + "', @piRequestNumber = " + ISNULL(CAST(@piRequestNumber AS VARCHAR),'NULL') + ", @pvUser = '" + ISNULL(@pvUser,'NULL') + "', @pvDueDate = '" + ISNULL(@pvDueDate,'NULL') + "', @pvPaymentDate = '" + ISNULL(@pvPaymentDate,'NULL') + "', @pvIdWorkflowType = '" + ISNULL(@pvIdWorkflowType,'NULL') + "', @piIdWorkflowStatus = '" + ISNULL(CAST(@piIdWorkflowStatus AS VARCHAR),'NULL') + "', @piIdWorkflowStatusChange = '" + ISNULL(CAST(@piIdWorkflowStatusChange AS VARCHAR),'NULL') + "', @pvWorkflowComments = '" + ISNULL(@pvWorkflowComments,'NULL') + "', @pfSubTotal = '" + ISNULL(CAST(@pfSubTotal AS VARCHAR),'NULL') + "', @pfTransferred_Taxes = '" + ISNULL(CAST(@pfTransferred_Taxes AS VARCHAR),'NULL') + "', @pfWithholded_Taxes = '" + ISNULL(CAST(@pfWithholded_Taxes AS VARCHAR),'NULL') + "', @pfTotal = '" + ISNULL(CAST(@pfTotal AS VARCHAR),'NULL') + "', @pbStatus = '" + ISNULL(CAST(@pbStatus AS VARCHAR),'NULL') + "',  @pvIP = '" + ISNULL(@pvIP,'NULL') + "'"
	--------------------------------------------------------------------
	--Create Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'C'
	BEGIN
		-- Get Id Request
		IF EXISTS (SELECT * FROM Invoices WHERE UUID = @pvUUID)
		BEGIN
			SET @iCode	= dbo.fnGetCodes('Duplicate Record')	
		END
		ELSE
		BEGIN
			--Validaciones
			IF @pvDueDate		= '' SET @pvDueDate = NULL 
			IF @pvPaymentDate	= '' SET @pvPaymentDate = NULL 

			--Insert
			INSERT INTO Invoices (
					UUID,
					Id_Invoice_Type,
					Id_Company,
					Id_Vendor,
					Id_Receipt_Type,
					Id_Entity_Type,
					Id_Currency,
					Serie,
					Folio,
					Invoice_Date,
					XML_Path,
					PDF_Path,
					Request_Number,
					Due_Date,
					Payment_Date,
					[Status],
					SubTotal,
					Transferred_Taxes,
					Withholded_Taxes,
					Total,
					Modify_By,
					Modify_Date,
					Modify_IP)




			VALUES (@pvUUID,
					@pvIdInvoiceType,
					@piIdCompany,
					@piIdVendor,
					@pvIdReceiptType,
					@pvIdEntityType,
					@pvIdCurrency,
					@pvSerie,
					@pvFolio,
					@pvInvoiceDate,
					@pvXMLPath,
					@pvPDFPath,
					@piRequestNumber,
					@pvDueDate,
					@pvPaymentDate,
					@pbStatus,
					@pfSubTotal,
					@pfTransferred_Taxes,
					@pfWithholded_Taxes,
					@pfTotal,	
					@pvUser,
					GETDATE(),
					@pvIP	)

			-- INSERTA WF
			INSERT INTO @TblResponse
			EXEC spWorkflow_CRUD_Records 
									@pvOptionCRUD = 'C', 
									@pvIdWorkflowType = @pvIdWorkflowType, 
									@piIdWorkflowStatus = @piIdWorkflowStatus, 
									@piIdWorkflowStatusChange = @piIdWorkflowStatusChange,
									@pvRecordIdentifier = @pvUUID, 
									@pvComments = @pvWorkflowComments,  
									@pvUser = @pvUser, 
									@pvIP = @pvIP

		END
	END
	--------------------------------------------------------------------
	--Reads Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'R'
	BEGIN
		SELECT  
				CP.UUID,
				CP.Id_Invoice_Type,
				Invoice_Type_Desc = IT.Short_Desc,
				CP.Id_Workflow	,
				WF.Id_Workflow_Type,
				Id_Workflow_Status = WF.Id_Workflow_Status_Change,
				Workflow_Status = WS.Short_Desc,
				CP.Id_Company,
				Company			= C.Name,
				Company_RFC		= C.Tax_Id,
				Company_Status	= C.Status,
				CP.Id_Vendor,
				Vendor			= V.Name,
				Vendor_RFC		= V.Tax_Id,
				Vendorn_Status	= V.Status,
				CP.Id_Receipt_Type,
				Receipt_Type_Desc = RT.Short_Desc,
				CP.Id_Entity_Type,
				Entity_Type_Desc = ET.Short_Desc,
				CP.Id_Currency,
				Currency_Desc = CU.Short_Desc,
				CP.Serie,
				CP.Folio,
				CP.Invoice_Date,
				CP.XML_Path,
				CP.PDF_Path,
				CP.Request_Number,
				CP.Due_Date,
				CP.Payment_Date,
				CP.SubTotal,
				CP.Transferred_Taxes,
				CP.Withholded_Taxes,
				CP.Total,
				CP.[Status],
				CP.Modify_By,
				CP.Modify_Date,
				CP.Modify_IP

		FROM Invoices CP

		INNER JOIN Cat_Invoice_Types IT ON
		CP.Id_Invoice_Type = IT.Id_Invoice_Type

		INNER JOIN Companies C ON 
		CP.Id_Company = C.Id_Company

		INNER JOIN Cat_Vendors V ON 
		CP.Id_Vendor = V.Id_Vendor

		INNER JOIN SAT_Cat_Receipt_Types RT ON 
		CP.Id_Receipt_Type = RT.Id_Receipt_Type

		INNER JOIN SAT_Cat_Entity_Types ET ON 
		CP.Id_Entity_Type = ET.Id_Entity_Type

		INNER JOIN Workflow WF ON 
		CP.Id_Workflow = WF.Id_Workflow

		INNER JOIN Cat_Workflow_Status WS ON
		WF.Id_Workflow_Type = WS.Id_Workflow_Type AND
		WF.Id_Workflow_Status_Change = WS.Id_Workflow_Status

		INNER JOIN SAT_Cat_Currencies CU ON 
		CP.Id_Currency = CU.Id_Currency			

		WHERE
		(@pnIdWorkflow			= 0	 OR CP.Id_Workflow = @pnIdWorkflow) AND
		(@pvUUID				= '' OR CP.UUID LIKE '%' + @pvUUID + '%') AND
		(@pvSerie				= '' OR CP.Serie LIKE '%' +  @pvSerie + '%') AND
		(@pvFolio				= '' OR CP.Folio LIKE '%' +  @pvFolio + '%') AND
		(@piIdCompany			= 0	 OR CP.Id_Company = @piIdCompany) AND
		(@pvCompanyTaxId		= '' OR C.Tax_Id LIKE '%' +  @pvCompanyTaxId + '%') AND
		(@piIdVendor			= -1 OR CP.Id_Vendor = @piIdVendor) AND
		(@pvVendorTaxId			= '' OR V.Tax_Id LIKE '%' +  @pvVendorTaxId + '%') AND				
		(@pvInvoiceDate			= '' OR CONVERT(VARCHAR(10),CP.Invoice_Date,112) BETWEEN @pvInvoiceDate AND @pvInvoiceDateFinal) AND 
		(@piIdWorkflowStatus	= 0  OR WF.Id_Workflow_Status_Change = @piIdWorkflowStatus ) AND
		(@pvSerieFolio			= '' OR RTRIM(LTRIM(CP.Serie)) + RTRIM(LTRIM(CP.Folio)) =  @pvSerieFolio) AND 
		(@pvIdCurrency			= 0	 OR CP.Id_Currency = @pvIdCurrency)
		ORDER BY CP.UUID, CP.Id_Workflow, CP.Id_Company, CP.Id_Vendor 		
	END

	--------------------------------------------------------------------
	--Update Records
	--------------------------------------------------------------------
	IF @pvOptionCRUD = 'U'
	BEGIN
		-- Actualiza el estatus
		IF @pbStatus <> 1
		BEGIN
			UPDATE Invoices
			SET [Status]	= @pbStatus,
				Modify_By	= @pvUser,
				Modify_Date	= GETDATE(),
				Modify_IP	= @pvIP
			WHERE UUID = @pvUUID
		END

		-- Actualiza @pvDueDate
		IF @pvDueDate <> '' 
		BEGIN
			UPDATE Invoices
			SET Due_Date		= @pvDueDate,
				Modify_By	= @pvUser,
				Modify_Date	= GETDATE(),
				Modify_IP	= @pvIP
			WHERE UUID = @pvUUID
		END


		IF @pvPaymentDate <> ''
		BEGIN
			UPDATE Invoices
			SET Payment_Date		= @pvPaymentDate,
				Modify_By	= @pvUser,
				Modify_Date	= GETDATE(),
				Modify_IP	= @pvIP
			WHERE UUID = @pvUUID
		END
		
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