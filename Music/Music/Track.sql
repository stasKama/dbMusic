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
		DECLARE @MusicId INT, @CountMusic INT, @CountLicenses INT
		IF EXISTS (SELECT * FROM inserted)
		BEGIN
			 SELECT @MusicId = inserted.MusicId FROM inserted
			 SELECT @CountMusic = TrackCount, @CountLicenses = TrackLicenses FROM dbo.[Music] WHERE Id = @MusicId
			 IF @CountMusic > @CountLicenses
			 BEGIN
				ROLLBACK TRAN
				RETURN
			 END
		END
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
			 SELECT @MusicId = inserted.MusicId FROM inserted
			 SELECT @CountMusic = TrackCount, @CountLicenses = TrackLicenses FROM dbo.[Music] WHERE Id = @MusicId
			 SELECT @CountMusic
			 IF ((SELECT COUNT(*) FROM inserted WHERE MusicId = @MusicId) + @CountMusic) > @CountLicenses
			 BEGIN
				ROLLBACK TRAN
				RETURN
			 END
		END
		IF EXISTS (SELECT * FROM inserted)
		BEGIN
			SELECT @MusicId = MusicId, @MixId = MixId FROM inserted
			SELECT @PrimaryGenre = PrimaryGenre, @SecondaryGenre = SecondaryGenre FROM [dbo].[GetGenre](@MixId)
		END
		ELSE
		BEGIN
			SELECT @MusicId = MusicId, @MixId = MixId FROM deleted
			SELECT @PrimaryGenre = PrimaryGenre, @SecondaryGenre = SecondaryGenre FROM [dbo].[GetGenre](@MixId)
		END
		UPDATE dbo.[Music] SET dbo.[Music].TrackCount = [dbo].[CountTracksMusic](@MusicId) WHERE Id = @MusicId
		UPDATE dbo.[Mix] SET dbo.[Mix].PrimaryGenre = @PrimaryGenre,  dbo.[Mix].SecondaryGenre = @SecondaryGenre WHERE Id = @MixId
    END
GO