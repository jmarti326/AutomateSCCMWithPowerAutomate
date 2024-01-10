USE [CM_LAB]
GO

/****** Object:  StoredProcedure [automation].[uspAddMissingCustomPropertyForDevice]    Script Date: 1/10/2024 3:50:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [automation].[uspAddMissingCustomPropertyForDevice]
    @pintResourceId INT,
    @pintPropertyId INT,
    @pstrCreatedBy VARCHAR(255),
    @pstrCreatedDate DATETIME
AS
BEGIN
	DECLARE 
		@PropertyId INT,
		@ResourceId INT,
        @AlreadyExist BIT = 0

	BEGIN TRY

        -- DOES RESOURCE EXIST?
		SELECT
			@ResourceId = SMSRS.ItemKey
		FROM
			dbo.vSMS_R_SYSTEM SMSRS
		WHERE
			SMSRS.ItemKey = @pintResourceId

        -- DOES CUSTOM PROPERTY EXIST?
        SELECT 
			@PropertyId = DER.PropertyId
		FROM 
			dbo.DeviceExtensionRegistration DER
		WHERE
			DER.PropertyId = @pintPropertyId

        -- IS THIS DEVICE ALREADY CONFIGURED TO USE THIS CUSTOM PROPERTY?
        SELECT
            TOP 1 @AlreadyExist = COUNT (DED.ID)
        FROM
            dbo.DeviceExtensionData DED
        WHERE
            DED.ResourceId = @pintResourceId
            AND DED.PropertyId = @pintPropertyId
        
		BEGIN TRANSACTION;
            IF
            (
                @AlreadyExist = 0 
                AND @ResourceId IS NOT NULL
                AND @PropertyId IS NOT NULL
            )
            INSERT INTO DeviceExtensionData 
			(
				ResourceId,
				PropertyId,
				--Value,
				CreatedBy,
				CreatedDate,
				ModifiedBy,
				ModifiedDate

			)
            VALUES 
			(
				@ResourceId, 
				@PropertyId, 
				--@PropertyValue, 
				@pstrCreatedBy, 
				@pstrCreatedDate, 
				@pstrCreatedBy, 
				@pstrCreatedDate
			)
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


