// $ npm install koa --save

// $ npm install dotenv

const Koa = require('koa')

const app = new Koa()

const path = require('path')

const PORT = process.env.PORT || 3000

const http = require('http')

// k8s networking
const options = {
  hostname: 'example-service',
  //hostname: 'localhost',
  port: 80,
  //port: 3001,
  path: '/',
  method: 'GET'
}

const dotenv = require('dotenv')

dotenv.config()

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

  if (ctx.path.includes('favicon.ico')) return

  const counter = await getContent()

  if (process.env.MESSAGE) {
    console.log('counter', counter, process.env.MESSAGE)
  }
  else {
    console.log('counter', counter)
  }

  const timestamp = new Date().toISOString()

  if (process.env.MESSAGE) {
    ctx.body = `<h1>${process.env.MESSAGE} : ${timestamp} : ${hash_string} : ${counter}</h1>`
  }
  else {
    ctx.body = `<h1>${timestamp} : ${hash_string} : ${counter}</h1>`
  }

  

  console.log('ctx.body', ctx.body)

});

app.listen(PORT)

console.log(`Port: ${PORT}`)
