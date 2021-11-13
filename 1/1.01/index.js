const getHashNow = () => {
  
  const randomHash = Math.random().toString(36).substr(2, 6)

  return randomHash

  //setTimeout(getHashNow, 5000)
}

const randomhash = getHashNow()

const loop = () => {

  const timestamp = new Date().toISOString()

  console.log(timestamp + ' ' + randomhash)

  setTimeout(loop, 5000)

}

loop(randomhash)