CREATE FUNCTION [dbo].[CountTracksMusic]
(
	@MusicId INT
)
RETURNS INT
AS
BEGIN
	DECLARE @CountTracksMusic INT
	SELECT @CountTracksMusic = COUNT(*) FROM dbo.[Track] WHERE MusicId = @MusicId
	RETURN @CountTracksMusic
END
