const Koa = require('koa')

const app = new Koa()

const PORT = process.env.PORT || 3000

const createRandomString = () => Math.random().toString(36).substr(2, 6)

const startingString = createRandomString()

app.listen(PORT)

console.log(`Server started in port ${PORT}`)

console.log(startingString)
