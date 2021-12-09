// $ npm install --save nats@latest

require('dotenv').config()

const { connect, StringCodec } = require("nats")

const NATS = require('nats')

//const nc = NATS.connect({
  //url: process.env.NATS_URL || 'nats://todos-nats:4222'
  //servers: 'todos-nats:4222'
//})

const SLACK_TOKEN = process.env.SLACK_TOKEN

console.log('NATS')

var SLACK_MSG = {
  "channel": "CHANNEL_ID",
  "text": "todo"
}

const connector = async (server) => {

  console.log('NATS connect', server)

  if (server == "slack_server") {
    //const nc1 = await connect({ servers:"slack-nats:4222", token: SLACK_TOKEN })
    const nc1 = await NATS.connect({ servers:'todos-nats:4222'});
    console.log('NATS connected', server)
    return nc1
  }
  else {
    const nc2 = await NATS.connect({ servers:'todos-nats:4222'})
    console.log('NATS connected', server)
    return nc2
  }

   return null
}

const publisher = async (nc2) => {
//const publisher = async () => {

  console.log('publisher')

  var nc = null
  
  if (!nc2) {
    nc = await NATS.connect({ servers:'todos-nats:4222'})
    console.log('NATS connected')
  } else {
    nc = nc2
  }

  const sc = StringCodec()

  nc.publish('done', sc.encode(SLACK_MSG))

  console.log("NATS published")

  await nc.closed()
}

const subscriber = async (nc1) => {
//const subscriber = async () => {

  console.log('subscriber')

  //const nc = await connect({servers: 'todos-nats:4222'})

  var nc = null
  
  if (!nc1) {
    nc = await NATS.connect({servers: 'todos-nats:4222'})
  } else {
    nc = nc1
  }

  const sc = StringCodec()

  const sub = nc.subscribe("todos")

  console.log("NATS await subscribed")

  for await (const m of sub) {
      console.log(`[${sub.getProcessed()}]: ${sc.decode(m.data)}`);
  }

  nc.publish('todos', sc.encode('todo read'))

  console.log("NATS published")

  nc.unsubscribe('todos')

  await nc.closed()

  /*const ready = await new Promise((resolve) => {

    subscription = nc.subscribe('todos', (msg) => {

      console.log("NATS subscribed", sc.decode(msg.data))

      resolve(subscription)

    })

  })

  nc.unsubscribe(ready)

  await nc.closed()*/
}

module.exports = {subscriber, publisher, connector}
