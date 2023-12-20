CREATE SCHEMA automation
GO

CREATE TABLE automation.CustomProperties
(
	[ID] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[CustomPropertyName] [int] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[IsEnabled] [bit] NOT NULL
 CONSTRAINT [DeviceExtensionData_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO