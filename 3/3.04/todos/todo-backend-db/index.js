// $ npm install --save sequelize

// $ npm install --save sequelize-cli

// $ npm install --save pg

// $ npm install --save dotenv

// $ npm install --save curl

const express = require('express')

const app = express()

const cors = require('cors')

const fs = require('fs')

const path = require('path')

app.use(express.static('build'))

app.use(cors())

app.use(express.json())

const requestLogger = (request, response, next) => {

  console.log('Method:', request.method)

  console.log('Path:  ', request.path)

  console.log('Body:  ', request.body)

  console.log('*********************')

  next()
}

app.use(requestLogger)

require('dotenv').config()

var todo_id = 0

var todos = []

const { Sequelize, Model, DataTypes } = require('sequelize');

console.log('process.env.DB_HOST', process.env.DB_HOST)

const sequelize = new Sequelize(process.env.DB_SCHEMA || 'postgres',
                                process.env.DB_USER || 'postgres',
                                //process.env.DB_PASSWORD || 'postgres',
                                process.env.POSTGRES_PASSWORD || 'postgres',
                                {
                                    host: process.env.DB_HOST || 'localhost',
                                    port: process.env.DB_PORT || 5432,
                                    dialect: 'postgres',
                                    dialectOptions: {
                                        ssl: process.env.DB_SSL == "true"
                                }
})

// DATABASE_URL=postgres://username@localhost:5432/database_name

const Todos = sequelize.define('todos', {
    ID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    TODO: {
        type: DataTypes.STRING(140),
        allowNull: false,
        validate: {
            len: {
                args: [1,140],
                msg: "Error String length exceeded 140 characters"
           }
       }
    }
})

var TODO_URL = ""

const directory = path.join('/', 'etc', '/', 'data')

console.log(directory)

const filePath = path.join(directory, '/', 'url.txt')

console.log(filePath)

const getUrl = async () => new Promise(response => {

  console.log('getUrl')

  try {

    fs.readFile(filePath, 'utf8' , (error, data) => {

      if (error) {

        console.error(error)

      }

      console.log(data)

      TODO_URL = data

      console.log('TODO_URL', TODO_URL)

      return true

    })

  } catch (error) {
    console.log(error)
    return false
  }
});

const initialize = (async () => {

  await sequelize.authenticate().then(() => {

    sequelize.sync({ force: true }).then(() => {
        console.log("Drop and Sync DB.");
    })
  })
  
  try {

    await sequelize.sync().then(() => {
        console.log("Sync DB.");
    })

    const result = await Todos.create({
      TODO: ""
    })

    console.log(result.toJSON())

    const result_json = result.toJSON()

    todo_id = result_json.ID

    console.log('ID:', todo_id)

  } catch (error) {
    console.log(error)
    }
})

app.get('/', (request, response) => {

  console.log('GET /')

  response.send('<h1>TODO</h1>')
})

app.get('/todos', async function(request, response) {

  console.log('GET /todos')

  todos = []

  //const success = await getUrl()

  //console.log('success', success)

  try {

        await sequelize.sync().then(() => {
            console.log("Sync DB.");
        })
        
        const results = await Todos.findAll()

        console.log(results.every(result => result.TODO))

        const records = results.map(function(result) {

            return result.dataValues
        })

        console.log(records)

        if (records && records.length > 0) {

          records.forEach(record => {

            const todo = {
              id: record.ID,
              content: record.TODO,
              date: record.createdAt
            }

            todos.push(todo)

            console.log(todo)

          })

        }

      } catch (error) {

        console.log(error)
    }

  response.json(todos)

})

const generateId = () => {

  const maxId = todos.length > 0 ? Math.max(...todos.map(n => n.id)) : 0

  return maxId + 1
}

app.post('/todos', async function(request, response) {

  console.log('POST /todos', request.body)

  const body = request.body

  if (!body.content) {

    return response.status(400).json({
      error: 'Content Unknown'
    })
  }

  console.log('body.content.length', body.content.length)

  if (body.content.length > 140) {

    return response.status(400).json({
      error: 'Content Length Max Length'
    })
  }

  const todo = {
    id: generateId(),
    content: body.content,
    date: body.date
  }

  todos = todos.concat(todo)

  const record = { ID: todo.id, TODO: todo.content}

  console.log("TODO:", record.ID, record.TODO)

  try {

    await Todos.create(record).then(function (todo) {
      if (todo) {
        console.log(todo)
      } else {
        console.log('Error sequelize')
      }
    })

  } catch (error) {

    console.log(error)
  }

  response.json(todo)
})

app.get('/todos/:id', (request, response) => {

  console.log('GET', request.params.id)

  const id = Number(request.params.id)

  const todo = todos.find(todo => todo.id === id)

  if (todo) {
    response.json(todo)
  } else {
    response.status(404).end()
  }
})

//TODO: update
/*try {

    var selector = { 
      where: { ID: todo.id }
    }

    await sequelize.sync().then(() => {
      console.log("Sync DB.");
    })

    const result = await Todos.update(record,selector)

    console.log(result)

  } catch (error) {
    console.log(error)
  }
*/

app.delete('/todos/:id', (request, response) => {

  console.log('DELETE')

  const id = Number(request.params.id)

  todos = todos.filter(todo => todo.id !== id)

  response.status(204).end()
})

const unknownUrl = (request, response) => {

  response.status(404).send({ error: 'Unknown Url' })
}

app.use(unknownUrl)

const PORT = process.env.PORT || 3002

initialize()

app.listen(PORT, () => {

  console.log(`PORT: ${PORT}`)
})