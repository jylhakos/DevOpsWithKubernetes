const Koa = require('koa')

const app = new Koa()

const PORT = process.env.PORT || 3000

const createRandomString = () => Math.random().toString(36).substr(2, 6)

const startingString = createRandomString()

app.use(async ctx => {

  if (ctx.path.includes('favicon.ico')) return

  const stringNow = createRandomString()

  console.log('--------------------')

  console.log(`Response ${stringNow}`)

  ctx.body = `${startingString}: ${stringNow}`

});


// console.log(`Started with ${startingString}`)

app.listen(PORT)

console.log(`Server started in port ${PORT}`)
