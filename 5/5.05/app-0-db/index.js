// $ npm install koa --save

const Koa = require('koa')

const app = new Koa()

const path = require('path')

// const PORT = process.env.PORT || 3000

const PORT = 3000

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

var counter = 0

const getContent = async () => new Promise(result => {

  console.log('getContent')

  var counter = null

  const request = http.request(options, response => {

    response.on('data', data => {

      const statusCode = response.statusCode

      if (statusCode == 500) {

        result('Error')

      }
      else if (statusCode == 204) {

        result('No Content')

      }
      else {

        console.log(`statusCode: ${response.statusCode}`)

        json_data = JSON.parse(data);

        counter = String(json_data.counter)

        console.log('data', counter)

        response.setEncoding('utf8')

        result(counter)
      }
    })
  })

  request.end()

  console.log('request.end')

  request.on('error', error => {

    console.error('http.request', error)

    result('Error')

  })
})

const hash_string = Math.random().toString(36).substr(2, 6)

app.use(async (ctx, next) => {

  switch (ctx.url) {

    case "/":

    console.log('GET /')

      if (ctx.path.includes('favicon.ico')) return

      counter = await getContent()

      if (counter == 'Error') {

          ctx.status = 500

          console.log('ctx.status', ctx.status)

          next()

      } else if(counter == 'No Content') {

          ctx.status = 204

          console.log('ctx.status', ctx.status)

      }
      else {

        console.log('counter', counter)

        ctx.status = 200

        const timestamp = new Date().toISOString()

        ctx.body = `<h1>${timestamp} : ${hash_string} : ${counter}</h1>`

        console.log('ctx.body', ctx.body)

      }

      break

    case "/healthz":

        console.log('/healthz')

        try {

          counter = await getContent()

          if (counter == 'Error') {

            ctx.status = 500

            console.log('ctx.status', ctx.status)

            next()

          } else if(counter == 'No Content') {

            ctx.status = 204

            console.log('ctx.status', ctx.status)

          }
          else {
          
            console.log('counter', counter)

            ctx.status = 200

          }

        } catch (error) {

          console.log('Error: initialize', error)
        }

      break

    default:

      ctx.status = 404

      ctx.body = `<h1>404</h1>`
  }

})

app.listen(PORT)

console.log(`Port: ${PORT}`)
