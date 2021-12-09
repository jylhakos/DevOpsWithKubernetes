// $ npm install --save nats@latest

const service = require('./services/subscriber_publisher')

const express = require('express')

const app = express()

app.use(express.json())

const PORT = 3004

async function connect_server(server) {

  console.log('connect_server')

  try {

    const connected = await service.connector(server)

    console.log('NATS', connected)

    return connected

   } catch (error) {

      console.error(error)

      return null
   }
}

async function subscriber(nc) {

  console.log('subscriber')

  try {

    const subscribed = await service.subscriber()

    console.log('NATS', subscribed)

   } catch (error) {

      console.error(error)
   }
}

async function publisher(nc) {

  console.log('publisher')

  try {

    const published = await service.publisher(nc)

    console.log('NATS', published)

   } catch (error) {

      console.error(error)
   }
}

async function broadcast_service(nc1, nc2) {

  console.log('broadcast_service')

  await subscriber(nc1)

  await publisher(nc2)

}

async function connect_services(server) {

  console.log('connect_services')

  const connect_broadcast = await connect_server(server)

  return connect_broadcast

}

app.listen(PORT)

console.log('PORT: ' + PORT)

var nats_server = "nats_server"

const nc1 = connect_services(nats_server)

var slack_server = "slack_server"

const nc2 = connect_services(slack_server)

setInterval(broadcast_service, 6*1000, nc1, nc2)
