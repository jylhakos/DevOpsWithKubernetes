// $ npm install --save sequelize

// $ npm install --save sequelize-cli

// $ npm install --save pg

// $ npm install --save dotenv

// $ npm install --save curl

// $ npm install --save nats@latest

const express = require('express')

const app = express()

const cors = require('cors')

const fs = require('fs')

const path = require('path')

app.use(express.static('build'))

app.use(cors())

app.use(express.json())

const NATS = require('nats')

const { connect, StringCodec } = require("nats")

const sc = StringCodec()

const NATS_URL = 'nats://todos-nats:4222'

//url: process.env.NATS_URL || 'nats://todos-nats:4222'

console.log("NATS", NATS_URL)

var nc = null

const requestLogger = (request, response, next) => {

  console.log('Method:', request.method)

  console.log('Path:  ', request.path)

  console.log('Body:  ', request.body)

  console.log('-----------------------')

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
        //validate: {
        //    len: {
        //        args: [1,140],
        //        msg: "Error String length exceeded 140 characters"
        //   }
       //}
    },
    CHECKED: {
        type: DataTypes.BOOLEAN(),
        allowNull: true
    }
})

const directory = path.join('/', 'etc', '/', 'data')

console.log(directory)

const filePath = path.join(directory, '/', 'url.txt')

console.log(filePath)

const setup_nats = async () => {

  console.log('NATS connect', NATS_URL)

  nc = await NATS.connect({servers: NATS_URL})  

  //const nc = await connect({servers: 'todos-nats:4222'})

  nc.publish("todos", sc.encode("NATS connected"))

  console.log('NATS connected')
}

const initialize = (async () => {

  try {

    await sequelize.authenticate().then(() => {

          sequelize.sync({ force: true }).then(() => {

          console.log("Drop and Sync DB.")

          }).catch(error => {

            console.log('Error: ', error)

          return 'Error'

          })

      }).catch(error => {

          console.log('Error: ', error)

          return 'Error'
      })

    const result = await Todos.create({TODO: ""})

    console.log(result.toJSON())

    const result_json = result.toJSON()

    todo_id = result_json.ID

    console.log('ID:', todo_id)

  } catch (error) {

    console.log(error)

  }

  try {

    console.log('await setup_nats')

    await setup_nats()

    console.log('waited setup_nats')

  } catch (error) {

    console.log('NATS', error)

  }

})

app.get('/', (request, response) => {

  console.log('GET /')

  response.send('<p>200</p>')
})

app.get('/todos', async function(request, response) {

  console.log('GET /todos')

  todos = []

  try {

        await sequelize.sync().then(() => {

            console.log("Sync DB.")

        }).catch(error => {

          console.log('Error: ', error)

          return response.status(500).json({
            error: 'Database'
          })
        })
        
        const results = await Todos.findAll()

        console.log(results.every(result => result.TODO))

        const records = results.map(function(result) {

            return result.dataValues

        })

        console.log('records', records)

        if (records && records.length > 0) {

          records.forEach(record => {

            const todo = {
              id: record.ID,
              content: record.TODO,
              checked: record.CHECKED,
              date: record.createdAt
            }

            todos.push(todo)

            console.log('TODO', todo)

          })

        }

      } catch (error) {

        console.log(error)
    }

  response.json(todos)

  /*if (nc) {

    nc.publish("todos", sc.encode("todos query"))

    console.log("todos query")
  }*/

})

app.get('/healthz', async function(request, response) {

  console.log('/healthz')

  await sequelize.sync().then(() => {

    console.log("Sync DB.")

    return response.status(200).json({
      status: 'OK'
    })

  }).catch(error => {

    console.log('Error: ', error)

    return response.status(500).json({
      error: 'Database'
    })
  })
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
    checked: false,
    date: body.date
  }

  todos = todos.concat(todo)

  const record = { ID: todo.id, TODO: todo.content, CHECKED: todo.checked }

  console.log("RECORD:", record.ID, record.TODO, record.CHECKED)

  try {

    await Todos.create(record).then(function (todo) {

      if (todo) {

        console.log('Todos.create', todo)

      } else {

        console.log('Error sequelize')
      }
    })

    if (nc) {

      nc.publish("todos", sc.encode("todo saved"))

      console.log('NATS published')
    }

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

app.put('/todos/:id', async (request, response) => {

  console.log('/todos/:id', request.body.id)

  try {

      var selector = { 
        where: { ID: request.body.id }
      }

      await sequelize.sync().then(() => {
        console.log("Sync DB.");
      })

      var record = {
        ID: request.body.id,
        TODO: request.body.content,
        CHECKED: request.body.checked
      }

      console.log('record', record)

      const result = await Todos.update(record, selector)

      console.log('Todos.update', result)

      if (nc) {
      
        nc.publish("todos", sc.encode("todo updated"))

        console.log('NATS published')

      }

    } catch (error) {

      console.log(error)
    }
})

app.delete('/todos/:id', async (request, response) => {

  console.log('DELETE')

  const id = Number(request.params.id)

  todos = todos.filter(todo => todo.id !== id)

  response.status(204).end()
})

const unknownUrl = (request, response) => {

  response.status(404).send({ error: 'Unknown Url' })
}

app.use(unknownUrl)

const PORT = process.env.BACKEND_PORT || 3002

//const PORT = 3002

const success = initialize()

app.listen(PORT, () => {

  console.log(`PORT: ${PORT}`)
})