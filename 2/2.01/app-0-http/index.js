// $ npm install koa --save

const Koa = require('koa')

const app = new Koa()

const path = require('path')

const PORT = process.env.PORT || 3000

const http = require('http')

const options = {
  hostname: 'localhost',
  port: 3001,
  //port: 8080,
  path: '/',
  method: 'GET'
}

const getContent = async () => new Promise(result => {

    var counter = null

    const request = http.request(options, response => {

      response.setEncoding('utf8')

      console.log(`statusCode: ${response.statusCode}`)

      response.on('data', data => {

        console.log(data)

        json_data = JSON.parse(data);

        counter = String(json_data.counter)

        console.log(counter)

        result(counter)

      })
    })

    request.on('error', error => {

      console.error(error)

    })

    request.end()

})

app.use(async ctx => {

  if (ctx.path.includes('favicon.ico')) return

  const counter = await getContent()

  console.log('counter', counter)

  const timestamp = new Date().toISOString()

  ctx.body = `<h1>${timestamp} : ${counter}</h1>`

  console.log('ctx.body', ctx.body)

});

app.listen(PORT)

console.log(`Port: ${PORT}`)
