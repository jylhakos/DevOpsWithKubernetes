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

	await sequelize.authenticate().then(() => {

		sequelize.sync({ force: true }).then(() => {

  			console.log("Drop and Sync DB.")
		})
	})
	
	try {

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
				})
				
				await Counter.findByPk(counter_id).then((result) => {

					console.log('result', result)

					if (result) {

		    			counter = result.COUNTER

		    			console.log('result.COUNTER', counter)
					}

				})

			} catch (error) {

				console.log('Error: ', error)
  			}

			var json_type = mime.lookup('json')
	        
	    	ctx.response.set("content-type", json_type)
	        
	    	var json_data = {counter: counter}
	        
	    	ctx.body = JSON.stringify(json_data)
				
			console.log("ctx.body " + counter)

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

	  				//ctx.response.status = 200

	  				//ctx.response.set('Content-Type', 'text/html charset=utf-8')
				})

			} catch (error) {

				console.log('Error: ', error)

				ctx.status = 500
				
				//ctx.response.status = 500

				//ctx.response.set('Content-Type', 'text/html charset=utf-8')
  			}

			break;

		default:

			ctx.body = `<h1>404</h1>`
	}
})

initialize()

app.listen(PORT)

console.log(`Port: ${PORT}`)