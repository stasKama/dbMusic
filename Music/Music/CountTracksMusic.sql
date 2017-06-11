CREATE FUNCTION [dbo].[CountTracksMusic]
(
	@MusicId INT
)
RETURNS INT
AS
BEGIN
	DECLARE @CountTracksMusic INT
	SELECT @CountTracksMusic = COUNT(*) FROM dbo.[Track] WHERE [SongId] = @MusicId
	RETURN @CountTracksMusic
END
