// BASE DE DATOS: PARCIAL 2
use('university')

// Ejercicio 1:
db.getCollection('grades').find(
    {
        $and: [
            {
                $or: [
                    {'scores': {$elemMatch: {'type': 'exam', 'score': {$gte: 80}}}},
                    {'scores': {$elemMatch: {'type': 'quiz', 'score': {$gte: 90}}}}
                ]
            },
            {
                'scores': {$not: {$elemMatch: {'type': 'homework', 'score': {$lt: 60}}}}
            }
        ]
    },
    {
        '_id': 0
    }
).sort(
    {'class_id': -1, 'student_id': 1}
);

// Ejercicio 2:
db.getCollection('grades').aggregate([
    {
        $match: {
            'class_id': {$in: [20, 220, 420]}
        }
    },
    {
        $unwind: '$scores'
    },
    {
        $group: {
            '_id': {'student_id': '$student_id', 'class_id': '$class_id'},
            'avg_score': {$avg: '$scores.score'},
            'min_score': {$min: '$scores.score'},
            'max_score': {$max: '$scores.score'}
        }
    },
    {
        $sort: {'_id.student_id': 1, '_id.class_id': 1} 
    }
]);

// Ejercicio 3:
db.grades.aggregate([
    {
        $project: {
            class_id: 1,
            exam_scores: {
                $filter: {
                    input: '$scores',
                    as: 'score',
                    cond: {$eq: ['$$score.type', 'exam']}
                }
            },
            quiz_scores: {
                $filter: {
                    input: '$scores',
                    as: 'score',
                    cond: {$eq: ['$$score.type', 'quiz']}
                }
            }
        }
    },
    {
        $project: {
            class_id: 1,
            max_exam_score: {$max: '$exam_scores.score'},
            max_quiz_score: {$max: '$quiz_scores.score'}
        }
    },
    {
        $sort: {class_id: 1}
    }
]);

// Ejercicio 4:
db.top10students.drop();
db.createView(
    'top10students',
    'grades',
    [
        {
            $unwind: '$scores'
        },
        {
            $group: {
                '_id': '$student_id',
                'avg_score': {$avg: '$scores.score'},
            }
        },
        {
            $sort: {'avg_score': -1,}
        },
        {
            $limit: 10
        }
    ]
);
db.top10students.find();

// Ejercicio 5:
db.getCollection('grades').aggregate([
    {
        $match: {
            'class_id': {$eq: 339}
        }
    },
    {
        $unwind: '$scores'
    },
    {
        $group: {
            '_id': {'class_id': '$class_id', 'student_id': '$student_id'},
            'avg_score': {$avg: '$scores.score'},
        }
    },
    {
        $addFields: {
            'letter': {
                $switch: {
                    branches: [
                        {
                            case: {$and: [ 
                                {$gte: ['$avg_score', 0]}, 
                                {$lt: ['$avg_score', 60]}]},
                            then: 'NA'
                        },
                        {
                            case: {$and: [ 
                                {$gte: ['$avg_score', 60]}, 
                                {$lt: ['$avg_score', 80]}]},
                            then: 'A'
                        },
                        {
                            case: {$and: [ 
                                {$gte: ['$avg_score', 80]}, 
                                {$lte: ['$avg_score', 100]}]},
                            then: 'p'
                        }
                    ],
                }
            }
        }
    }
]);

// Ejercicio 6:
db.runCommand({
    collMod: 'grades',
    validator: {$jsonSchema: {
        bsonType: 'object',
        required: ['class_id', 'student_id', 'scores'],
        properties: {
            class_id: {
                bsonType: 'int',
                description: 'id of the class, must be an int and is required'
                },
            student_id: {
                bsonType: 'int',
                description: 'id of the student, must be an int and is required'
            },
            scores: {
                bsonType: 'array',
                items: {
                    bsonType: 'object',
                    required: ['type', 'score'],
                    properties: {
                        type: {
                            enum:['exam', 'quiz', 'homework'],
                            description: 'must be a enum values and is required'
                        },
                        score: {
                            bsonType: 'double',
                            description: 'must be a double and is required'
                        }
                    }
                },
                description: 'must be an array of type and score, and is required'
            }
        }
    }},
    validationLevel: 'strict',
    validationAction: 'error'
});

db.grades.aggregate([
    {
        $project: {
            class_id: 1,
            exam_scores: {
                $filter: {
                    input: '$scores',
                    as: 'score',
                    cond: {$eq: ['$$score.type', 'exam']}
                }
            },
            quiz_scores: {
                $filter: {
                    input: '$scores',
                    as: 'score',
                    cond: {$eq: ['$$score.type', 'quiz']}
                }
            }
        }
    },
    {
        $project: {
            class_id: 1,
            max_exam_score: {$max: '$exam_scores.score'},
            max_quiz_score: {$max: '$quiz_scores.score'}
        }
    },
    {
        $sort: {class_id: 1}
    }
]);