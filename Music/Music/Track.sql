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
		DECLARE @MusicId INT, @CountMusic INT, @CountLicenses INT, @CountInsert INT
		DECLARE trackCursor CURSOR LOCAL STATIC FOR
			SELECT inserted.MusicId FROM inserted

		OPEN trackCursor
		FETCH FIRST FROM trackCursor INTO @MusicId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			SELECT @CountInsert = COUNT(*) FROM inserted WHERE MusicId = @MusicId
			SELECT @CountMusic = TrackCount, @CountLicenses = TrackLicenses FROM dbo.[Music] WHERE Id = @MusicId
			IF @CountMusic + @CountInsert > @CountLicenses
			BEGIN
				ROLLBACK TRAN
				RETURN
			END
			FETCH NEXT FROM trackCursor INTO @MusicId
		END
		CLOSE trackCursor
		DEALLOCATE trackCursor
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
			SELECT inserted.MusicId FROM inserted

			OPEN trackUpdateCursor
			FETCH FIRST FROM trackUpdateCursor INTO @MusicId
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @MusicId = inserted.MusicId FROM inserted
				SELECT @CountMusic = TrackCount, @CountLicenses = TrackLicenses FROM dbo.[Music] WHERE Id = @MusicId
				IF ((SELECT COUNT(*) FROM inserted WHERE MusicId = @MusicId) + @CountMusic) > @CountLicenses
				BEGIN
					ROLLBACK TRAN
					RETURN
				END
				FETCH NEXT FROM trackUpdateCursor INTO @MusicId
			END
			CLOSE trackUpdateCursor
			DEALLOCATE trackUpdateCursor
		END

		IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)
		BEGIN
			DECLARE trackInsertCursor CURSOR LOCAL STATIC FOR
			SELECT inserted.MusicId FROM inserted

			OPEN trackInsertCursor
			FETCH FIRST FROM trackInsertCursor INTO @MusicId
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @MixId = MixId FROM inserted WHERE MusicId = @MusicId
				SELECT @PrimaryGenre = PrimaryGenre, @SecondaryGenre = SecondaryGenre FROM [dbo].[GetGenre](@MixId)
				UPDATE dbo.[Music] SET dbo.[Music].TrackCount = [dbo].[CountTracksMusic](@MusicId) WHERE Id = @MusicId
				UPDATE dbo.[Mix] SET dbo.[Mix].PrimaryGenre = @PrimaryGenre,  dbo.[Mix].SecondaryGenre = @SecondaryGenre WHERE Id = @MixId
				FETCH NEXT FROM trackInsertCursor INTO @MusicId
			END
		CLOSE trackInsertCursor
		DEALLOCATE trackInsertCursor
		END

		IF EXISTS(SELECT * FROM deleted) AND NOT EXISTS(SELECT * FROM inserted)
		BEGIN
			DECLARE trackDeleteCursor CURSOR LOCAL STATIC FOR
			SELECT deleted.MusicId FROM deleted

			OPEN trackDeleteCursor
			FETCH FIRST FROM trackDeleteCursor INTO @MusicId
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @MixId = MixId FROM deleted WHERE MusicId = @MusicId
				SELECT @PrimaryGenre = PrimaryGenre, @SecondaryGenre = SecondaryGenre FROM [dbo].[GetGenre](@MixId)
				UPDATE dbo.[Music] SET dbo.[Music].TrackCount = [dbo].[CountTracksMusic](@MusicId) WHERE Id = @MusicId
				UPDATE dbo.[Mix] SET dbo.[Mix].PrimaryGenre = @PrimaryGenre,  dbo.[Mix].SecondaryGenre = @SecondaryGenre WHERE Id = @MixId
				FETCH NEXT FROM trackDeleteCursor INTO @MusicId
			END
		CLOSE trackDeleteCursor
		DEALLOCATE trackDeleteCursor
		END
	END
GO