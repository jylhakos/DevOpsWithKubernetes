// $ npm install koa-router --save 

// $ npm install koa-bodyparser --save

const Koa = require('koa')

const Router = require('koa-router')

var bodyParser = require('koa-bodyparser')

const mime = require('mime-types')

const PORT = process.env.PORT || 3001

const app = new Koa()

const router = new Router()

const path = require('path')

const fs = require('fs')

var counter = 0

app
  .use(bodyParser())
  .use(router.routes())
  .use(router.allowedMethods())

app.use((ctx) => {

	switch (ctx.url) {

		case "/":

			var json_type = mime.lookup('json')
	        
	    ctx.response.set("content-type", json_type)
	        
	    var json_data = {counter: counter}
	        
	    ctx.body = JSON.stringify(json_data)
				
			console.log("ctx.body " + counter)

			break;

		case "/pingpong":

			console.log("pong " + counter)
			
			counter = counter + 1

			ctx.body = `<h1>pong ${counter}</h1>`

			break;

		default:

			ctx.body = `<h1>404</h1>`
  }
})

app.listen(PORT)

console.log(`Port: ${PORT}`)
