import diagnoses from '../../data/diagnoses';

import { Diagnose } from '../types'

// 9.10
const getDiagnoses = (): Array<Diagnose> => {
  return diagnoses;
}

const addDiagnose = () => {
  return null;
}

export default {
  getDiagnoses,
  addDiagnose
};