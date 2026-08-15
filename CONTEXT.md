# خريطة رحلات بولس الرسول

An Arabic, RTL, single-purpose app about St Paul's epistles, built for إعداد خدام ٢٠٢٦. It holds two
separate experiences over one pixel-art Mapbox basemap: a **Cross Map** for memorising where the
epistles' recipients sit, and the **Post Office Game**, a guided playthrough that delivers the
fourteen letters one at a time.

## Language

### The Cross Map

**Cross Map**:
The reference map: a fixed three-level hierarchy of categories and places, arranged as an equal-armed
cross over the Mediterranean. A memorisation aid, not a route — nothing travels it.
_Avoid_: journey map, hierarchy map

**Cross Arm**:
One of the four directions of the Cross layout (top, bottom, left, right). Each arm holds exactly one
Category.

**Category**:
A root of the Cross: قارات، بلاد، بحار، جزر. The only nodes that occupy an arm.

**Place**:
A node beneath a Category — a continent, country, sea, island, or city. Every Place has a Place Kind.
_Avoid_: location, region

**Place Kind**:
The taxonomy a Place belongs to: continent, country, sea, island, or city. Drives how its marker
looks.

**Node**:
The umbrella for a Category or a Place — anything that sits in the Cross Map's tree and can be
drilled into.

**Breadcrumb**:
The chain of ancestors from a Category down to the Node currently drilled into. Empty means the whole
Cross is showing.

**Non-Geographic Group**:
A thematic grouping of epistle recipients with no place on the map — أشخاص (تيموثاوس، تيطس، فليمون)
and العبرانيين. Shown outside the map entirely.

### The Post Office Game

**Post Office Game**:
The guided playthrough: fourteen Levels, each delivering one Letter, played in the order the Play
Script sets.

**Journey**:
The route the Couriers walk across the map over the course of the game. Reserved for the game — the
Cross Map is not a journey.

**Play Script**:
`المسرحية.docx`, the normative source for every line, verse, and level in the game. Where it stages a
scene rather than speaking in the game's voice, the Level simply carries less — nothing is invented
to fill the gap.
_Avoid_: screenplay, story file

**Script**:
The whole playthrough as data: the guide, the narrator, the letter writer, a prologue, the ordered
Levels, and an epilogue.

**Level (مرحلة)**:
One stage of play — the unit the player advances through, and the canonical unit of the game. Today
every Level delivers exactly one Letter, but a Level is defined by being a stage, not by being an
epistle.
_Avoid_: chapter, stage, mission

**Letter (رسالة)**:
One of Paul's fourteen epistles: the subject matter a Level is built around, and whose Verses that
Level quotes.
_Avoid_: epistle, message, mail

**Road Letters / Prison Letters**:
The two halves the fourteen Letters split into — رسائل الطريق, written while travelling, then رسائل
السجن, written in captivity. The game plays them in that order.

**Stop**:
A place the Journey passes through: where a Letter is delivered and where its Couriers stand while it
is read. Positioned from the Gazetteer.
_Avoid_: waypoint, station, node

**Destination**:
The Stop a given Level is about — where its leading group stands, and what the camera frames.

**Destination Card**:
The artwork panel shown over the map during a Level, carrying the Letter's title, its Verses as they
are revealed, and the Letter Writer's portrait. Named for the Destination, not for a city — several
Destinations are provinces, not cities.
_Avoid_: city card, level card

**Verse (شاهد)**:
A scripture citation the Play Script quotes for a Letter. Revealed one at a time on the Destination
Card, as the reward for understanding the Level rather than as its content.

**Character**:
Anyone who takes part in the game — a Courier, the Guide, the Narrator, or the Letter Writer. The
umbrella term; each role below behaves differently and the umbrella alone is rarely the right word.

**Courier (ساعي البريد)**:
A Character who carries the Letters and moves across the map. The only role with a Token and a Trail.
Couriers travel paired.
_Avoid_: postman, traveller, player character

**Guide (صوت اللعبة)**:
The in-world Character who explains each Level, hands out the next one, and confirms a Clearance.
Speaks from a portrait and a speech panel.

**Narrator (الراوي)**:
The out-of-world voice that frames the Journey between Levels. Shown as a letterboxed band, never as
a figure in the world.

**Letter Writer**:
بولس الرسول — whose words the Verses are. Never on the map; present only as the signature on the
Destination Card.

**Placement**:
Which Characters stand at which Stop during one Level. A Placement covers a *group*, which is what
lets a second pair of Couriers walk their own route through the same Levels.

**Story Beat**:
One line of story shown as an overlay over the map, spoken by either the Guide or the Narrator.
_Avoid_: dialogue line, cue

**Step**:
One position in the playthrough: either a single Story Beat, or a Level's playable map with nothing
in the way. The whole game is a flat list of Steps, which is why forward and backward are always one
move.

**Phase**:
Which part of the playthrough a Step belongs to: prologue, briefing, playing, clearance, or epilogue.

**Briefing**:
The Story Beats played before a Level's map is handed to the player.

**Clearance**:
The Story Beats played once the player has passed a Level. A Level that has been passed is **cleared**,
and its Stop is drawn as such.

**Trail**:
The dashed line marking where a Courier has already been. One per Courier on the move.
_Avoid_: route, path, track

### Shared

**Gazetteer**:
The app's single record of where the real places it names actually are. Both the Cross Map and the
Journey read the places they share off it, so a city cannot sit in two places at once. Holds only real
locations — Mnemonic Placements are deliberately not in it.
_Avoid_: coordinates file, place index

**Mnemonic Placement**:
A position chosen so the Cross reads well on screen, rather than to say where anything really is —
the four arm anchors, and the continents, seas and countries. Never a Gazetteer entry.

### Map Rendering

**Map Surface**:
The map viewport itself, described independently of any provider. What actually draws it (Mapbox on
native, Mapbox GL JS on web) is not part of the term.

**Surface Spec**:
The complete, provider-agnostic description of what a Map Surface should currently show — its
Markers, Trails, Tokens, and Camera Target. Deliberately excludes anything provider-specific, such as
tile URLs or attribution.

**Marker**:
A point drawn on the map for a *place* — a Cross Map Node or a Journey Stop.

**Token**:
A round portrait drawn on the map for a *Character standing somewhere*. Distinct from a Marker: a
Marker is a place, a Token is a person.

**Camera Target**:
Where the Map Surface's camera should be looking, expressed either as a centre with a zoom or as
bounds to fit.

**Pixel Style**:
The pixel-art treatment of the basemap — the palette and sprite recipes that give the whole app its
look.

**Design Spec**:
`docs/design.md`. Normative for coordinates, layout maths, and styling numbers: use the figures it
gives rather than re-deriving them.
