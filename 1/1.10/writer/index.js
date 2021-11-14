// $ npm install koa --save

const Koa = require('koa')

const app = new Koa()

const path = require('path')

const fs = require('fs')

const PORT = process.env.PORT || 3001

const directory = path.join('/', 'usr', '/', 'src', '/', 'app', '/', 'files')

console.log(directory)

const filePath = path.join(directory, '/', 'text.txt')

console.log(filePath)

if (!fs.existsSync(directory)) {

  fs.mkdir(directory, error => {

    if (error) {

      console.log(error)
    }
  });
}

const loop = () => {

  const timestamp = new Date().toISOString()

  const stringNow = Math.random().toString(36).substr(2, 6)

  console.log(`${timestamp} : ${stringNow}`)

  const content = `<h1>${timestamp} : ${stringNow}</h1>`

  fs.writeFile(filePath, content, error => {

    if (error) {

      console.error(error)
    }

  })

  setTimeout(loop, 5000)

}  

app.listen(PORT)

console.log(`Port: ${PORT}`)

loop()
