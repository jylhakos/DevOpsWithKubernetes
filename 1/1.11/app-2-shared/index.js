// $ npm install koa-router --save 

// $ npm install koa-bodyparser --save

const Koa = require('koa')

const Router = require('koa-router')

var bodyParser = require('koa-bodyparser')

const PORT = process.env.PORT || 3001

const app = new Koa()

const router = new Router()

const path = require('path')

const fs = require('fs')

const directory = path.join('/', 'usr', '/', 'src', '/', 'app', '/', 'files')

console.log(directory)

const filePath = path.join(directory, '/', 'text.txt')

console.log(filePath)

if (!fs.existsSync(directory)) {

	console.log('fs.existsSync')

  fs.mkdir(directory, {recursive: true}, error => {

    if (error) {

      console.log('Error: ' + error)
    }
  });
}

var counter = 0

app
  .use(bodyParser())
  .use(router.routes())
  .use(router.allowedMethods())

app.use((ctx) => {

	switch (ctx.url) {

		case "/pingpong":

			console.log("pong " + counter)
			
			counter = counter + 1

			fs.writeFile(filePath, counter, error => {

	    	if (error) {

	      	console.error(error)
	    	}

  		})

			ctx.body = `<h1>pong ${counter}</h1>`
			
			break;
		default:
			ctx.body = `<h1>Error 404 - Page Not Found.</h1>`

	console.log(ctx.body)

  }
})

app.listen(PORT)

console.log(`Server started in port ${PORT}`)
