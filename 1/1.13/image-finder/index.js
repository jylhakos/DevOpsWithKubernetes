// $ sudo chmod 777 -R /usr/src/app/files

const Koa = require('koa')

const path = require('path')

const fs = require('fs')

const axios = require('axios')

const app = new Koa()

const PORT = process.env.PORT || 3001

const directory = path.join('/', 'usr', 'src', 'app', 'files')

//const directory = './public'

const filePath = path.join(directory, 'image.jpg')

const fileAlreadyExists = async () => new Promise(res => {

  fs.stat(filePath, (err, stats) => {

    if (err || !stats) return res(false)

    console.log('fileAlreadyExists', true)

    return res(true)
  })
})

const findAFile = async () => {

  console.log('findAFile')

  if (await fileAlreadyExists()) {

    console.log('fileAlreadyExists')

    return
  }

  await new Promise(res => fs.mkdir(directory, (err) => res()))

  const response = await axios.get('https://picsum.photos/256/256', { responseType: 'stream' })

  response.data.pipe(fs.createWriteStream(filePath))

}

const removeFile = async () => { new Promise(res => {

    fs.unlink(filePath, (err) => { res()

      console.log('unlink')

    })
  })
}

app.use(async ctx => {

  if (ctx.path.includes('favicon.ico')) return
  
  await removeFile()

  await findAFile()

  console.log('status', ctx.status)

  ctx.status = 200

});

removeFile()

findAFile()

app.listen(PORT)

console.log('Image-Finder Started: ' + PORT)

