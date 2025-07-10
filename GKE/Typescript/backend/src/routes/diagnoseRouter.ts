import express, {Request, Response } from 'express';

import diagnoseService from '../services/diagnoseService';

const diagnoseRouter = express.Router();

// 9.10
diagnoseRouter.get('/diagnoses', (_req: Request, res: Response) => {

  console.log('diagnoses')

  res.json(diagnoseService.getDiagnoses());
});

diagnoseRouter.post('/', (_req: Request, res: Response) => {
  res.send('Saving DiagnoseEntry');
});

export default diagnoseRouter;