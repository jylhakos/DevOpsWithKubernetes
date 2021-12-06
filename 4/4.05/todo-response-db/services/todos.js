// $ npm install --save dotenv

//import axios from 'axios'

const axios = require('axios')

require('dotenv').config()

//const url = 'http://localhost:3002/todos'

//const url = 'http://backend-db-service/todos'

const url = process.env.BACKEND_URL || "http://localhost:3002/todos"

console.log('process.env.BACKEND_URL', process.env.BACKEND_URL, 'URL', url)

const get = () => {

  console.log('get', url)

  const request = axios({
    url: url,
    method: 'get'
  })

  //const request = axios.get(url)

  return request.then(response => response.data)
}

const create = todo => {

  console.log('create', todo)

  const request = axios.post(url, todo)

  return request.then(response => response.data)
}

const update = (id, todo) => {

  console.log('update', id)

  const request = axios.put(`${url}/${id}`,todo)

  return request.then(response => response.data)
}

const remove = (id) => {

  console.log('remove', id)

  const request = axios.delete(`${url}/${id}`)

  return request.then(response => response.data)
}

module.exports = {get, create, update, remove}

//export default {
//  get, create, update, remove
//}