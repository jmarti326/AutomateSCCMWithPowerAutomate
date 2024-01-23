USE [CM_LAB]
GO

/****** Object:  StoredProcedure [automation].[uspAddOrUpdateDeviceCustomProperty]    Script Date: 1/23/2024 8:58:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--CREATE SCHEMA automation
--GO
CREATE PROCEDURE [automation].[uspAddOrUpdateDeviceCustomProperty]
	@strPropertyName VARCHAR(50),
	@strPropertyValue VARCHAR(50),
	@strDeviceName VARCHAR(50)
AS
BEGIN
	DECLARE 
		@TodaysDate DATETIME = GETDATE(),
		@Editor VARCHAR(50) = 'INTERNAL\sccmlabadmin',
		@PropertyName VARCHAR(50) = @strPropertyName,
		@PropertyValue VARCHAR(50) = @strPropertyValue,
		@DeviceName VARCHAR(50) = @strDeviceName,
		@PropertyId INT = NULL,
		@ResourceId INT = NULL;

	BEGIN TRY
		-- Look for the propertyId of the property name.
		SELECT 
			@PropertyId = DER.PropertyId
		FROM 
			dbo.DeviceExtensionRegistration DER
		WHERE
			DER.PropertyName = @PropertyName

		SELECT
			@ResourceId = SMSRS.ItemKey
		FROM
			dbo.vSMS_R_SYSTEM SMSRS
		WHERE
			SMSRS.Name0 = @DeviceName

		BEGIN TRANSACTION;

		IF (@PropertyId IS NULL)
			INSERT INTO DeviceExtensionData 
			(
				ResourceId,
				PropertyId,
				Value,
				CreatedBy,
				CreatedDate,
				ModifiedBy,
				ModifiedDate

			) values 
			(
				@ResourceId, 
				@PropertyId, 
				@PropertyValue, 
				@Editor, 
				@TodaysDate, 
				@Editor, 
				@TodaysDate
			)
		ELSE
			UPDATE DeviceExtensionData
			SET
				Value = @PropertyValue,
				ModifiedBy = @Editor,
				ModifiedDate = @TodaysDate
			WHERE
				ResourceId = @ResourceId
				AND PropertyId = @PropertyId

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		-- report exception
		SELECT  
			ERROR_NUMBER() AS ErrorNumber,  
            ERROR_SEVERITY() AS ErrorSeverity,  
            ERROR_STATE() AS ErrorState,  
            ERROR_PROCEDURE() AS ErrorProcedure,  
            ERROR_LINE() AS ErrorLine,  
            ERROR_MESSAGE() AS ErrorMessage;
		
		-- Is Transaction uncommittable?
		IF(XACT_STATE()) = -1
		BEGIN
			PRINT 'The transaction is in an uncommittable state. Rolling back transaction.'
			ROLLBACK TRANSACTION;
		END;

		IF (XACT_STATE()) = 1  
        BEGIN  
            PRINT N'The transaction is committable. Committing transaction.'  
            COMMIT TRANSACTION;     
        END;  
	END CATCH
END
GO


