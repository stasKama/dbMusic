<h1>Music</h1>

<p>This project contains five script files tables and two script files with functions.</p>
<p>Mix - list OF songs of different Artist and various genre.</p>
<p>Mix has primary and secondary genre.</p>
<p>User participatES in creating mix.</p>
<p>Mix has limitation, if the song doesn't have enough licenses or tracks in the mix are more than 20 or the total time of mix is more than 90 minutes.</p>
<p>Song can be used in mix, if it has licenses, and THE quantity of using the song must n't exceed the quantity of licenses.</p>
<p>In one mix, the song can not be repeated twice.</p>

<h3>Table User</h3>

<p>Table contains fields: Id, name and the number of mixes created by this user.</p>
<p>Field "The number of mixes created by this user" is increases automatically when creating new mix BY THE USER, the logic of this procedure will be described in trigger of table Mix.</p>

<h3>Table Artist</h3>

<p>Table contains fields: Id, name, country and artist’s label.</p>

<h3>Table Mix</h3>

<p>Table contains fields: Id, name, id the user’s, who created the mix, primary and secondary genre.</p>
<p>Field "Id the user’s, who created the mix" is selected from of list existing users.</p>
<p>The fields "Primary genre" and "Secondary genre" are determined automatically when adding song, the logic of this procedure is described in trigger of table Track.</p>
<p>Table Mix has trigger.</p>
<p>This trigger works after adding new Mix in DB.</p>

<h3>Table Song</h3>

<p>Table contains fields: Id, name, artist’S id, length, genre, number of uses and number of songs’ licenses.</p>
<p>Field "Artist’s Id" is selected from the list of existing artists.</p>
<p>Field "Genre" is selected from the list of possible genres.</p>
<p>Field "The number of using" is updated automatically when adding the song in mix, the logic of this procedure is described in trigger of table Track.</p>

<h3>Table Track</h3>

<p>Table contains fields: Id, id of song and of mix.</p>
<p>The meaning for the  fields "id of song" and "id of mix"  are selected from the list of ids of existing songs and mixes.</p>
<p>Table Mix has two triggers.</p>
<p>1) "Before trigger" is performed before writing data to a DB.</p>
<p>Trigger checks availability of the song’s licenses and the limit of the number of songs in the mix(20 songs) and the duration of the songs in the mix (90 minutes).</p>
<p>2) "After trigger" is performed before writing data to a DB.</p>
<p>Trigger changes the meading of the field "The number of usig the song" table Song, through the function "CountTracksMusic" and fields Primary and secondary genres of mix table Mix, through the function "GetGenre"</p>
