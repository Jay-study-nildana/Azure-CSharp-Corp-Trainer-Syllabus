// Continuation: MongoDB DCComicsDB Full Recreation (Part 4)
// This script continues from dccomics-mongodb-part3.js

// 12. Insert comic book entries for John Constantine
const constantineId = db.superheroes.findOne({ name: "John Constantine" })._id;
const villainIds = db.villains.find().toArray().map(v => v._id);
db.comics.insertMany([
  { title: "Hellblazer", issueNumber: 1, releaseDate: ISODate("1985-06-01"), superhero: constantineId, villain: villainIds[0] },
  { title: "Hellblazer", issueNumber: 2, releaseDate: ISODate("1985-07-01"), superhero: constantineId, villain: villainIds[1] },
  { title: "Hellblazer", issueNumber: 3, releaseDate: ISODate("1985-08-01"), superhero: constantineId, villain: villainIds[2] },
  { title: "Hellblazer", issueNumber: 4, releaseDate: ISODate("1985-09-01"), superhero: constantineId, villain: villainIds[3] },
  { title: "Hellblazer", issueNumber: 5, releaseDate: ISODate("1985-10-01"), superhero: constantineId, villain: villainIds[4] }
]);

// 13. Insert comic book entries for John Stewart
const johnStewartId = db.superheroes.findOne({ name: "John Stewart" })._id;
db.comics.insertMany([
  { title: "Green Lantern Corps", issueNumber: 1, releaseDate: ISODate("1971-12-01"), superhero: johnStewartId, villain: villainIds[6] },
  { title: "Green Lantern Corps", issueNumber: 2, releaseDate: ISODate("1972-01-01"), superhero: johnStewartId, villain: villainIds[5] },
  { title: "Green Lantern Corps", issueNumber: 3, releaseDate: ISODate("1972-02-01"), superhero: johnStewartId, villain: villainIds[7] },
  { title: "Green Lantern Corps", issueNumber: 4, releaseDate: ISODate("1972-03-01"), superhero: johnStewartId, villain: villainIds[8] },
  { title: "Green Lantern Corps", issueNumber: 5, releaseDate: ISODate("1972-04-01"), superhero: johnStewartId, villain: villainIds[9] },
  { title: "Green Lantern Corps", issueNumber: 6, releaseDate: ISODate("1972-05-01"), superhero: johnStewartId, villain: villainIds[0] }
]);

// 14. Insert comic book entries for J'onn J'onzz (Martian Manhunter)
const martianManhunterId = db.superheroes.findOne({ name: "Jonn Jonzz" })._id;
db.comics.insertMany([
  { title: "Martian Manhunter", issueNumber: 1, releaseDate: ISODate("1955-11-01"), superhero: martianManhunterId, villain: villainIds[1] },
  { title: "Martian Manhunter", issueNumber: 2, releaseDate: ISODate("1955-12-01"), superhero: martianManhunterId, villain: villainIds[3] },
  { title: "Martian Manhunter", issueNumber: 3, releaseDate: ISODate("1956-01-01"), superhero: martianManhunterId, villain: villainIds[7] },
  { title: "Martian Manhunter", issueNumber: 4, releaseDate: ISODate("1956-02-01"), superhero: martianManhunterId, villain: villainIds[9] }
]);

// 15. Insert comic book entries for Dinah Lance (Black Canary)
const blackCanaryId = db.superheroes.findOne({ name: "Dinah Lance" })._id;
db.comics.insertMany([
  { title: "Black Canary", issueNumber: 1, releaseDate: ISODate("1947-08-01"), superhero: blackCanaryId, villain: villainIds[0] },
  { title: "Black Canary", issueNumber: 2, releaseDate: ISODate("1947-09-01"), superhero: blackCanaryId, villain: villainIds[2] },
  { title: "Black Canary", issueNumber: 3, releaseDate: ISODate("1947-10-01"), superhero: blackCanaryId, villain: villainIds[6] }
]);
