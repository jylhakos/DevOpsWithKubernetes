// $ npm install koa --save

const Koa = require('koa')

const app = new Koa()

const path = require('path')

const fs = require('fs')

const PORT = process.env.PORT || 3000

const directory = path.join('/', 'usr', '/', 'src', '/', 'app', '/', 'files')

console.log(directory)

const filePath = path.join(directory, '/', 'text.txt')

console.log(filePath)

const getContent = async () => new Promise(response => {

  fs.readFile(filePath, 'utf8' , (error, data) => {

    if (error) {

      console.error(error)

      response(error)
    }

    console.log(data)

    response(data)

  })

});

app.use(async ctx => {

  if (ctx.path.includes('favicon.ico')) return

  ctx.body = await getContent()

  ctx.set('Content-type', 'text/html')

  ctx.status = 200

  console.log(ctx.body)

});

app.listen(PORT)

console.log(`Port: ${PORT}`)
