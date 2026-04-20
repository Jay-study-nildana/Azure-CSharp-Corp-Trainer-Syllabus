// Continuation: MongoDB DCComicsDB Full Recreation (Part 2)
// This script continues from dccomics-mongodb-part1.js

// 4. Insert Teams
const teams = [
  { teamName: "Justice League", baseOfOperations: "Hall of Justice" },
  { teamName: "Teen Titans", baseOfOperations: "Titans Tower" },
  { teamName: "Suicide Squad", baseOfOperations: "Belle Reve Penitentiary" }
];
const teamResult = db.teams.insertMany(teams);

// 5. Insert Villain Teams
const villainTeams = [
  { teamName: "Legion of Doom", baseOfOperations: "Hall of Doom" },
  { teamName: "Injustice League", baseOfOperations: "Secret Base" },
  { teamName: "Suicide Squad", baseOfOperations: "Belle Reve Penitentiary" }
];
const villainTeamResult = db.villainTeams.insertMany(villainTeams);

// 6. Insert Comics (first batch, for main heroes and villains)
const comics = [
  { title: "Action Comics", issueNumber: 1, releaseDate: ISODate("1938-06-01"), superhero: superheroResult.insertedIds[0], villain: villainResult.insertedIds[0] },
  { title: "Detective Comics", issueNumber: 27, releaseDate: ISODate("1939-05-01"), superhero: superheroResult.insertedIds[1], villain: villainResult.insertedIds[1] },
  { title: "Wonder Woman", issueNumber: 1, releaseDate: ISODate("1941-12-01"), superhero: superheroResult.insertedIds[2], villain: villainResult.insertedIds[3] },
  { title: "The Flash", issueNumber: 123, releaseDate: ISODate("1961-09-01"), superhero: superheroResult.insertedIds[3], villain: villainResult.insertedIds[5] },
  { title: "Green Lantern", issueNumber: 1, releaseDate: ISODate("1959-07-01"), superhero: superheroResult.insertedIds[4], villain: villainResult.insertedIds[6] },
  { title: "Aquaman", issueNumber: 35, releaseDate: ISODate("1967-09-01"), superhero: superheroResult.insertedIds[5], villain: villainResult.insertedIds[4] },
  { title: "Teen Titans", issueNumber: 2, releaseDate: ISODate("1980-12-01"), superhero: superheroResult.insertedIds[6], villain: villainResult.insertedIds[7] }
];
const comicResult = db.comics.insertMany(comics);

// 7. SuperheroTeams (many-to-many): Justice League membership
const justiceLeagueId = teamResult.insertedIds[0];
const justiceLeagueMembers = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14]; // All superheroes
justiceLeagueMembers.forEach(idx => {
  db.superheroTeams.insertOne({ superhero: superheroResult.insertedIds[idx], team: justiceLeagueId });
});

// 8. VillainTeamMemberships (many-to-many): Legion of Doom and Injustice League
const legionOfDoomId = villainTeamResult.insertedIds[0];
const injusticeLeagueId = villainTeamResult.insertedIds[1];
// Legion of Doom: villains 0-4
for (let i = 0; i <= 4; i++) {
  db.villainTeamMemberships.insertOne({ villain: villainResult.insertedIds[i], villainTeam: legionOfDoomId });
}
// Injustice League: villains 5-9
for (let i = 5; i <= 9; i++) {
  db.villainTeamMemberships.insertOne({ villain: villainResult.insertedIds[i], villainTeam: injusticeLeagueId });
}

// Continue with additional comics and team memberships as in the SQL file if needed.
