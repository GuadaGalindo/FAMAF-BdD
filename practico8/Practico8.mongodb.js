// PRACTICO 8:

// Ejercicio 1:
// Cantidad de cines (theaters) por estado.
use('mflix')
db.getCollection('theaters').aggregate([
    {
        $group: {
          '_id': '$location.address.state',
          'theaterPerStatecount': {$sum: 1}
        }
    }
]);

// Ejercicio 2:
// Cantidad de estados con al menos dos cines (theaters) registrados.
use('mflix')
db.getCollection('theaters').aggregate([
    {
        $group: {
          '_id': '$location.address.state',       //Agrupo los cines por estado
          'theaterPerStatecount': {$sum: 1}       //Sumo cada uno de los elementos de los grupos
        }
    },
    {
        $match: {
          'theaterPerStatecount': {$gte: 2}       //Filtro las cosas que sume a las que sean gte:2
        }
    },
    {
        $count: 'statesWithAtLeastTwoTheaters'    //Cuento lo que filtre
    }
]);

// Ejercicio 3:
// Cantidad de películas dirigidas por "Louis Lumière". 
// Sin pipeline de agregación:
use('mflix')
db.getCollection('movies').find(
    {
        'directors': {$elemMatch: {$eq: 'Louis Lumière'}}
    }
).count()

// Con pipeline de agregación:
db.getCollection('movies').aggregate([
    {
        $match: {
            'directors': {$elemMatch: {$eq: 'Louis Lumière'}}
        }
    },
    {
        $count: 'moviesDirectedByLouisLumiere'
    }
]);

// Ejercicio 4:
// Cantidad de películas estrenadas en los años 50 (desde 1950 hasta 1959).
// Sin pipeline de agregación:
use('mflix')
db.getCollection('movies').find(
    {
        'year': {$gte: 1950, $lte: 1959},
    }
).count();

// Con pipeline de agregación:
db.getCollection('movies').aggregate([
    {
        $match: {
            'year': {$gte: 1950, $lte: 1959},
        }
    },
    {
        $count: 'moviesIn50s'
    }
]);

// Ejercicio 5:
// Listar los 10 géneros con mayor cantidad de películas 
// (tener en cuenta que las películas pueden tener más de un género). 
// Devolver el género y la cantidad de películas. Hint: unwind puede ser de utilidad.
use('mflix')
db.getCollection('movies').aggregate([
    {
        $unwind: '$genres'
    },
    {
        $group: {
          '_id': '$genres',
          'moviesPerGenres': {$sum: 1}
        }
    },
    {
        $sort: {'moviesPerGenres': -1}
    },
    {
        $limit: 10
    }
])

// Ejercicio 6:
// Top 10 de usuarios con mayor cantidad de comentarios, 
// mostrando Nombre, Email y Cantidad de Comentarios.
use('mflix')
db.getCollection('comments').aggregate([
    {
        $group: {
          '_id': {'email': '$email', 'name': '$name'},
          'commentsPerUsers': {$sum: 1}
        }
    },
    {
        $project: {
          'name': 1,
          'commentsPerUsers': 1,
          'email': 1
        }
    },
    {
        $sort: {'commentsPerUsers': -1}
    },
    {
        $limit: 10
    }
]);

// Ejercicio 7:
// Ratings de IMDB promedio, mínimo y máximo por año 
// de las películas estrenadas en los años 80 (desde 1980 hasta 1989), 
// ordenados de mayor a menor por promedio del año.
use('mflix')
db.getCollection('movies').aggregate([
    {
        $match: {
            'year': {$gte: 1980, $lte: 1989},
        }
    },
    {
        $group: {
          '_id': '$year',
          'avg_rating': {$avg: '$imdb.rating'},
          'max_rating': {$max: '$imdb.rating'},
          'min_rating': {$min: '$imdb.rating'}
        }
    },
    {
        $sort: {'avg_rating': -1}
    }
]);

// Ejercicio 8:
// Título, año y cantidad de comentarios de las 10 películas con más comentarios.
use('mflix')
db.getCollection('comments').aggregate([
    {
        $group: {
          '_id': '$movie_id',
          'commentsPerMovies': {$sum: 1}
          }
    },
    {
        $lookup: {
          from: 'movies',
          localField: '_id',        //'_id' = 'movie_id' por el group anterior
          foreignField: '_id',
          as: 'movieInfo'
        }
    },          
    {
        $project: {
          'title': '$movieInfo.title',
          'name': '$movieInfo.year',
          'commentsPerMovies': 1
        }
    },
    {
        $sort: {'commentsPerMovies': -1}
    },
    {
        $limit: 10
    }
]);

// Ejercicio 9:
// Crear una vista con los 5 géneros con mayor cantidad de comentarios, 
// junto con la cantidad de comentarios.
use('mflix')
db.top5GenresByComments.drop();
db.createView(
    'top5GenresByComments',
    'comments',
    [
        {
            $lookup: {
                from: 'movies',
                localField: 'movie_id',
                foreignField: '_id',
                as: 'movieInfo'
            }
        },
        {
            $unwind: '$movieInfo'
        },
        {
            $unwind: '$movieInfo.genres'
        },
        {
            $group: {
            '_id': '$movieInfo.genres',
            'commentsPerGenres': {$sum: 1}
            }
        },        
        {
            $sort: {'commentsPerGenres': -1}
        },
        {
            $limit: 5
        }
    ]
);
db.top5GenresByComments.find();

// Ejercicio 10:
// Listar los actores (cast) que trabajaron en 2 o más películas dirigidas por "Jules Bass". 
// Devolver el nombre de estos actores junto con la lista de películas (solo título y año). 
db.getCollection('movies').aggregate([
    {
        $match: {
            'directors': {$elemMatch: {$eq: 'Jules Bass'}}
        }
    },
    {
        $unwind: '$cast'
    },
    {
        $group: {
            _id: '$cast',
            movies: {
                $addToSet: {
                    title: '$title',
                    year: '$year'
                }
            }
        }
    },
    {
        $match: {
            'movies.1': {$exists: true}
        }
    },
    {
        $project: {
            actor: '$_id',
            _id: 0,
            movies: 1
        }
    }
]);

// Ejercicio 11:
// Listar los usuarios que realizaron comentarios durante el mismo mes de lanzamiento de la película
// mostrando Nombre, Email, fecha del comentario, título de la película, fecha de lanzamiento.
use('mflix')
db.getCollection('movies').aggregate([
    {
        $lookup: {
            from: 'comments',
            let: {
                movie_title: '$title',
                movie_released: '$released',
            },
            pipeline: [
                {
                    $match: {
                        $expr: {
                            $eq: [
                                {$month: '$date'}, 
                                {$month: '$$movie_released'}
                            ]
                        }
                    }
                },
                {
                    $project: {
                        name: 1,
                        email: 1,
                        date: 1
                    }
                }
            ],
            as: 'comments'
        }
    },
    {
        $unwind: '$comments'
    },
    {
        $project: {
            name: '$comments.name',
            email: '$comments.email',
            comment_date: '$comments.date',
            title: 1,
            released: 1
        }
    }
]);
 
// El $lookup en esta consulta:

// Realiza una unión entre la colección de películas (movies) y la colección de comentarios (comments).
// Filtra los comentarios para que solo se traigan aquellos que fueron hechos en el mismo mes en que la película fue lanzada.
// Agrega los comentarios relacionados en un campo comments en cada documento de película.
// Después de hacer el $lookup, puedes acceder a estos comentarios y extraer la información relevante.

// Ejercicio 12:
// Ejercicio 13: