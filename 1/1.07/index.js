// $ npm install koa --save

const Koa = require('koa')

const PORT = process.env.PORT || 3000

const app = new Koa();

let timestamp = 0

let randomhash = 0

const generateContext = () => {
  
  timestamp = new Date().toISOString()

  randomhash = Math.random().toString(36).substr(2, 6)

  console.log(timestamp + ':' + randomhash)

}

app.use((ctx) => {

  switch (ctx.url) {
    case "/":
      ctx.body = `<h1>${timestamp}:${randomhash}</h1>`
      break;
    default:
      ctx.body = `<h1>Error 404 - Page Not Found.</h1>`

  console.log(ctx.body)
  }
})

const loop = () => {

  generateContext()

  setTimeout(loop, 5000)
}

app.listen(PORT)

console.log(`Server started in port ${PORT}`)

loop()
