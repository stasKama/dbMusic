CREATE TABLE [dbo].[Music]
(
	[Id] INT NOT NULL IDENTiTY(1,1) PRIMARY KEY,
	[Name] varchar(30) NOT NULL,
	[ArtistId] INT NOT NULL,
	[Length] NUMERIC(5,2) NOT NULL,
	[TrackCount] INT DEFAULT 0,
	[TrackLicenses] INT DEFAULT 0,
	FOREIGN KEY ([ArtistId]) REFERENCES [Artist] ([Id]),
)
