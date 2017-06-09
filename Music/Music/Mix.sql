CREATE TABLE [dbo].[Mix]
(
	[Id] INT NOT NULL IDENTiTY(1,1) PRIMARY KEY,
	[Name] VARCHAR(20) NOT NULL,
	[UserId] INT NOT NULL,
	[PrimaryGenre] VARCHAR(40) NULL,
	[SecondaryGenre] VARCHAR(40) NULL,
    FOREIGN KEY ([UserId]) REFERENCES [User] ([Id])
)
