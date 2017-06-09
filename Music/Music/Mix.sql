CREATE TABLE [dbo].[Mix]
(
	[Id] INT NOT NULL IDENTiTY(1,1) PRIMARY KEY,
	[Name] VARCHAR(20) NOT NULL,
	[UserId] INT NOT NULL,
	[PrimaryGenre] VARCHAR(40) NULL,
	[SecondaryGenre] VARCHAR(40) NULL,
    FOREIGN KEY ([UserId]) REFERENCES [User] ([Id])
)

GO

CREATE TRIGGER [dbo].[Trigger_Get_Count_New_Mix]
    ON [dbo].[Mix]
    AFTER INSERT
    AS
    BEGIN
        SET NoCount ON
		DECLARE @UserId INT
		
		DECLARE mixCursor CURSOR LOCAL STATIC FOR
			SELECT inserted.UserId FROM inserted

		OPEN mixCursor
		FETCH FIRST FROM mixCursor INTO @UserId
		WHILE @@FETCH_STATUS = 0
		BEGIN
			UPDATE dbo.[User] SET CountCreateMix = CountCreateMix + 1 WHERE Id = @UserId
			FETCH NEXT FROM mixCursor INTO @UserId
		END
		CLOSE mixCursor
		DEALLOCATE mixCursor
    END

GO