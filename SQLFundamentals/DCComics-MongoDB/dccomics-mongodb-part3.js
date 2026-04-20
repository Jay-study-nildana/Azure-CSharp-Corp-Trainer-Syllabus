// Continuation: MongoDB DCComicsDB Full Recreation (Part 3)
// This script continues from dccomics-mongodb-part2.js

// 9. Insert additional comic book entries for Oliver Queen (Green Arrow)
const greenArrowId = db.superheroes.findOne({ name: "Oliver Queen" })._id;
const villainIds = db.villains.find().toArray().map(v => v._id);

db.comics.insertMany([
  { title: "Green Arrow", issueNumber: 1, releaseDate: ISODate("1983-11-01"), superhero: greenArrowId, villain: villainIds[1] },
  { title: "Green Arrow", issueNumber: 2, releaseDate: ISODate("1983-12-01"), superhero: greenArrowId, villain: villainIds[3] },
  { title: "Green Arrow", issueNumber: 3, releaseDate: ISODate("1984-01-01"), superhero: greenArrowId, villain: villainIds[6] },
  { title: "Green Arrow", issueNumber: 4, releaseDate: ISODate("1984-02-01"), superhero: greenArrowId, villain: villainIds[0] },
  { title: "Green Arrow", issueNumber: 5, releaseDate: ISODate("1984-03-01"), superhero: greenArrowId, villain: villainIds[5] },
  { title: "Green Arrow", issueNumber: 6, releaseDate: ISODate("1984-04-01"), superhero: greenArrowId, villain: villainIds[8] },
  { title: "Green Arrow", issueNumber: 7, releaseDate: ISODate("1984-05-01"), superhero: greenArrowId, villain: villainIds[7] },
  { title: "Green Arrow", issueNumber: 8, releaseDate: ISODate("1984-06-01"), superhero: greenArrowId, villain: villainIds[4] },
  { title: "Green Arrow", issueNumber: 9, releaseDate: ISODate("1984-07-01"), superhero: greenArrowId, villain: villainIds[9] },
  { title: "Green Arrow", issueNumber: 10, releaseDate: ISODate("1984-08-01"), superhero: greenArrowId, villain: villainIds[2] }
]);

// 10. Insert comic book entries for Zatanna Zatara
const zatannaId = db.superheroes.findOne({ name: "Zatanna Zatara" })._id;
db.comics.insertMany([
  { title: "Zatanna", issueNumber: 1, releaseDate: ISODate("1964-11-01"), superhero: zatannaId, villain: villainIds[1] },
  { title: "Zatanna", issueNumber: 2, releaseDate: ISODate("1965-01-01"), superhero: zatannaId, villain: villainIds[3] },
  { title: "Zatanna", issueNumber: 3, releaseDate: ISODate("1965-03-01"), superhero: zatannaId, villain: villainIds[8] },
  { title: "Zatanna", issueNumber: 4, releaseDate: ISODate("1965-05-01"), superhero: zatannaId, villain: villainIds[9] }
]);

// 11. Insert comic book entries for Billy Batson (Shazam)
const shazamId = db.superheroes.findOne({ name: "Billy Batson" })._id;
db.comics.insertMany([
  { title: "Shazam!", issueNumber: 1, releaseDate: ISODate("1940-02-01"), superhero: shazamId, villain: villainIds[0] },
  { title: "Shazam!", issueNumber: 2, releaseDate: ISODate("1940-04-01"), superhero: shazamId, villain: villainIds[1] },
  { title: "Shazam!", issueNumber: 3, releaseDate: ISODate("1940-06-01"), superhero: shazamId, villain: villainIds[2] },
  { title: "Shazam!", issueNumber: 4, releaseDate: ISODate("1940-08-01"), superhero: shazamId, villain: villainIds[3] },
  { title: "Shazam!", issueNumber: 5, releaseDate: ISODate("1940-10-01"), superhero: shazamId, villain: villainIds[4] },
  { title: "Shazam!", issueNumber: 6, releaseDate: ISODate("1940-12-01"), superhero: shazamId, villain: villainIds[5] },
  { title: "Shazam!", issueNumber: 7, releaseDate: ISODate("1941-02-01"), superhero: shazamId, villain: villainIds[6] },
  { title: "Shazam!", issueNumber: 8, releaseDate: ISODate("1941-04-01"), superhero: shazamId, villain: villainIds[7] },
  { title: "Shazam!", issueNumber: 9, releaseDate: ISODate("1941-06-01"), superhero: shazamId, villain: villainIds[8] },
  { title: "Shazam!", issueNumber: 10, releaseDate: ISODate("1941-08-01"), superhero: shazamId, villain: villainIds[9] }
]);

// Continue with Constantine, John Stewart, Martian Manhunter, Black Canary, etc. as in the SQL file.
