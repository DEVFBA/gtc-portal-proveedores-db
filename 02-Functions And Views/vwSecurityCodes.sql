USE PortalProveedores
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

/* ==================================================================================*/
-- vwQuotation
/* ==================================================================================*/	
PRINT 'Crea View: vwSecurityCodes'

IF OBJECT_ID('vwSecurityCodes','V') IS NOT NULL
       DROP VIEW [dbo].vwSecurityCodes
GO



/*
Autor:		Alejandro Zepeda
Desc:		Security Codes  View
Date:		23/10/2021
Example:
		SELECT * FROM vwSecurityCodes
*/

CREATE VIEW dbo.vwSecurityCodes
WITH ENCRYPTION AS

SELECT	Id_Code_Classification		= Code.Id_Code_Classification,
		Code_Classification	= CodeClassification.Short_Desc,
		Id_Code_Type					= Code.Id_Code_Type,
		Code_Type 				= CodeTypes.Short_Desc,
		Code,
		Code_Message_TI			= Code.Description_TI,
		Code_Message_User		= Code.Description_User,
		Code_Successful			= CodeTypes.Successful
	FROM Security_Codes Code
	
	INNER JOIN Security_Code_Types CodeTypes ON
	Code.Id_Code_Type = CodeTypes.Id_Code_Type

	INNER JOIN Security_Code_Classification CodeClassification ON
	Code.Id_Code_Classification = CodeClassification.Id_Code_Classification
