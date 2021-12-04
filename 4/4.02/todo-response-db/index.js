const Koa = require('koa')

var bodyParser = require('koa-body')

const path = require('path')

const fs = require('fs')

const fs_ex = require('fs-extra')

const mime = require('mime-types')

var serve = require('koa-static')

const service = require('./services/todos')

require('dotenv').config()

const app = new Koa()

const PORT = process.env.FRONTEND_PORT || 3000

console.log('process.env.FRONTEND_PORT', process.env.FRONTEND_PORT)

const directory = path.join('/', 'usr', 'src', 'app', 'files')

const file_path = path.join(directory, 'image.jpg')

const PERIOD = (1000 * 60 * 60 * 24) + (1000 * 60)

app.use(serve('public'))

app.use(bodyParser());

const public_file = './public/image.jpg'

var todos = []

async function copy() {

  try {

    await fs_ex.copy(file_path, public_file)

    console.log('copy', file_path, 'to', public_file)

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

        todos.push(todo.content)

        console.log(todo.content)
      }

      console.log(todos)

    }).catch(error => {

      console.log('Error', error)

      return 'Error'

    })
}

app.use(async (ctx, next) => {

  console.log('ctx.url', ctx.url)

  //ctx.set('Access-Control-Allow-Origin', '*')

  //ctx.set('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept')

  //ctx.set('Access-Control-Allow-Methods', 'POST, GET, PUT, DELETE, OPTIONS')

  if (ctx.url === '/' && ctx.method === 'GET') {

    console.log(ctx.method)

    var html = `
      <!DOCTYPE html>
      <html>
        <body>
          <img src=image.jpg width="50%" height="25%"></img>
          <br>
          <div>
            <input type="text" id="todo_input" minlength="1" maxlength="140">
            <button id="add_todo" onclick="clickFunction(event)">Create</button>
          </div>
          <br>
          <div style="height:15%;">
              <ul id="todo_list">`

              for (var i = 0; i < todos.length; i++) {
                html += `<li>` 
                html += todos[i] 
                html += `</li>`
              }

          html += 
          `</ul>
          </div>
          <script>

            var clickFunction = function(event) {

                event.stopImmediatePropagation();

                if(!event.detail || event.detail == 1) {

                  var todo_value = document.getElementById("todo_input").value;

                  console.log('todo_value', todo_value);

                  var ul = document.getElementById("todo_list");

                  var li = document.createElement("li");

                  li.appendChild(document.createTextNode(todo_value));

                  ul.appendChild(li);

                  const data = { todo: todo_value };

                  fetch('/', {
                    method: 'POST',
                    headers: {
                     'Content-Type': 'application/json',
                     'Accept': 'application/json'
                    },
                    body: JSON.stringify(data),
                   })

                  return true; 
              }
            };
            
            const btn = document.getElementById('add_todo');

            if (btn) {
              btn.addEventListener('click', clickFunction);
            }
          </script>
        </body>
      </html>
    `

    console.log('html', html)

    ctx.body = html

  } else if (ctx.url === '/todos' && ctx.method === 'GET') {
    
    console.log('ctx', ctx.method, ctx.url, ctx.origin)

    await initialize().then(() => {

      console.log('redirect', ctx.origin)

      ctx.redirect(ctx.origin)

    }).catch(error => {

        ctx.status = 500

        ctx.body = `<p>Internal Server Error</p>`

        console.log('Error', error, 'ctx.status', ctx.status)

        next()
    })

  } else if(ctx.url === "/healthz" && ctx.method === 'GET') {

    console.log('/healthz')

    try {

      await initialize().then(() => {

        ctx.status = 200

        ctx.body = `<p>OK</p>`

      }).catch(error => {

        ctx.status = 500

        ctx.body = `<p>Internal Server Error</p>`

        console.log('Error', error, 'ctx.status', ctx.status)

        next()
      })

    } catch (error) {

      ctx.status = 500

      ctx.body = `<p>Internal Server Error</p>`

      console.log('Error', error, 'ctx.status', ctx.status)

      next()
    }
  }
  else if (ctx.url === '/' && ctx.method === 'POST') {
  
    var data = ctx.request.body

    console.log("POST", data.todo)

    const todo = {
      content: data.todo,
      date: new Date().toISOString()
    }

    service.create(todo).then(result => {

      todos.push(result.content)

      console.log('todos', todos)
    })

    ctx.status = 200
  }
})

function updateFile() {

  console.log('updateFile')

  copy()
}

setInterval(updateFile, PERIOD)

const success = initialize()

app.listen(PORT)

console.log('PORT: ' + PORT)

