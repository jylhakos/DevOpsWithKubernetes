import { Gender, NewPatientEntry, Entry, NewEntry } from './types'

const isString = (text: unknown): text is string => {
  return typeof text === 'string' || text instanceof String;
}

/*const isArray = (object: unknown): object is Array<any> => {
  return Array.isArray(object);
}*/

// 9.19
const isEntries = (object: unknown): object is Entry[] => {
  return object !== undefined;
}


const isEntry = (object: unknown): object is Entry => {
  return object !== undefined;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const isGender = (param: any): param is Gender => {
  return Object.values(Gender).includes(param);
};

// 9.13
export const parseGender = (gender: unknown): Gender => {

  if (!gender || !isGender(gender)) {

    console.log('Error', gender);

    throw new Error('Incorrect or missing gender: ' + gender);

  }

  return gender;

};

export const parseName = (name: unknown): string => {

  if (!name || !isString(name)) {

    console.log('Error', name);

    throw new Error('Incorrect or missing name: ' + name);

  }

  return name;

};

export const isDate = (date: string): boolean => {
  return Boolean(Date.parse(date));
};

export const parseDateOfBirth = (dateOfBirth: unknown): string => {

  if (!dateOfBirth  || !isString(dateOfBirth) || !isDate(dateOfBirth)) {

    console.log('Error', dateOfBirth);

    throw new Error('Incorrect or missing date of birth: ' + dateOfBirth);

  }

  return dateOfBirth;

};

export const parseSSN = (ssn: unknown): string => {

  if (!ssn || !isString(ssn)) {

    console.log('Error', ssn);

    throw new Error('Incorrect or missing ssn: ' + ssn);

  }

  return ssn;

};

export const parseOccupation = (occupation: unknown): string => {

  if (!occupation || !isString(occupation)) {

    console.log('Error', occupation);

    throw new Error('Incorrect or missing occupation: ' + occupation);

  }

  return occupation;

};

// 9.19
//export const parseEntries = (entries: unknown): Array<string> => {
  export const parseEntries = (entries: unknown): Entry[] => {

    if (!entries || !isEntries(entries)) {

    console.log('Error', entries);

    throw new Error('Incorrect or missing entries: ' + entries);

  }

  return entries;
};

export const parseEntry = (entries: unknown): Entry => {

  // console.log('parseEntry', entries);

  if (!entries || !isEntry(entries)) {

    console.log('Parse Entry Error', entries);

    throw new Error('Incorrect or missing entries: ' + entries);
  }

  return entries;
};

export const parseId = (id: unknown): string => {

  if (!id || !isString(id)) {

    console.log('Error', id);

    throw new Error('Missing id: ' + id);

  }

  return id;
};

export type Fields = { name: unknown, dateOfBirth: unknown, ssn: unknown, gender: unknown, occupation: unknown, entries: unknown };

export type Entries = { entry: Entry };

export const toNewPatientEntry= ({ name, dateOfBirth, ssn, gender, occupation, entries } : Fields): NewPatientEntry => {

  const newEntry: NewPatientEntry = {
    name: parseName(name),
    dateOfBirth: parseDateOfBirth(dateOfBirth),
    ssn: parseSSN(ssn),
    gender: parseGender(gender),
    occupation: parseOccupation(occupation),
    entries: parseEntries(entries)
  };

  console.log('newEntry', newEntry)

  return newEntry;
};

export const toNewEntry = (entry: Entries): NewEntry => {

  // console.log('toNewEntry', entry)

  const newEntry: NewEntry = {
    entry: parseEntry(entry)
  };

  // console.log('newEntry', newEntry)

  return newEntry;
};