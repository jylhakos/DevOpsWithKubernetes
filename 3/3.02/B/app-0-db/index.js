// $ npm install koa --save

const Koa = require('koa')

const app = new Koa()

const path = require('path')

const PORT = process.env.PORT || 3000

const http = require('http')

// k8s networking
const options = {
  hostname: 'app-2-db-svc',
  //hostname: 'localhost',
  port: 80,
  //port: 3001,
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

const hash_string = Math.random().toString(36).substr(2, 6)

app.use(async ctx => {

  const counter = await getContent()

  const timestamp = new Date().toISOString()

  switch (ctx.url) {

    case "/logs":

    if (ctx.path.includes('favicon.ico')) return

    console.log('counter', counter)

    ctx.body = `<h1>${timestamp} : ${hash_string} : ${counter}</h1>`

    console.log('ctx.body', ctx.body)

    break;

    default:

      ctx.body = `<h1>Error - 404</h1>`
    }

});

app.listen(PORT)

console.log(`Port: ${PORT}`)
