CREATE PROCEDURE automation.uspAddCustomProperty
	@strPropertyName VARCHAR(50)
AS
BEGIN
	DECLARE 
		@TodaysDate DATETIME = GETDATE(),
		@Editor VARCHAR(50) = 'INTERNAL\sccmlabadmin',
		@PropertyName VARCHAR(50) = @strPropertyName,
		@PropertyId INT = NULL;

	DECLARE @DER_Result TABLE 
	(
		[PropertyId] [int]
	)

	BEGIN TRY
		-- Look for the propertyId of the property name.
		SELECT 
			@PropertyId = DER.PropertyId
		FROM 
			dbo.DeviceExtensionRegistration DER
		WHERE
			DER.PropertyName = @PropertyName
		
		BEGIN TRANSACTION;

		IF (@PropertyId IS NULL)
				INSERT INTO DeviceExtensionRegistration 
				(
					PropertyName,
					CreatedBy,
					CreatedDate,
					ModifiedBy,
					ModifiedDate
				)
				OUTPUT inserted.PropertyId into @DER_Result
				values 
				(
					@PropertyName,
					@Editor, 
					@TodaysDate, 
					@Editor, 
					@TodaysDate
				)
		ELSE
			SELECT @PropertyId AS PropertyId;
		
		COMMIT TRANSACTION;
		
		IF (@PropertyId IS NULL)
			SELECT 
				PropertyId 
			FROM @DER_Result;
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