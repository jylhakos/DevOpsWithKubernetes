const Koa = require('koa')

const app = new Koa()

const PORT = process.env.PORT || 3000

const getHashNow = () => {
  
  const randomhash = Math.random().toString(36).substr(2, 6)

  return randomhash

  //setTimeout(getHashNow, 5000)
}

const randomhash = getHashNow()

const loop = () => {

  const timestamp = new Date().toISOString()

  console.log(timestamp + ' ' + randomhash)

  setTimeout(loop, 5000)

}

app.listen(PORT)

console.log(`Server started in port ${PORT}`)

loop()

