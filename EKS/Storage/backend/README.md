# backend-example

## Environment

Execute the file e.g. `./server`.

Server accepts the following environment variables:

- `PORT` to choose which port for the application. Default: 8080

- In 1.12 and after
  - `REQUEST_ORIGIN` to pass an url through the cors check. Default: https://example.com

- In 2.4 and after
  - `REDIS_HOST` The hostname for redis. (port will default to 6379, the default for Redis)

- We don't open ports to Redis to the outside world because the backend will be able to access the application within the docker network.

- In 2.6 and after
  - `POSTGRES_HOST` The hostname for postgres database. (port will default to 5432 the default for Postgres)
  - `POSTGRES_USER` database user. Default: postgres
  - `POSTGRES_PASSWORD` database password. Default: postgres
  - `POSTGRES_DATABASE` database name. Default: postgres

