// $ npm install koa-router --save 

// $ npm install koa-bodyparser --save

const Koa = require('koa')

const Router = require('koa-router');

var bodyParser = require('koa-bodyparser');

const PORT = process.env.PORT || 3000

const app = new Koa();

const router = new Router();

const createRandomString = () => Math.random().toString(36).substr(2, 6)

const startingString = createRandomString()

app
  .use(bodyParser())
  .use(router.routes())
  .use(router.allowedMethods())

app.use((ctx) => {

	const stringNow = createRandomString()

	switch (ctx.url) {
		case "/":
			ctx.body = `<h1>${new Date().toISOString()}:${startingString}:${stringNow}</h1>`
			break;
		default:
			ctx.body = `<h1>Page Not Found.</h1>`

	console.log(ctx.body)
  }
})

/*router.get('/', async ctx => {

	const stringNow = createRandomString()

	ctx.type = 'text/plain; charset=utf-8';

    ctx.body = 
    `<h1>${startingString}</h1>
    <h2>${startingString}</h2>
    <h3>${stringNow}</h3>
	<h4>${new Date().toISOString()}</h4>`

    console.log(ctx.body)

})*/

app.listen(PORT)

console.log(`Server started in port ${PORT}`)
