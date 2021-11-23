// $ sudo chmod 777 -R /usr/src/app/files

const Koa = require('koa')

const path = require('path')

const fs = require('fs')

const axios = require('axios')

const app = new Koa()

const PORT = process.env.FINDER_PORT || 3001

console.log('process.env.FINDER_PORT', process.env.FINDER_PORT)

const directory = path.join('/', 'usr', 'src', 'app', 'files')

const PERIOD = 1000 * 60 * 60 * 24

const DELAY = 1000 * 30

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

    console.log('removeFile')

    try {

      fs.unlink(filePath, (err) => { res()

        console.log('unlink')

      })

    } catch (error) {

      console.error(error)
    }

  })
}

app.use(async ctx => {

  if (ctx.path.includes('favicon.ico')) return
  
  await removeFile()

  setTimeout(await findAFile, DELAY)

  console.log('status', ctx.status)

  ctx.status = 200

});

const updateFile = async () => {

  console.log('updateFile')
  
  await removeFile()

  setTimeout(await findAFile, DELAY)

}

setInterval(updateFile, PERIOD)

app.listen(PORT)

console.log('PORT: ' + PORT)

