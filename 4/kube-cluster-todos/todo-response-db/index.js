//const Koa = require('koa')

//var bodyParser = require('koa-body')

//var serve = require('koa-static')

//const app = new Koa()

//const Router = require('@koa/router')

//const router = new Router()

const path = require('path')

const fs = require('fs')

const fs_ex = require('fs-extra')

const mime = require('mime-types')

const service = require('./services/todos')

require('dotenv').config()

const express = require('express')

const app = express()

app.use(express.json())

const PORT = process.env.FRONTEND_PORT || 3000

//const PORT = 3000

console.log('process.env.FRONTEND_PORT', process.env.FRONTEND_PORT)

const directory = path.join('/', 'usr', 'src', 'app', 'files')

const file_path = path.join(directory, 'image.jpg')

const PERIOD = (1000 * 60 * 60 * 24) + (1000 * 60)

app.use(express.static('public'));

//app.use(router.routes()).use(router.allowedMethods());

//app.use(serve('public'))

//app.use(bodyParser());

const public_file = './public/image.jpg'

var todos = []

async function render() {

  var html = `
        <!DOCTYPE html>
        <html>
          <body>
            <img src=image.jpg width="50%" height="25%"></img>
            <br>
            <div>
              <input type="text" id="todo_input" minlength="1" maxlength="140">
              <button id="add_todo" onclick="clickCreate(event)">Create</button>
            </div>
            <br>
            <div style="height:15%;">
                <ul id="todo_list">`
                
                for (var i = 0; i < todos.length; i++) {
                  html += `<li`
                  html += ` id="`
                  html += todos[i].id
                  html += `"`
                  html += `>`
                  html += `<label>`
                  html += todos[i].content
                  html += `<label>`
                  html += ` <input type='checkbox' id=todo_done value=` + todos[i].id + ` name="` + todos[i].content + `"` + ` onclick='clickDone(event, value, name)'`
                  if (todos[i].checked == true) {
                    html += ` checked="` + todos[i].checked + `"`
                  }
                  html += `/>`
                  html += `</li>` 
                }

            html += 
            `</ul>
            </div>
            <script>

              var clickCreate = async function(event) {

                  event.stopImmediatePropagation();

                  if(!event.detail || event.detail == 1) {

                    var content = document.getElementById("todo_input").value;

                    console.log('content', content);

                    var ul = document.getElementById("todo_list");

                    var li = document.createElement("li");

                    li.appendChild(document.createTextNode(content));

                    var checkbox = document.createElement('input');

                    checkbox.type = 'checkbox';

                    checkbox.checked = false;

                    li.appendChild(checkbox);

                    ul.appendChild(li);

                    const data = { content: content };

                    const response = await fetch('/todos', {
                      method: 'POST',
                      headers: {
                       'Content-Type': 'application/json',
                       'Accept': 'application/json'
                      },
                      body: JSON.stringify(data),
                     })

                    console.log('response', response);

                    document.location.reload(true);

                    return true; 
                }
              };

              var clickDone = function(event, value, name) {

                event.stopImmediatePropagation();

                if(!event.detail || event.detail == 1) {

                  var id = value;

                  data = {
                    id: value,
                    content: name,
                    checked: true
                  };

                  console.log('data', data);

                  fetch('/todos/' + id, {
                    method: 'PUT',
                    headers: {
                     'Content-Type': 'application/json',
                     'Accept': 'application/json'
                    },
                    body: JSON.stringify(data),
                  })
                }
              };

              const btn = document.getElementById('add_todo');

              if (btn) {
                btn.addEventListener('click', clickCreate);
              }

            </script>
          </body>
        </html>
      `
  return html
}

async function copy() {

  try {

    await fs_ex.copy(file_path, public_file)

    console.log('copy', file_path, 'to', public_file)

   } catch (error) {

      console.error(error)
   }
}

async function create(todo) {

  try {

    await service.create(todo)

   } catch (error) {

      console.error(error)
   }
}

async function initialize() {

  todos = []

  await service.get().then(result => {

      console.log(result)

      for(var i = 0; i < result.length; i++) {
        
        var todo = result[i]

        todos.push(todo)

        console.log(todo)
      }

      console.log(todos)

    }).catch(error => {

      console.log('Error', error)

      return 'Error'

    })
}

app.get("/", async (request, response) => {

  console.log('/')

  await initialize().then(() => {

    console.log('initialized')

  })

  const body = await render()

  console.log('html', body)

  response.send(body)

})

app.put("/todos/:id", async (request, response) => {

  var id = request.params.id

  var data = request.body

  console.log('/todos/:id', id, data)

  const todo = {
    id: data.id,
    content: data.content,
    checked: data.checked,
    date: new Date().toISOString()
  }

  await service.update(id, todo).then(() => {

    console.log('updated', todo)

  })

  await initialize().then(() => {

    console.log('initialized')

  })
  
  const body = await render()

  console.log('body', body)

  response.send(body)

})

app.get("/todos", async (request, response) => {

  console.log('/todos')

  await initialize().then(() => {

    console.log('redirect')

    response.redirect('back')

  }).catch(error => {

      const status = 500

      const body = `<p>Internal Server Error</p>`

      console.log('Error', error, 'status', status)

      response.status(status).send(body)
  })
})

app.get("/healthz", async (request, response) => {

  console.log('/healthz')

  try {

    await initialize().then(() => {

      const status = 200

      const body = `<p>200</p>`

      response.status(status).send(body)

    }).catch(error => {

      const status = 500

      const body = `<p>Internal Server Error</p>`

      console.log('Error', error, 'status', status)

      response.status(status).send(body)
    })

  } catch (error) {

    const status = 500

    const body = `<p>Internal Server Error</p>`

    console.log('Error', error, 'status', status)

    response.status(status).send(body)
  }
})

app.post("/todos", async (request, response) => {

  console.log('/todos')

  var data = request.body

  const todo = {
    content: data.content,
    checked: false,
    date: new Date().toISOString()
  }

  await create(todo).then(() => {

    console.log('created', todo)

  })

  await initialize().then(() => {

    console.log('initialized', todos)

  })

  await render().then((data) => {

    console.log('html', data)
  
    const body = data

    const status = 200

    response.status(status).send(body)
  })
})

function updateFile() {

  console.log('updateFile')

  copy()
}

setInterval(updateFile, PERIOD)

const success = initialize()

app.listen(PORT)

console.log('PORT: ' + PORT)