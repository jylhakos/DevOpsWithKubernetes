const express = require('express')

const app = express()

const cors = require('cors')

app.use(express.static('build'))

app.use(cors())

app.use(express.json())

const requestLogger = (request, response, next) => {

  console.log('Method:', request.method)

  console.log('Path:  ', request.path)

  console.log('Body:  ', request.body)

  console.log('-----------------------')

  next()
}

app.use(requestLogger)

var todos = [
  {
    id: 1,
    content: "Todo A",
    date: "2021-11-19T11:30:32.093Z"
  },
  {
    id: 2,
    content: "Todo B",
    date: "2021-11-19T12:33:35.091Z"
  }
]

app.get('/', (request, response) => {

  console.log('GET /')

  response.send('<h1>TODO</h1>')
})

app.get('/todos', (request, response) => {

  console.log('GET /todos')

  response.json(todos)
})

const generateId = () => {

  const maxId = todos.length > 0 ? Math.max(...todos.map(n => n.id)) : 0

  return maxId + 1
}

app.post('/todos', (request, response) => {

  console.log('POST /todos', request.body)

  const body = request.body

  if (!body.content) {

    return response.status(400).json({
      error: 'Content Unknown'
    })
  }

  const todo = {
    id: generateId(),
    content: body.content,
    date: body.date
  }

  todos = todos.concat(todo)

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

app.listen(PORT, () => {

  console.log(`PORT: ${PORT}`)
})