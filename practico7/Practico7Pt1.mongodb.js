// PRACTICO 7 parte 1:
use("mflix");

// Ejercicio 1:
db.users.deleteMany({
  email: {
    $in: ["guada@mail", "diane@mail", "feli@mail", "jaz@mail", "marti@mail"],
  },
});

db.users.insertMany([
  { email: "guada@mail", name: "guada", password: "guada123" },
  { email: "diane@mail", name: "diane", password: "diane123" },
  { email: "feli@mail", name: "feli", password: "feli123" },
  { email: "jaz@mail", name: "jaz", password: "jaz123" },
  { email: "marti@mail", name: "marti", password: "marti123" },
]);

db.comments.deleteMany({
  email: {
    $in: ["guada@mail", "diane@mail", "feli@mail", "jaz@mail", "marti@mail"],
  },
});

db.comments.insertMany([
  { date: new Date(), email: "guada@mail", name: "guada", text: "buena peli" },
  { date: new Date(), email: "diane@mail", name: "diane", text: "mala peli" },
  { date: new Date(), email: "feli@mail", name: "feli", text: "horrible peli" },
  { date: new Date(), email: "jaz@mail", name: "jaz", text: "genial peli" },
  { date: new Date(), email: "marti@mail", name: "marti", text: "mmm peli" },
]);

// Ejercicio 2:
db.getCollection("movies")
  .find(
    {
      year: { $in: [1990, 1999] },
      "imdb.rating": { $type: "double" },
    },
    { title: 1, year: 1, cast: 1, directors: 1, "imdb.rating": 1 }
  )
  .sort({ "imdb.rating": -1 })
  .limit(10);

//Ejercicio 3:
db.getCollection("comments")
  .find(
    {
      movie_id: { $eq: ObjectId("573a1399f29313caabcee886") },
      date: {
        $gte: new Date("2014-01-01T00:00:00Z"),
        $lte: new Date("2016-12-31T23:59:59Z"),
      },
    },
    { email: 1, text: 1, date: 1 }
  )
  .sort({ date: 1 });

db.getCollection("comments").aggregate([
  {
    $match: {
      movie_id: ObjectId("573a1399f29313caabcee886"),
      date: {
        $gte: new Date("2014-01-01T00:00:00Z"),
        $lte: new Date("2016-12-31T23:59:59Z"),
      },
    },
  },
  {
    $count: "totalComments",
  },
]);

//Ejercicio 4:
db.getCollection("comments")
  .find(
    {
      email: { $eq: "patricia_good@fakegmail.com" },
    },
    { name: 1, movie_id: 1, text: 1, date: 1 }
  )
  .sort({ date: -1 })
  .limit(3);

//Ejercicio 5:
db.getCollection("movies")
  .find(
    {
      genres: { $elemMatch: { $eq: "Drama", $eq: "Action" } },
      languages: { $size: 1 },
      $or: [{ "imdb.rating": { $gt: 9 } }, { runtime: { $gte: 180 } }],
    },
    { title: 1, genres: 1, released: 1, "imdb.votes": 1, languages: 1 }
  ).sort(
    { released: 1, "imdb.votes": 1 }
  );

//Ejercicio 6:
db.getCollection("theaters")
  .find(
    {
      $and: [
        { "location.address.state": { $in: ["CA", "NY", "TX"] } },
        { "location.address.city": /^F/ },
      ],
    },
    {
      theaterId: 1,
      "location.address.state": 1,
      "location.address.city": 1,
      "location.geo.coordinates": 1,
    }
  )
  .sort({ "location.address.state": 1, "location.address.city": 1 });

//Ejercicico 7:
db.getCollection("comments").updateOne(
  {
    _id: ObjectId("5b72236520a3277c015b3b73"),
  },
  {
    $set: { text: "mi mejor comentario", date: new Date() },
    $currentDate: { lastModified: true },
  }
);

//Ejercicico 8:
db.getCollection("users").updateOne(
  {
    email: "joel.macdonel@fakegmail.com",
  },
  {
    $set: { password: "some password" },
  },
  {
    upsert: true,
  }
);

//Ejercicico 9:
db.getCollection("comments").deleteMany({
  email: "victor_patel@fakegmail.com",
  date: {
    $gte: new Date("1980-01-01T00:00:00Z"),
    $lt: new Date("1981-01-01T00:00:00Z"),
  },
});
