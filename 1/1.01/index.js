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

loop()
