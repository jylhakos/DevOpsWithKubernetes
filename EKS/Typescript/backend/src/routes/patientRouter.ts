import express, {Request, Response } from 'express';

const patientRouter = express.Router();

import patientService from '../services/patientService';

// 9.23
patientRouter.post('/patients/:id/entries', async (req : Request, res: Response) => {

  console.log('req.body', req.body);
  
  const id = req.params.id;

  const entries = req.body;

  console.log('/patients/:id/entries', id, entries);

  const newEntry = patientService.addEntry(
    id,
    entries
  );

  // console.log('newEntry', newEntry);

  res.json(newEntry);

});

// $ curl -X "GET" http://localhost:3001/api/patients/:id

// 9.16
patientRouter.get('/patients/:id', async (req : Request, res: Response) => {

  const id = req.params.id

  console.log('/patients/:id', id)

  const patient = await patientService.getPatient(id)

  console.log('patient', patient)

  res.json(patient);

});

// 9.11
patientRouter.get('/patients', (_req : Request, res: Response) => {

  console.log('patients')

  res.json(patientService.getPatients());
});

// 9.12
patientRouter.post('/patients', (req: Request, res: Response) => {

  const { name, dateOfBirth, ssn, gender, occupation, entries } = req.body;

  const newPatientEntry = patientService.addPatient({ 
    name,
    dateOfBirth,
    ssn,
    gender,
    occupation,
    entries
  });

  console.log('newPatientEntry', newPatientEntry)

  res.json(newPatientEntry);
});

// $ curl -X "POST" http://localhost:3001/api/patients/d2773822-f723-11e9-8f0b-362b9e155667/entries -H "Content-Type: application/json" -d "{\"date\":\"2021-09-11\", \"specialist\":\"MD House\", \"type\":\"HealthCheck\", \"description\":\"Daily control visit\", \"healthCheckRating\":0}"

export default patientRouter;

