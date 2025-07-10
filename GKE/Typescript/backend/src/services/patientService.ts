import { v1 as uuid } from 'uuid'

import patients from '../../data/patients';

import { Patient, PatientEntryNonSSN, NewPatientEntry, PublicPatient, NewEntry, Gender } from '../types'

import { toNewPatientEntry, toNewEntry } from '../utils'

// 9.16
const getPatient = (id: string): PublicPatient | undefined => {

  const patient = patients.find(patient => patient.id === id);

  return patient;
}

// 9.11
//const getPatients = (): Array<Patient> => {

const getPatients = (): Array<PatientEntryNonSSN> => {

  return patients.map(({ id, name, dateOfBirth, gender, occupation, entries }) => ({
    id,
    name,
    dateOfBirth,
    gender,
    occupation,
    entries
  }));
}

// 9.12
const addPatient = (entry: NewPatientEntry): Patient => {

  const id: string = uuid();

  console.log(id,
    entry.name,
    entry.dateOfBirth,
    entry.ssn,
    entry.gender,
    entry.occupation);

  // 9.13
  const newPatientEntry = toNewPatientEntry(entry) as Patient;

  newPatientEntry.id = id;

  // 9.12
  /*
  const newPatientEntry = {
    id: id,
    ...entry
  };
  */

  patients.push(newPatientEntry);

  console.log(newPatientEntry);

  return newPatientEntry;
}

// 9.23
const addEntry = (patient_id: string, entry: NewEntry): Patient | any => {

  const entry_id: string = uuid();

  // Entry = | HealthCheckEntry | HospitalEntry | OccupationalHealthcareEntry

  // console.log('addEntry', 'id', id, 'entry', entry);

  const newEntry = toNewEntry(entry) as NewEntry;

  newEntry.entry.id = entry_id;

  // console.log('newEntry.entry', newEntry.entry);

  let updatedPatient: Patient = {
    id: "", 
    name: "",
    dateOfBirth: "",
    ssn: "",
    gender: Gender.Other,
    occupation: "",
    entries:[]
  };

  patients.forEach(function(patient: Patient)  {

    if (patient.id === patient_id) {

      console.log('patient.id', patient.id);

      patient.entries.push(newEntry.entry);

      // console.log('addEntry', patient)

      updatedPatient = patient
    }
  });

  console.log('addEntry', updatedPatient);

  return updatedPatient;
}

export default {
  getPatient,
  getPatients,
  addPatient,
  addEntry
};