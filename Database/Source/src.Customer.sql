USE [EnterpriseSales_Source]
GO

/****** Object:  Table [src].[Customer]    Script Date: 31/10/2026 01:42:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [src].[Customer](
	[CustomerID] [varchar](50) NULL,
	[CustomerName] [varchar](50) NULL,
	[Gender] [varchar](50) NULL,
	[Age] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Segment] [varchar](50) NULL,
	[AcquisitionChannel] [varchar](50) NULL,
	[SignupDate] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[Region] [varchar](50) NULL,
	[Email] [varchar](50) NULL,
	[Phone] [varchar](50) NULL,
	[LastActivityDate] [varchar](50) NULL,
	[LastModifiedDate] [datetime2](0) NULL
) ON [PRIMARY]
GO

ALTER TABLE [src].[Customer] ADD  CONSTRAINT [DF_Customer_LastModifiedDate]  DEFAULT (sysdatetime()) FOR [LastModifiedDate]
GO

