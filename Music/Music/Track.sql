CREATE TABLE [dbo].[Track]
(
	[Id] INT NOT NULL IDENTiTY(1,1) PRIMARY KEY,
	[SongId] INT,
	[MixId] INT NOT NULL,
	UNIQUE([SongId], [MixId]),
	FOREIGN KEY ([SongId]) REFERENCES [Song] ([Id]) ON DELETE CASCADE,
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
		SELECT s.[Id], i.CountTracks + s.[TrackCount], s.[TrackLicenses] FROM dbo.[Song] s 
			INNER JOIN 
			(SELECT COUNT([SongId]) AS CountTracks, [SongId] FROM inserted GROUP BY [SongId]) i 
			ON  s.[Id] = i.[SongId]
			WHERE s.[Id] IN (SELECT [SongId] FROM inserted GROUP BY [SongId]) 

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
			INNER JOIN dbo.[Song] s ON t.[SongId] = s.[Id]
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
		DECLARE @TableMixId Table (
			MixId INT
		)
		DECLARE @TableMusicId Table (
			MusicId INT
		)
		DECLARE @Id INT, @CountMusic INT, @CountLicenses INT, @PrimaryGenre VARCHAR(40), @SecondaryGenre VARCHAR(40)
		IF UPDATE([SongId]) 
		BEGIN
			DECLARE trackUpdateCursor CURSOR LOCAL STATIC FOR
			SELECT t.[CountMusic], s.[TrackLicenses] FROM dbo.[Song] s 
				INNER JOIN (SELECT [SongId], COUNT([SongId]) AS CountMusic FROM dbo.[Track] GROUP BY [SongId]) t 
				ON s.[Id] = t.[SongId]
				WHERE s.[Id] IN (SELECT [SongId] FROM inserted GROUP BY [SongId])

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

		IF EXISTS(SELECT * FROM deleted)
		BEGIN
			INSERT INTO @TableMixId SELECT [MixId] FROM deleted GROUP BY [MixId]
			INSERT INTO @TableMusicId SELECT [SongId] FROM deleted GROUP BY [SongId]
		END
		IF EXISTS(SELECT * FROM inserted)
		BEGIN
			INSERT INTO @TableMixId SELECT [MixId] FROM inserted GROUP BY [MixId]
			INSERT INTO @TableMusicId SELECT [SongId] FROM inserted GROUP BY [SongId]
		END

		DECLARE trackCursor CURSOR LOCAL STATIC FOR
		SELECT MixId FROM @TableMixId

		OPEN trackMixCursor
		FETCH FIRST FROM trackMixCursor INTO @Id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @PrimaryGenre = PrimaryGenre, @SecondaryGenre = SecondaryGenre FROM [dbo].[GetGenre](@Id)
			UPDATE dbo.[Mix] SET dbo.[Mix].[PrimaryGenre] = @PrimaryGenre,  dbo.[Mix].[SecondaryGenre] = @SecondaryGenre WHERE Id = @Id
			FETCH NEXT FROM trackMixCursor INTO @Id
		END
		CLOSE trackMixCursor
		DEALLOCATE trackMixCursor

		DECLARE trackMusicCursor CURSOR LOCAL STATIC FOR
		SELECT MusicId FROM @TableMusicId

		OPEN trackMusicCursor
		FETCH FIRST FROM trackMusicCursor INTO @Id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE dbo.[Song] SET dbo.[Song].[TrackCount] = [dbo].[CountTracksMusic](@Id) WHERE Id = @Id
			FETCH NEXT FROM trackMusicCursor INTO @Id
		END
		CLOSE trackMusicCursor
		DEALLOCATE trackMusicCursor
	END
GO