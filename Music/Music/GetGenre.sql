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

	INSERT @TopGenre SELECT TOP 2 [Music].Genre FROM dbo.[Track] 
		INNER JOIN dbo.[Music] ON [Track].MusicId = [Music].Id
		WHERE MixId = @MixId 
		GROUP BY [Music].Genre 
		ORDER BY COUNT([Music].Genre) DESC

	SELECT @PrimaryGenre = Genre FROM @TopGenre WHERE Id = 1;
	SELECT @SecondaryGenre = Genre FROM @TopGenre WHERE Id = 2;

    INSERT INTO @GenreMusic VALUES (@PrimaryGenre, @SecondaryGenre)

    RETURN 
END