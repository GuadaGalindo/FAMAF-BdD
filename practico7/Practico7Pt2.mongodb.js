// PRACTICO 7 parte 2:
use("restaurantdb");

// Ejercicio 10:
db.getCollection('restaurants').find(
  {
    'grades': {
      $elemMatch: {
        'date':{
          $gte: new Date("2014-01-01T00:00:00Z"),
          $lte: new Date("2015-12-31T23:59:59Z")
        },
        'score': {$gt: 70, $lte: 90},
      },
    },
  },
  { 'restaurant_id': 1, 'grades.$': 1 }
);

// Ejercicio 11:
db.getCollection('restaurants').updateOne(
  { 
    'restaurant_id': "50018608" 
  },
  {
    $push: {
      'grades': {
        $each: [{
          'date': ISODate("2019-10-10T00:00:00Z"),
          'grade': "A",
          'score': 18
        },
        {
          'date': ISODate("2020-02-25T00:00:00Z"),
          'grade': "A",
          'score': 21
        }]
      }
    }
  }
)