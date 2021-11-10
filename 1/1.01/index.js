const getHashNow = () => {
  
  const randomHash = Math.random().toString(36).substr(2, 6)

  return randomHash

  //setTimeout(getHashNow, 5000)
}

const rh = getHashNow()

const loop = () => {

  const timestamp = new Date().toISOString()

  console.log(rh + ' ' + timestamp)

  setTimeout(loop, 5000)

}

loop(rh)
