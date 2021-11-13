// $ npm install koa-router --save 

// $ npm install koa-bodyparser --save

const Koa = require('koa')

const Router = require('koa-router')

var bodyParser = require('koa-bodyparser')

const PORT = process.env.PORT || 3000

const app = new Koa()

const router = new Router()

var counter = 0

app
  .use(bodyParser())
  .use(router.routes())
  .use(router.allowedMethods())

app.use((ctx) => {

	switch (ctx.url) {
		case "/pingpong":
			console.log("pong " + counter)
			ctx.body = `<h1>pong ${counter}</h1>`
			counter = counter + 1
			break;
		default:
			ctx.body = `<h1>Error 404 - Page Not Found.</h1>`

	console.log(ctx.body)

  }
})

app.listen(PORT)

console.log(`Server started in port ${PORT}`)
