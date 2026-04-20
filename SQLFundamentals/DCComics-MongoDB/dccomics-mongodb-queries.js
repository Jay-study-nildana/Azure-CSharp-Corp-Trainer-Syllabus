// MongoDB DCComicsDB Query Collection
// 1000+ lines of queries for superheroes, villains, teams, comics, and relationships
// Run in the MongoDB shell or as a .js script

// 1. Basic Queries
// Find all superheroes
print('All Superheroes:');
db.superheroes.find().forEach(printjson);

// Find all villains
print('All Villains:');
db.villains.find().forEach(printjson);

// Find all teams
print('All Teams:');
db.teams.find().forEach(printjson);

// Find all comics
print('All Comics:');
db.comics.find().forEach(printjson);

// 2. Projections
// Find superhero names only
print('Superhero Names:');
db.superheroes.find({}, { name: 1, _id: 0 }).forEach(printjson);

// Find villain aliases only
print('Villain Aliases:');
db.villains.find({}, { alias: 1, _id: 0 }).forEach(printjson);

// 3. Sorting
// Find all comics sorted by release date
print('Comics by Release Date:');
db.comics.find().sort({ releaseDate: 1 }).forEach(printjson);

// 4. Filtering
// Find superheroes who first appeared before 1950
print('Superheroes before 1950:');
db.superheroes.find({ firstAppearance: { $lt: ISODate('1950-01-01') } }).forEach(printjson);

// Find villains with alias 'Joker'
print('Villains with alias Joker:');
db.villains.find({ alias: 'Joker' }).forEach(printjson);

