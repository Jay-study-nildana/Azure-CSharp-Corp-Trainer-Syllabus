// MongoDB DCComicsDB Full Recreation
// This script recreates the SQL DCComicsDB in MongoDB, line by line.
// Run in the MongoDB shell or as a .js script.

// 1. Drop existing collections if they exist

db.superheroes.drop();
db.villains.drop();
db.teams.drop();
db.villainTeams.drop();
db.comics.drop();

db.superheroTeams.drop(); // For many-to-many

db.villainTeamMemberships.drop(); // For many-to-many

// 2. Insert Superheroes
const superheroes = [
  { name: "Clark Kent", alias: "Superman", firstAppearance: ISODate("1938-06-01"), publisher: "DC Comics" },
  { name: "Bruce Wayne", alias: "Batman", firstAppearance: ISODate("1939-05-01"), publisher: "DC Comics" },
  { name: "Diana Prince", alias: "Wonder Woman", firstAppearance: ISODate("1941-12-01"), publisher: "DC Comics" },
  { name: "Barry Allen", alias: "The Flash", firstAppearance: ISODate("1956-10-01"), publisher: "DC Comics" },
  { name: "Hal Jordan", alias: "Green Lantern", firstAppearance: ISODate("1959-07-01"), publisher: "DC Comics" },
  { name: "Arthur Curry", alias: "Aquaman", firstAppearance: ISODate("1941-11-01"), publisher: "DC Comics" },
  { name: "Victor Stone", alias: "Cyborg", firstAppearance: ISODate("1980-10-01"), publisher: "DC Comics" },
  { name: "John Constantine", alias: "Constantine", firstAppearance: ISODate("1985-06-01"), publisher: "DC Comics" },
  { name: "Billy Batson", alias: "Shazam", firstAppearance: ISODate("1940-02-01"), publisher: "DC Comics" },
  { name: "Oliver Queen", alias: "Green Arrow", firstAppearance: ISODate("1941-11-01"), publisher: "DC Comics" },
  { name: "Kara Zor-El", alias: "Supergirl", firstAppearance: ISODate("1959-05-01"), publisher: "DC Comics" },
  { name: "Jonn Jonzz", alias: "Martian Manhunter", firstAppearance: ISODate("1955-11-01"), publisher: "DC Comics" },
  { name: "John Stewart", alias: "Green Lantern", firstAppearance: ISODate("1971-12-01"), publisher: "DC Comics" },
  { name: "Zatanna Zatara", alias: "Zatanna", firstAppearance: ISODate("1964-11-01"), publisher: "DC Comics" },
  { name: "Dinah Lance", alias: "Black Canary", firstAppearance: ISODate("1947-08-01"), publisher: "DC Comics" }
];
const superheroResult = db.superheroes.insertMany(superheroes);

// 3. Insert Villains
const villains = [
  { name: "Lex Luthor", alias: "Lex Luthor", firstAppearance: ISODate("1940-04-01"), publisher: "DC Comics" },
  { name: "Joker", alias: "Joker", firstAppearance: ISODate("1940-04-25"), publisher: "DC Comics" },
  { name: "Harley Quinn", alias: "Harley Quinn", firstAppearance: ISODate("1992-09-11"), publisher: "DC Comics" },
  { name: "Cheetah", alias: "Cheetah", firstAppearance: ISODate("1943-10-01"), publisher: "DC Comics" },
  { name: "Black Manta", alias: "Black Manta", firstAppearance: ISODate("1967-09-01"), publisher: "DC Comics" },
  { name: "Reverse-Flash", alias: "Reverse-Flash", firstAppearance: ISODate("1963-09-01"), publisher: "DC Comics" },
  { name: "Sinestro", alias: "Sinestro", firstAppearance: ISODate("1961-08-01"), publisher: "DC Comics" },
  { name: "Deathstroke", alias: "Deathstroke", firstAppearance: ISODate("1980-12-01"), publisher: "DC Comics" },
  { name: "Darkseid", alias: "Darkseid", firstAppearance: ISODate("1970-11-01"), publisher: "DC Comics" },
  { name: "Brainiac", alias: "Brainiac", firstAppearance: ISODate("1958-07-01"), publisher: "DC Comics" }
];
const villainResult = db.villains.insertMany(villains);

// Next steps: Insert teams, villainTeams, comics, and many-to-many memberships using the inserted ObjectIds.
// (File size limit reached, continue in next file if needed)
