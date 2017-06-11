CREATE FUNCTION [dbo].[GetGenre]
(
	@MixId INT
)
RETURNS @GenreMusic TABLE (PrimaryGenre VARCHAR(40), SecondaryGenre VARCHAR(40))
AS
BEGIN
    DECLARE @PrimaryGenre VARCHAR(40), @SecondaryGenre VARCHAR(40)
	
	DECLARE @TopGenre TABLE (
		Id INT IDENTITY(1,1),
		Genre VARCHAR(40)
	)

	INSERT @TopGenre SELECT TOP 2 [Song].Genre FROM dbo.[Track] 
		INNER JOIN dbo.[Song] ON [Track].[SongId] = [Song].[Id]
		WHERE MixId = @MixId 
		GROUP BY [Song].[Genre]
		ORDER BY COUNT([Song].[Genre]) DESC

	SELECT @PrimaryGenre = Genre FROM @TopGenre WHERE Id = 1;
	SELECT @SecondaryGenre = Genre FROM @TopGenre WHERE Id = 2;

    INSERT INTO @GenreMusic VALUES (@PrimaryGenre, @SecondaryGenre)

    RETURN 
END