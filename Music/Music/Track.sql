CREATE TABLE [dbo].[Track]
(
	[Id] INT NOT NULL IDENTiTY(1,1) PRIMARY KEY,
	[MusicId] INT,
	[MixId] INT NOT NULL,
	UNIQUE([MusicId], [MixId]),
	FOREIGN KEY ([MusicId]) REFERENCES [Music] ([Id]) ON DELETE CASCADE,
	FOREIGN KEY ([MixId]) REFERENCES [Mix] ([Id]) ON DELETE CASCADE
)

GO

CREATE TRIGGER [dbo].[Trigger_Mix_For]
    ON [dbo].[Track]
    FOR INSERT
    AS
    BEGIN
        SET NoCount ON

		DECLARE @Id INT, @CountMusic INT, @CountLicenses INT, @TimeMix NUMERIC(5, 2)

		DECLARE trackMusicCursor CURSOR LOCAL STATIC FOR
		SELECT m.[Id], i.CountTracks + m.[TrackCount], m.[TrackLicenses] FROM dbo.[Music] m 
			INNER JOIN 
			(SELECT COUNT([MusicId]) AS CountTracks,[MusicId] FROM inserted GROUP BY [MusicId]) i 
			ON  m.[Id] = i.[MusicId]
			WHERE m.[Id] IN (SELECT [MusicId] FROM inserted GROUP BY [MusicId]) 

		OPEN trackMusicCursor

		FETCH FIRST FROM trackMusicCursor INTO @Id, @CountMusic, @CountLicenses
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CountMusic > @CountLicenses
			BEGIN
				ROLLBACK TRAN
				RETURN
			END
			FETCH NEXT FROM trackMusicCursor INTO @Id, @CountMusic, @CountLicenses
		END
		CLOSE trackMusicCursor
		DEALLOCATE trackMusicCursor
		
		DECLARE trackMixCursor CURSOR LOCAL STATIC FOR
		SELECT m.[Id], COUNT(m.[Id]), SUM(s.[Length]) FROM dbo.[Mix] m 
			INNER JOIN dbo.[Track] t ON m.[Id] = t.[MixId]
			INNER JOIN dbo.[Music] s ON t.[MusicId] = s.[Id]
			WHERE m.[Id] IN (SELECT [MixId] FROM inserted GROUP BY [MixId]) 
			GROUP BY m.[Id]

		OPEN trackMixCursor

		FETCH FIRST FROM trackMixCursor INTO @Id, @CountMusic, @TimeMix
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @CountMusic > 20 OR @TimeMix > 90.0
			BEGIN
				ROLLBACK TRAN
				RETURN
			END
			FETCH NEXT FROM trackMixCursor INTO @Id, @CountMusic, @TimeMix
		END
		CLOSE trackMixCursor
		DEALLOCATE trackMixCursor
    END
GO

CREATE TRIGGER [dbo].[Trigger_Mix_After]
   ON [dbo].[Track]
    AFTER DELETE, INSERT, UPDATE
    AS
    BEGIN
        SET NoCount ON
		DECLARE @MusicId INT, @MixId INT, @CountMusic INT, @CountLicenses INT, @PrimaryGenre VARCHAR(40), @SecondaryGenre VARCHAR(40)
		IF UPDATE(MusicId) 
		BEGIN
			DECLARE trackUpdateCursor CURSOR LOCAL STATIC FOR
			SELECT t.[CountMusic], m.[TrackLicenses] FROM dbo.[Music] m 
				INNER JOIN (SELECT [MusicId], COUNT([MusicId]) AS CountMusic FROM dbo.[Track] GROUP BY [MusicId]) t 
				ON m.[Id] = t.[MusicId]
				WHERE m.[Id] IN (SELECT [MusicId] FROM inserted GROUP BY [MusicId])

			OPEN trackUpdateCursor
			FETCH FIRST FROM trackUpdateCursor INTO @CountMusic, @CountLicenses
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF @CountMusic > @CountLicenses
				BEGIN
					ROLLBACK TRAN
					RETURN
				END
				FETCH NEXT FROM trackUpdateCursor INTO @CountMusic, @CountLicenses
			END
			CLOSE trackUpdateCursor
			DEALLOCATE trackUpdateCursor
		END

		IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
		BEGIN
			DECLARE trackInsertCursor CURSOR LOCAL STATIC FOR
			SELECT inserted.MusicId, inserted.MixId FROM inserted

			OPEN trackInsertCursor
			FETCH FIRST FROM trackInsertCursor INTO @MusicId, @MixId
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @PrimaryGenre = PrimaryGenre, @SecondaryGenre = SecondaryGenre FROM [dbo].[GetGenre](@MixId)
				UPDATE dbo.[Music] SET dbo.[Music].TrackCount = [dbo].[CountTracksMusic](@MusicId) WHERE Id = @MusicId
				UPDATE dbo.[Mix] SET dbo.[Mix].PrimaryGenre = @PrimaryGenre,  dbo.[Mix].SecondaryGenre = @SecondaryGenre WHERE Id = @MixId
				FETCH NEXT FROM trackInsertCursor INTO @MusicId, @MixId
			END
		CLOSE trackInsertCursor
		DEALLOCATE trackInsertCursor
		END

		IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
		BEGIN
			DECLARE trackDeleteCursor CURSOR LOCAL STATIC FOR
			SELECT deleted.MusicId, deleted.MixId FROM deleted

			OPEN trackDeleteCursor
			FETCH FIRST FROM trackDeleteCursor INTO @MusicId, @MixId
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @PrimaryGenre = PrimaryGenre, @SecondaryGenre = SecondaryGenre FROM [dbo].[GetGenre](@MixId)
				UPDATE dbo.[Music] SET dbo.[Music].TrackCount = [dbo].[CountTracksMusic](@MusicId) WHERE Id = @MusicId
				UPDATE dbo.[Mix] SET dbo.[Mix].PrimaryGenre = @PrimaryGenre,  dbo.[Mix].SecondaryGenre = @SecondaryGenre WHERE Id = @MixId
				FETCH NEXT FROM trackDeleteCursor INTO @MusicId, @MixId
			END
		CLOSE trackDeleteCursor
		DEALLOCATE trackDeleteCursor
		END
	END
GO