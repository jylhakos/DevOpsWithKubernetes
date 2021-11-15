const Koa = require('koa')

const path = require('path')

const fs = require('fs')

const mime = require('mime-types')

const app = new Koa()

const PORT = process.env.PORT || 3000

const directory = path.join('/', 'usr', 'src', 'app', 'files')

const filePath = path.join(directory, 'image.jpg')

const getFile = async () => new Promise(res => {

  console.log('getFile: ' + filePath)

  fs.readFile(filePath, (err, buffer) => {

    if (err) return console.log('FAILED TO READ FILE', '----------------', err)

    res(buffer)
  })
})

app.use(async ctx => {

  if (ctx.path.includes('favicon.ico')) return

  ctx.body = await getFile()

  var mimeType = mime.lookup(filePath)
        
  const src = fs.createReadStream(filePath)
        
  ctx.response.set("content-type", mimeType)
        
  ctx.body = src

  ctx.status = 200
});

app.listen(PORT)

console.log('Image-Response Started: ' + PORT)

