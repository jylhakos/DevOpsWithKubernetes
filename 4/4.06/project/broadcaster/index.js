// $ npm install --save nats@latest

const NATS = require('nats')

require('dotenv').config()

const nc = NATS.connect({
  url: process.env.NATS_URL || 'nats://todos-nats:4222'
})

console.log(`NATS: ${nc}`)

const sub = nc.subscribe("todos")

const main = async () => {

  console.log('main')

  for await (const m of sub) {

    console.log(`[${sub.getProcessed()}]: ${m.data}`)
  }

  nc.publish("done", "todo");

  console.log("done")

  main()
}

main() 