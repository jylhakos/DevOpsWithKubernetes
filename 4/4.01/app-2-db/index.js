// $ npm install --save koa-router 

// $ npm install --save koa-bodyparser 

// $ npm install --save sequelize

// $ npm install --save sequelize-cli

// $ npm install --save pg

// $ npm install --save dotenv

const Koa = require('koa')

const Router = require('koa-router')

var bodyParser = require('koa-bodyparser')

const mime = require('mime-types')

//const PORT = process.env.PORT || 3001

const PORT = 3001

const app = new Koa()

const router = new Router()

const path = require('path')

const fs = require('fs')

require('dotenv').config()

const { EventEmitter } = require('events');

var connect_event = new EventEmitter();

var counter = 0

var counter_id = 0

app
  .use(bodyParser())
  .use(router.routes())
  .use(router.allowedMethods())

const { Sequelize, Model, DataTypes } = require('sequelize');

console.log('process.env.DB_HOST', process.env.DB_HOST)

const sequelize = new Sequelize(process.env.DB_SCHEMA || 'postgres',
                                process.env.DB_USER || 'postgres',
                                //process.env.DB_PASSWORD || 'postgres',
                                process.env.POSTGRES_PASSWORD || 'postgres',
                                {
                                    host: process.env.DB_HOST || 'localhost',
                                    port: process.env.DB_PORT || 5432,
                                    dialect: 'postgres',
                                    dialectOptions: {
                                        ssl: process.env.DB_SSL == "true"
                                }
})

const Counter = sequelize.define('counter', {
    ID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      allowNull: false,
    },
    COUNTER: {
        type: DataTypes.INTEGER,
        //type: DataTypes.STRING,
        allowNull: false
    }
})

const initialize = (async () => {

	console.log('initialize')

	try {

		var connect_success = false

		const initial = await sequelize.authenticate().then(() => {

			sequelize.sync({ force: true }).then(() => {

  			console.log("Drop and Sync DB.")

			}).catch(error => {

    			console.log('Drop and Sync DB Error: ', error)
  			})

  			connect_success = true

			connect_event.emit('connected', {connected: true})

		}).catch(error => {

    		console.log('Sequelize Error: ', error)

    		connect_event.emit('connected', {connected: false})
  		})
	
		if (connect_success) {

			await sequelize.sync().then(() => {

		  		console.log("Sync DB.")
			})

			const result = await Counter.create({

				COUNTER: 0
			})

			console.log(result.toJSON())

			const result_json = result.toJSON()

			counter_id = result_json.ID

			console.log('ID:', counter_id)

		}

	} catch (error) {

		console.log('Error: initialize', error)
  	}
})

app.use(async ctx => {

	switch (ctx.url) {

		case "/":

			console.log('ctx.request.method', ctx.request.method)

			try {

				await sequelize.sync().then(() => {

	  				console.log("Sync DB.")

				}).catch(error => {

    				console.log('Sync DB Error: ', error)

					ctx.status = 500

  				})
				
				if (ctx.status != 500) {

					await Counter.findByPk(counter_id).then((result) => {

						console.log('result', result)

						if (result) {

			    			counter = result.COUNTER

			    			console.log('result.COUNTER', counter)

			    			var json_type = mime.lookup('json')
		        
		    				ctx.response.set("content-type", json_type)
		        
		    				var json_data = {counter: counter}
		        
		    				ctx.body = JSON.stringify(json_data)

		    				ctx.status = 200
					
							console.log("ctx.body", counter)

						} else {

							ctx.status = 204
						}
					})
				}

			} catch (error) {

				console.log('Error: ', error)

				ctx.status = 500
  			}

  			console.log("ctx.status", ctx.status)

  			break;

		case "/pingpong":

			counter = counter + 1

			ctx.body = `<h1>pong ${counter}</h1>`

			console.log("pong " + counter)

    		const record = { COUNTER: counter }

    		console.log("COUNTER" + record.COUNTER)

    		try {

    			await sequelize.sync().then(() => {

	  				console.log("Sync DB.")
				})

				const result = await Counter.update(record, {

					where: {
	        			ID: counter_id,
	    			},

	      			returning: true,
	    		})

	    		console.log(result)

    		} catch (error) {
    			
    			console.log('Error: ', error)
  			}

			break;

		case "/healthz":

  			console.log('/healthz', ctx.request.body)

  			try {

				await sequelize.sync().then(() => {

	  				console.log("Sync DB.")

	  				ctx.status = 200

				})

			} catch (error) {

				console.log('Error: ', error)

				ctx.status = 500

  			}

			break;

		default:

			ctx.body = `<h1>404</h1>`
	}
})

const success = initialize()

connect_event.on('connected', function(result) {

	var result_json = JSON.stringify(result) + '\n'

	process.stdout.write(result_json)

	app.listen(PORT)

	console.log(`Port: ${PORT}`)
})

