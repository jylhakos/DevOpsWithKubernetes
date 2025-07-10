// $ npm init

// $ npm install typescript --save-dev

// $ npm run tsc -- --init

// $ npm install express

// $ npm install --save-dev eslint @types/express @typescript-eslint/eslint-plugin @typescript-eslint/parser

// $ npm install --save-dev ts-node-dev

// $ npm install cors --save

// $ npm install @types/uuid --save-dev --save

// $ npm run dev

// $ npm run tsc

// $ npm run dev --resolveJsonModule

import express from 'express';

const cors = require('cors');

const app = express();

const PORT = 3001;

import diagnoseRouter from './routes/diagnoseRouter';

import patientRouter  from './routes/patientRouter';

app.use(cors());

app.use(express.json());

// 9.8
app.get('/ping', (req, res) => {

  console.log('ping', req.body);

  res.send('pong');

});

// 9.10
app.use('/api', diagnoseRouter);

// 9.11
app.use('/api', patientRouter);

app.listen(PORT, () => {

  console.log(`Server running on port ${PORT}`);

});