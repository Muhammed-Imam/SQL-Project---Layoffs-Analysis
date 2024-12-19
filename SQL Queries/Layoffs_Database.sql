USE [world_layoffs]
GO

/****** Object:  Table [dbo].[layoffs]    Script Date: 12/19/2024 7:19:46 AM ******/

CREATE TABLE [dbo].[layoffs](
	[company] [nvarchar](50) NULL,
	[location] [nvarchar](50) NULL,
	[industry] [nvarchar](50) NULL,
	[total_laid_off] [int] NULL,
	[percentage_laid_off] [float] NULL,
	[date] [date] NULL,
	[stage] [nvarchar](50) NULL,
	[country] [nvarchar](50) NULL,
	[funds_raised_millions] [int] NULL
) ON [PRIMARY]
GO