// 5. Aggregation: Count comics per superhero
print('Comics per Superhero:');
db.comics.aggregate([
  { $group: { _id: "$superhero", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]).forEach(printjson);

// 6. Aggregation: List all comics for a given villain
const jokerId = db.villains.findOne({ alias: 'Joker' })._id;
print('Comics with Joker:');
db.comics.find({ villain: jokerId }).forEach(printjson);

// 7. $lookup: Join comics with superhero names
print('Comics with Superhero Names:');
db.comics.aggregate([
  { $lookup: {
      from: 'superheroes',
      localField: 'superhero',
      foreignField: '_id',
      as: 'heroInfo'
    }
  },
  { $unwind: "$heroInfo" },
  { $project: { title: 1, issueNumber: 1, 'heroInfo.name': 1 } }
]).forEach(printjson);

// 8. $lookup: Join comics with villain names
print('Comics with Villain Names:');
db.comics.aggregate([
  { $lookup: {
      from: 'villains',
      localField: 'villain',
      foreignField: '_id',
      as: 'villainInfo'
    }
  },
  { $unwind: "$villainInfo" },
  { $project: { title: 1, issueNumber: 1, 'villainInfo.name': 1 } }
]).forEach(printjson);

// 9. Find all members of the Justice League
const justiceLeagueId = db.teams.findOne({ teamName: 'Justice League' })._id;
print('Justice League Members:');
db.superheroTeams.find({ team: justiceLeagueId }).forEach(function(m) {
  printjson(db.superheroes.findOne({ _id: m.superhero }));
});

// 10. Find all villains in Legion of Doom
const legionOfDoomId = db.villainTeams.findOne({ teamName: 'Legion of Doom' })._id;
print('Legion of Doom Members:');
db.villainTeamMemberships.find({ villainTeam: legionOfDoomId }).forEach(function(m) {
  printjson(db.villains.findOne({ _id: m.villain }));
});

// 24. Find all comics where the superhero is a Green Lantern
const greenLanternIds = db.superheroes.find({ alias: /Green Lantern/ }).toArray().map(h => h._id);
print('Comics with any Green Lantern:');
db.comics.find({ superhero: { $in: greenLanternIds } }).forEach(printjson);

// 25. Find all comics where the villain is Sinestro
const sinestroId = db.villains.findOne({ alias: 'Sinestro' })._id;
print('Comics with Sinestro:');
db.comics.find({ villain: sinestroId }).forEach(printjson);

// 26. Find all comics where the superhero and villain are both in the Justice League and Legion of Doom, respectively
const legionOfDoomVillainIds = db.villainTeamMemberships.find({ villainTeam: legionOfDoomId }).toArray().map(m => m.villain);
print('Comics: Justice League vs Legion of Doom:');
db.superheroTeams.find({ team: justiceLeagueId }).forEach(function(m) {
  db.comics.find({ superhero: m.superhero, villain: { $in: legionOfDoomVillainIds } }).forEach(printjson);
});

// 27. Find the top 5 most frequent superhero-villain matchups
print('Top 5 Superhero-Villain Matchups:');
db.comics.aggregate([
  { $group: { _id: { hero: "$superhero", villain: "$villain" }, count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 5 },
  { $lookup: { from: 'superheroes', localField: '_id.hero', foreignField: '_id', as: 'hero' } },
  { $lookup: { from: 'villains', localField: '_id.villain', foreignField: '_id', as: 'villain' } },
  { $unwind: '$hero' },
  { $unwind: '$villain' },
  { $project: { 'hero.name': 1, 'villain.name': 1, count: 1 } }
]).forEach(printjson);

// 28. Find all comics where the issue number is a multiple of 100
print('Comics with issue number multiple of 100:');
db.comics.find({ issueNumber: { $mod: [100, 0] } }).forEach(printjson);

// 29. Find all superheroes who have fought more than 3 different villains
print('Superheroes who fought >3 villains:');
db.comics.aggregate([
  { $group: { _id: "$superhero", villains: { $addToSet: "$villain" } } },
  { $project: { count: { $size: "$villains" } } },
  { $match: { count: { $gt: 3 } } },
  { $lookup: { from: 'superheroes', localField: '_id', foreignField: '_id', as: 'hero' } },
  { $unwind: '$hero' },
  { $project: { 'hero.name': 1, count: 1 } }
]).forEach(printjson);

// 30. Find all villains who have fought more than 3 different superheroes
print('Villains who fought >3 superheroes:');
db.comics.aggregate([
  { $group: { _id: "$villain", heroes: { $addToSet: "$superhero" } } },
  { $project: { count: { $size: "$heroes" } } },
  { $match: { count: { $gt: 3 } } },
  { $lookup: { from: 'villains', localField: '_id', foreignField: '_id', as: 'villain' } },
  { $unwind: '$villain' },
  { $project: { 'villain.name': 1, count: 1 } }
]).forEach(printjson);

// 31. Find all comics where the superhero and villain are the same person (should be empty)
print('Comics where hero and villain are the same:');
db.comics.find({ $expr: { $eq: ["$superhero", "$villain"] } }).forEach(printjson);

// 32. Find the earliest comic for each superhero
print('Earliest comic per superhero:');
db.comics.aggregate([
  { $sort: { superhero: 1, releaseDate: 1 } },
  { $group: { _id: "$superhero", firstComic: { $first: "$$ROOT" } } },
  { $lookup: { from: 'superheroes', localField: '_id', foreignField: '_id', as: 'hero' } },
  { $unwind: '$hero' },
  { $project: { 'hero.name': 1, 'firstComic.title': 1, 'firstComic.releaseDate': 1 } }
]).forEach(printjson);

// 33. Find the latest comic for each villain
print('Latest comic per villain:');
db.comics.aggregate([
  { $sort: { villain: 1, releaseDate: -1 } },
  { $group: { _id: "$villain", lastComic: { $first: "$$ROOT" } } },
  { $lookup: { from: 'villains', localField: '_id', foreignField: '_id', as: 'villain' } },
  { $unwind: '$villain' },
  { $project: { 'villain.name': 1, 'lastComic.title': 1, 'lastComic.releaseDate': 1 } }
]).forEach(printjson);

// 34. Find all comics where the title contains 'Flash'
print('Comics with "Flash" in title:');
db.comics.find({ title: /Flash/ }).forEach(printjson);

// 35. Find all comics where the superhero is female (assuming names)
const femaleHeroes = ["Diana Prince", "Kara Zor-El", "Zatanna Zatara", "Dinah Lance"];
print('Comics with female superheroes:');
db.comics.find({ superhero: { $in: db.superheroes.find({ name: { $in: femaleHeroes } }).toArray().map(h => h._id) } }).forEach(printjson);

// 36. Find all comics where the villain is female (assuming names)
const femaleVillains = ["Harley Quinn", "Cheetah"];
print('Comics with female villains:');
db.comics.find({ villain: { $in: db.villains.find({ name: { $in: femaleVillains } }).toArray().map(v => v._id) } }).forEach(printjson);

// 37. Find all comics where the superhero is in more than one team
print('Superheroes in multiple teams:');
db.superheroTeams.aggregate([
  { $group: { _id: "$superhero", teams: { $addToSet: "$team" }, count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } },
  { $lookup: { from: 'superheroes', localField: '_id', foreignField: '_id', as: 'hero' } },
  { $unwind: '$hero' },
  { $project: { 'hero.name': 1, count: 1 } }
]).forEach(printjson);

// 38. Find all teams with more than 5 members
print('Teams with more than 5 members:');
db.superheroTeams.aggregate([
  { $group: { _id: "$team", members: { $addToSet: "$superhero" }, count: { $sum: 1 } } },
  { $match: { count: { $gt: 5 } } },
  { $lookup: { from: 'teams', localField: '_id', foreignField: '_id', as: 'team' } },
  { $unwind: '$team' },
  { $project: { 'team.teamName': 1, count: 1 } }
]).forEach(printjson);

// 39. Find all comics where the superhero is not in the Justice League
print('Comics with non-Justice League superheroes:');
db.comics.find({ superhero: { $nin: db.superheroTeams.find({ team: justiceLeagueId }).toArray().map(m => m.superhero) } }).forEach(printjson);

// 40. Find all comics where the villain is not in the Legion of Doom
print('Comics with non-Legion of Doom villains:');
db.comics.find({ villain: { $nin: legionOfDoomVillainIds } }).forEach(printjson);

// 41. Find the number of comics per year
print('Number of comics per year:');
db.comics.aggregate([
  { $group: { _id: { $year: "$releaseDate" }, count: { $sum: 1 } } },
  { $sort: { _id: 1 } }
]).forEach(printjson);

// 42. Find the average issue number per superhero
print('Average issue number per superhero:');
db.comics.aggregate([
  { $group: { _id: "$superhero", avgIssue: { $avg: "$issueNumber" } } },
  { $lookup: { from: 'superheroes', localField: '_id', foreignField: '_id', as: 'hero' } },
  { $unwind: '$hero' },
  { $project: { 'hero.name': 1, avgIssue: 1 } }
]).forEach(printjson);

// 43. Find the superhero with the most comic appearances
print('Superhero with most comic appearances:');
db.comics.aggregate([
  { $group: { _id: "$superhero", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 1 },
  { $lookup: { from: 'superheroes', localField: '_id', foreignField: '_id', as: 'hero' } },
  { $unwind: '$hero' },
  { $project: { 'hero.name': 1, count: 1 } }
]).forEach(printjson);

// 44. Find the villain with the most comic appearances
print('Villain with most comic appearances:');
db.comics.aggregate([
  { $group: { _id: "$villain", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 1 },
  { $lookup: { from: 'villains', localField: '_id', foreignField: '_id', as: 'villain' } },
  { $unwind: '$villain' },
  { $project: { 'villain.name': 1, count: 1 } }
]).forEach(printjson);

// 45. Find all comics where the superhero and villain first appeared in the same decade
print('Comics where hero and villain first appeared same decade:');
db.comics.aggregate([
  { $lookup: { from: 'superheroes', localField: 'superhero', foreignField: '_id', as: 'hero' } },
  { $unwind: '$hero' },
  { $lookup: { from: 'villains', localField: 'villain', foreignField: '_id', as: 'villain' } },
  { $unwind: '$villain' },
  { $project: { title: 1, issueNumber: 1, hero: 1, villain: 1, sameDecade: { $eq: [ { $subtract: [ { $year: '$hero.firstAppearance' }, { $mod: [ { $year: '$hero.firstAppearance' }, 10 ] } ] }, { $subtract: [ { $year: '$villain.firstAppearance' }, { $mod: [ { $year: '$villain.firstAppearance' }, 10 ] } ] } ] } } },
  { $match: { sameDecade: true } }
]).forEach(printjson);

// 46. Find all comics where the superhero and villain have never fought before (unique matchups)
print('Comics with unique hero-villain matchups:');
db.comics.aggregate([
  { $group: { _id: { hero: "$superhero", villain: "$villain" }, count: { $sum: 1 }, comic: { $first: "$$ROOT" } } },
  { $match: { count: 1 } },
  { $replaceRoot: { newRoot: "$comic" } }
]).forEach(printjson);

// 47. Find all superheroes who have never fought Joker
print('Superheroes who never fought Joker:');
db.superheroes.find({ _id: { $nin: db.comics.find({ villain: jokerId }).toArray().map(c => c.superhero) } }).forEach(printjson);

// 48. Find all villains who have never fought Batman
const batmanId = db.superheroes.findOne({ alias: 'Batman' })._id;
print('Villains who never fought Batman:');
db.villains.find({ _id: { $nin: db.comics.find({ superhero: batmanId }).toArray().map(c => c.villain) } }).forEach(printjson);

// 49. Find the average number of comics per team
print('Average comics per team:');
db.superheroTeams.aggregate([
  { $lookup: { from: 'comics', localField: 'superhero', foreignField: 'superhero', as: 'comics' } },
  { $group: { _id: "$team", totalComics: { $sum: { $size: "$comics" } }, memberCount: { $sum: 1 } } },
  { $project: { avgComics: { $divide: ["$totalComics", "$memberCount"] } } },
  { $lookup: { from: 'teams', localField: '_id', foreignField: '_id', as: 'team' } },
  { $unwind: '$team' },
  { $project: { 'team.teamName': 1, avgComics: 1 } }
]).forEach(printjson);

// 50. Find all comics where the superhero is in the Teen Titans
const teenTitansId = db.teams.findOne({ teamName: 'Teen Titans' })._id;
const teenTitanHeroIds = db.superheroTeams.find({ team: teenTitansId }).toArray().map(m => m.superhero);
print('Comics with Teen Titans members:');
db.comics.find({ superhero: { $in: teenTitanHeroIds } }).forEach(printjson);

// 51. Find all comics where the villain is in the Injustice League
const injusticeLeagueId = db.villainTeams.findOne({ teamName: 'Injustice League' })._id;
const injusticeLeagueVillainIds = db.villainTeamMemberships.find({ villainTeam: injusticeLeagueId }).toArray().map(m => m.villain);
print('Comics with Injustice League villains:');
db.comics.find({ villain: { $in: injusticeLeagueVillainIds } }).forEach(printjson);

// 52. Find all comics where the superhero is not in any team
print('Comics with superheroes not in any team:');
db.comics.find({ superhero: { $nin: db.superheroTeams.distinct('superhero') } }).forEach(printjson);

// 53. Find all comics where the villain is not in any villain team
print('Comics with villains not in any villain team:');
db.comics.find({ villain: { $nin: db.villainTeamMemberships.distinct('villain') } }).forEach(printjson);

// 54. Find the most common team for each superhero
print('Most common team per superhero:');
db.superheroTeams.aggregate([
  { $group: { _id: { superhero: "$superhero", team: "$team" }, count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $group: { _id: "$_id.superhero", mostCommon: { $first: "$_id.team" }, count: { $first: "$count" } } },
  { $lookup: { from: 'superheroes', localField: '_id', foreignField: '_id', as: 'hero' } },
  { $unwind: '$hero' },
  { $lookup: { from: 'teams', localField: 'mostCommon', foreignField: '_id', as: 'team' } },
  { $unwind: '$team' },
  { $project: { 'hero.name': 1, 'team.teamName': 1, count: 1 } }
]).forEach(printjson);

// 55. Find the most common villain team for each villain
print('Most common villain team per villain:');
db.villainTeamMemberships.aggregate([
  { $group: { _id: { villain: "$villain", villainTeam: "$villainTeam" }, count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $group: { _id: "$_id.villain", mostCommon: { $first: "$_id.villainTeam" }, count: { $first: "$count" } } },
  { $lookup: { from: 'villains', localField: '_id', foreignField: '_id', as: 'villain' } },
  { $unwind: '$villain' },
  { $lookup: { from: 'villainTeams', localField: 'mostCommon', foreignField: '_id', as: 'villainTeam' } },
  { $unwind: '$villainTeam' },
  { $project: { 'villain.name': 1, 'villainTeam.teamName': 1, count: 1 } }
]).forEach(printjson);

// 56. Find all comics where the superhero and villain are both in the same team (should be rare)
print('Comics where hero and villain are in the same team:');
db.comics.aggregate([
  { $lookup: { from: 'superheroTeams', localField: 'superhero', foreignField: 'superhero', as: 'heroTeams' } },
  { $unwind: '$heroTeams' },
  { $lookup: { from: 'villainTeamMemberships', localField: 'villain', foreignField: 'villain', as: 'villainTeams' } },
  { $unwind: '$villainTeams' },
  { $match: { $expr: { $eq: [ '$heroTeams.team', '$villainTeams.villainTeam' ] } } },
  { $project: { title: 1, issueNumber: 1 } }
]).forEach(printjson);

// 57. Find all comics where the superhero is Superman or Batman and the villain is Joker or Lex Luthor
print('Comics: Superman/Batman vs Joker/Lex Luthor:');
db.comics.find({ superhero: { $in: [supermanId, batmanId] }, villain: { $in: [jokerId, lexLuthorId] } }).forEach(printjson);

// 58. Find all comics where the superhero is not Superman, Batman, or Wonder Woman
const excludedHeroIds = [supermanId, batmanId, wonderWomanId];
print('Comics with other superheroes:');
db.comics.find({ superhero: { $nin: excludedHeroIds } }).forEach(printjson);

// 59. Find all comics where the villain is not Joker, Lex Luthor, or Sinestro
const excludedVillainIds = [jokerId, lexLuthorId, sinestroId];
print('Comics with other villains:');
db.comics.find({ villain: { $nin: excludedVillainIds } }).forEach(printjson);

// 60. Find the number of comics per team, sorted descending
print('Number of comics per team:');
db.superheroTeams.aggregate([
  { $lookup: { from: 'comics', localField: 'superhero', foreignField: 'superhero', as: 'comics' } },
  { $group: { _id: "$team", totalComics: { $sum: { $size: "$comics" } } } },
  { $sort: { totalComics: -1 } },
  { $lookup: { from: 'teams', localField: '_id', foreignField: '_id', as: 'team' } },
  { $unwind: '$team' },
  { $project: { 'team.teamName': 1, totalComics: 1 } }
]).forEach(printjson);

// 61. Find all comics where the superhero is a member of both Justice League and Teen Titans
const teenTitansMembers = db.superheroTeams.find({ team: teenTitansId }).toArray().map(m => m.superhero);
const justiceLeagueMembers = db.superheroTeams.find({ team: justiceLeagueId }).toArray().map(m => m.superhero);
const bothTeams = justiceLeagueMembers.filter(id => teenTitansMembers.includes(id));
print('Comics with heroes in both Justice League and Teen Titans:');
db.comics.find({ superhero: { $in: bothTeams } }).forEach(printjson);

// 62. Find all comics where the villain is a member of both Legion of Doom and Injustice League
const injusticeLeagueMembers = db.villainTeamMemberships.find({ villainTeam: injusticeLeagueId }).toArray().map(m => m.villain);
const bothVillainTeams = legionOfDoomVillainIds.filter(id => injusticeLeagueMembers.includes(id));
print('Comics with villains in both Legion of Doom and Injustice League:');
db.comics.find({ villain: { $in: bothVillainTeams } }).forEach(printjson);

// 63. Find all comics where the superhero is not in any team and the villain is not in any villain team
print('Comics with solo heroes and villains:');
db.comics.find({ superhero: { $nin: db.superheroTeams.distinct('superhero') }, villain: { $nin: db.villainTeamMemberships.distinct('villain') } }).forEach(printjson);

// 64. Find all comics where the superhero and villain are both in at least two teams
print('Comics with multi-team heroes and villains:');
db.comics.aggregate([
  { $lookup: { from: 'superheroTeams', localField: 'superhero', foreignField: 'superhero', as: 'heroTeams' } },
  { $lookup: { from: 'villainTeamMemberships', localField: 'villain', foreignField: 'villain', as: 'villainTeams' } },
  { $project: { title: 1, issueNumber: 1, heroTeamCount: { $size: '$heroTeams' }, villainTeamCount: { $size: '$villainTeams' } } },
  { $match: { heroTeamCount: { $gte: 2 }, villainTeamCount: { $gte: 2 } } }
]).forEach(printjson);


