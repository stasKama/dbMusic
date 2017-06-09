CREATE TABLE [dbo].[Track]
(
	[Id] INT NOT NULL IDENTiTY(1,1) PRIMARY KEY,
	[MusicId] INT,
	[MixId] INT NOT NULL,
	UNIQUE([MusicId], [MixId]),
	FOREIGN KEY ([MusicId]) REFERENCES [Music] ([Id]),
	FOREIGN KEY ([MixId]) REFERENCES [Mix] ([Id])
)
