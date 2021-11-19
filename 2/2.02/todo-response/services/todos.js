//import axios from 'axios'

const axios = require('axios')

const url = 'backend-service/todos'

const get = () => {

  const request = axios.get(url)

  return request.then(response => response.data)
}

const create = todo => {

  const request = axios.post(url, todo)

  return request.then(response => response.data)
}

const update = (id, todo) => {

  const request = axios.put(`${url}/${id}`, todo)

  return request.then(response => response.data)
}

const remove = (id) => {

  const request = axios.delete(`${url}/${id}`)

  return request.then(response => response.data)
}

module.exports = {get, create, update, remove}

//export default {
//  get, create, update, remove
//}