// PRACTICO 9 - Validación:
use('mflix');

// Ejercicio 1:
// Especificar en la colección users las siguientes reglas de validación: 
// El campo name (requerido) debe ser un string con un máximo de 30 caracteres, 
// email (requerido) debe ser un string que matchee con la expresión regular: "^(.*)@(.*)\\.(.{2,4})$",
// password (requerido) debe ser un string con al menos 50 caracteres.
db.runCommand({
    collMod: 'users',
    validator: {$jsonSchema: {
        bsonType: 'object',
        required: ['name', 'email', 'password'],
        properties: {
            name: {
                bsonType: 'string',
                maxLength: 30,
                description: 'full name of the users and is required'
            },
            email: {
                bsonType: 'string',
                pattern: '^(.*)@(.*)\\.(.{2,4})$',
                description: 'email of the users and is required'
            },
            password: {
                bsonType: 'string',
                minLength: 50,
                description: 'email password of the users and is required'

            }
        }
    }},
    validationLevel: "moderate",
    validationAction: "error"
});

// Ejercicio 2:
// Obtener metadata de la colección users que garantice que las reglas de validación fueron correctamente aplicadas.
db.getCollectionInfos({name: 'users'});

// Ejercicio 3:
// Especificar en la colección theaters las siguientes reglas de validación: 
// El campo theaterId (requerido) debe ser un int y location (requerido) debe ser un object con:
// un campo address (requerido) que sea un object con campos street1, city, state y zipcode todos de tipo string y requeridos
// un campo geo (no requerido) que sea un object con un campo type, con valores posibles “Point” o null y coordinates que debe ser una lista de 2 doubles


