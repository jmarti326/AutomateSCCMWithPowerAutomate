SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [automation].[uspGetSCCMReportData]
AS
SET NOCOUNT ON;
BEGIN
	
	DECLARE 
        @COLUMNS VARCHAR(MAX),
        @SqlStatement VARCHAR(MAX)

    SELECT 
        @COLUMNS = coalesce(@COLUMNS + ', ', '') +  '[' + convert(varchar(255),PropertyName) + ']'
    FROM 
        DeviceExtensionRegistration
    ORDER BY 
        PropertyName

    SET @SqlStatement = N'select * from (
    select
        vSMS_R_SYSTEM.ItemKey,
        vSMS_R_SYSTEM.Client_Type0,
        vSMS_R_SYSTEM.Name0,
        vSMS_R_SYSTEM.SMS_Unique_Identifier0,
        vSMS_R_SYSTEM.Resource_Domain_OR_Workgr0,
        vSMS_R_SYSTEM.Client0,
    	v_SMS_G_System_ExtensionData.PropertyName,
    	v_SMS_G_System_ExtensionData.PropertyValue
    from vSMS_R_System left join v_SMS_G_System_ExtensionData 
    on v_SMS_G_System_ExtensionData.ResourceId = vSMS_R_System.ItemKey) t
    pivot
    (
    MAX(PropertyValue) FOR PropertyName IN ('+ @COLUMNS +')
    )
    AS PivotTable;'
    
    EXEC(@SqlStatement)
END
GO
