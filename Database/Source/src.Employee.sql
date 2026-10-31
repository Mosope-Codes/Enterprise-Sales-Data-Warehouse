USE [EnterpriseSales_Source]
GO

/****** Object:  Table [src].[Employee]    Script Date: 31/10/2026 01:43:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [src].[Employee](
	[EmployeeID] [varchar](50) NULL,
	[EmployeeName] [varchar](50) NULL,
	[Role] [varchar](50) NULL,
	[Department] [varchar](50) NULL,
	[StoreID] [varchar](50) NULL,
	[HireDate] [varchar](50) NULL,
	[Status] [varchar](50) NULL,
	[LastModifiedDate] [datetime2](0) NULL
) ON [PRIMARY]
GO

ALTER TABLE [src].[Employee] ADD  CONSTRAINT [DF_Employee_LastModifiedDate]  DEFAULT (sysdatetime()) FOR [LastModifiedDate]
GO

