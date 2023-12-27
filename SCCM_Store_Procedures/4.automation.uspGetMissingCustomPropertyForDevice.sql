CREATE PROCEDURE automation.uspGetMissingCustomPropertyForDevice
AS
BEGIN
	-- Look for the list of missing custom properties for each device.

	SELECT DISTINCT 
		--DED.ResourceId,
		S.ItemKey,
		CP.CustomPropertyName,
		S.Name0
	FROM
		vSMS_R_System S
	LEFT OUTER JOIN
		DeviceExtensionData DED
	ON
		S.ItemKey = DED.ResourceId
	JOIN 
		DeviceExtensionRegistration DER
	ON 
		DED.PropertyId = DER.PropertyId 
		OR DED.ResourceId IS NULL
	JOIN 
		automation.CustomProperties CP
	ON 
		cp.CustomPropertyName <> DER.PropertyName
	WHERE 
		CP.IsEnabled = 1
		AND S.Operating_System_Name_and0 like '%server%' 
END