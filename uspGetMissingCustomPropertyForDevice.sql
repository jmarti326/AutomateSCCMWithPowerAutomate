SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [automation].[uspGetMissingCustomPropertyForDevice]
AS
SET NOCOUNT ON;
BEGIN
	
	-- Look for the list of missing custom properties for each device.

	-- SELECT DISTINCT 
	-- 	--DED.ResourceId,
	-- 	S.ItemKey,
	-- 	CP.CustomPropertyName,
	-- 	S.Name0
	-- FROM
	-- 	vSMS_R_System S
	-- LEFT OUTER JOIN
	-- 	DeviceExtensionData DED
	-- ON
	-- 	S.ItemKey = DED.ResourceId
	-- JOIN 
	-- 	DeviceExtensionRegistration DER
	-- ON 
	-- 	DED.PropertyId = DER.PropertyId 
	-- 	OR DED.ResourceId IS NULL
	-- JOIN 
	-- 	automation.CustomProperties CP
	-- ON 
	-- 	cp.CustomPropertyName <> DER.PropertyName
	-- WHERE 
	-- 	CP.IsEnabled = 1
	-- 	AND S.Operating_System_Name_and0 like '%server%' 
    WITH Servers_CTE
    AS
    (
        Select 
            S.ItemKey AS ResourceId,
            S.Name0 AS ResourceName
        FROM
            vSMS_R_System S
        where S.Operating_System_Name_and0 like '%server%' 
    ),
    ServersAndTheirCustomProperties_CTE
    AS
    (
        SELECT 
            S.ResourceId,
            S.ResourceName,
            DED.PropertyId 
        FROM 
            Servers_CTE S
        LEFT JOIN 
            DeviceExtensionData DED 
        ON 
            S.ResourceId = DED.ResourceId
    )

    SELECT DISTINCT TOP 1
        SATCP.ResourceId, 
        SATCP.ResourceName, 
        DER.PropertyId, 
        DER.PropertyName--, 
        --IIF(SATCP.PropertyId IS NULL OR SATCP.PropertyId <> DER.PropertyId, 1, 0) AS IsMissing 
    FROM 
        DeviceExtensionRegistration DER
    LEFT JOIN 
        ServersAndTheirCustomProperties_CTE SATCP
    ON
        (DER.PropertyId = SATCP.PropertyId OR NULL IS NULL)
    WHERE
        (
            SATCP.PropertyId IS NULL 
            OR SATCP.PropertyId <> DER.PropertyId
        )
END
GO
