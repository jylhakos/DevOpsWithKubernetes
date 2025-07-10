// PatientPage.tsx
import React from 'react';

import { useParams } from 'react-router-dom';

import axios from "axios";

import { Segment, Icon, Button } from 'semantic-ui-react'

import { apiBaseUrl } from "../constants";

import { Patient, Entry, Diagnosis, HealthCheckRating } from "../types";

import { usePatientStateValue, useDiagnoseStateValue, setPatientPage, setNewEntry} from "../state";

import { EntryFormValues } from "./AddEntryForm";

import AddEntryModal from "./AddEntryModal";

function assertNever(x: never): never {
	throw new Error(`Unexpected object: ${x}`);
}

// 9.17
const PatientPage = () => {

	const [{ patients }, dispatch] = usePatientStateValue();

	const [{ diagnoses }, ] = useDiagnoseStateValue();

	const { id } = useParams<{ id: string }>();

	const [modalOpen, setModalOpen] = React.useState<boolean>(false);

	const [error, setError] = React.useState<string | undefined>();

	const openModal = (): void => setModalOpen(true);

	const closeModal = (): void => {
		setModalOpen(false);
		setError(undefined);
	};

	// 9.24
	const submitNewEntry = async (values: EntryFormValues) => {

		console.log('submitNewEntry', id, values);

		const { data: newEntry } = await axios.post<Patient>(
			`${apiBaseUrl}/api/patients/${id}/entries`,
			values
		);

		console.log('newEntry', newEntry);

		dispatch(setNewEntry(newEntry));

		closeModal();
	};

	React.useEffect(() => {

		console.log(id)

		const getPatient = async (id: string) => {

			try {

			const { data: patient } = await axios.get<Patient>(`${apiBaseUrl}/api/patients/${id}`);

			console.log('PatientPage', patient)

			// 9.18
			//dispatch({ type: "GET_PATIENT", payload: patient });
			dispatch(setPatientPage(patient));

			//Object.values(diagnoses).map((diagnose: Diagnosis) => console.log(diagnose.code, diagnose.name))

			} catch (e) {

				console.error(e);

			}
		}

		void getPatient(id);

	}, [id, dispatch]);

	// 9.21
	const DiagnoseCode = ({code}: any) => {

		console.log('DiagnoseCode', code);

		return (
			<>
			{ Object.values(diagnoses).map((diagnose: Diagnosis) => diagnose.code === code ? <span key={code}> {code} {diagnose.name} </span> : null) }
			</>
		);
	};

	const EmployerName : React.FC<{entry: Entry}> = ({entry}) => {

		console.log('EmployerName', entry)

		return (
			<>
				{Object.entries(entry).map(([key, value]) => (key === 'employerName') ? <span>{value}</span> : null )}
			</>
		)
	};

	const HealthCheckEntry: React.FC<{entry: Entry}> = ({entry}) => {
		return (
			<Segment raised>
				<div key={entry.id}>
					<h4>
					{entry.date} {" "} <Icon enabled name='user md' size='big'/> {" "}
					</h4>
					<div style={{color:'lightgrey', fontStyle: 'italic'}}>{entry.description}</div>
					<div>
					{
						(entry && entry.diagnosisCodes !== undefined) ? (entry.diagnosisCodes.map((code: string)  => <li key={code}><DiagnoseCode code={code} /></li>) ) : null 
					}
					</div>
					<div style={{paddingTop:10}}>{(entry.healthCheckRating === HealthCheckRating.Healthy) ? (<Icon enabled name='heart' color="green"/>) : (entry.healthCheckRating === HealthCheckRating.LowRisk) ? (<Icon enabled name='heart' color="yellow"/>) : (<Icon enabled name='heart outline'/>)}</div>
				</div>
			</Segment>
		);
	}

	const HospitalEntry: React.FC<{entry: Entry}> = ({entry}) => {
		return (
			<Segment raised>
				<div key={entry.id}>
					<h4>
					{entry.date} {" "} <Icon enabled name='hospital' size='big'/> {" "}
					</h4>
					<div style={{color:'lightgrey', fontStyle: 'italic'}}>{entry.description}</div>
					<div>
					{
						(entry && entry.diagnosisCodes !== undefined) ? (entry.diagnosisCodes.map((code: string)  => <li key={code}><DiagnoseCode code={code} /></li>) ) : null 
					}
					</div>
					<div style={{paddingTop:10}}>{(entry.healthCheckRating === HealthCheckRating.Healthy) ? (<Icon enabled name='heart' color="green"/>) : (entry.healthCheckRating === HealthCheckRating.LowRisk) ? (<Icon enabled name='heart' color="yellow"/>) : (<Icon enabled name='heart outline'/>)}</div>
				</div>
			</Segment>
		);
	}

	const OccupationalHealthcareEntry: React.FC<{entry: Entry}> = ({entry}) => {
		
		console.log('OccupationalHealthcareEntry', entry);

		/*let employerName = null;

		Object.entries(entry).map(function([key, value]) {
			
			//console.log('key', key, 'value', value);

			if (key === 'employerName') {
				employerName = value;
			}
		});

		// <span> {employerName} </span>
		*/

		return (
			<Segment raised>
				<div key={entry.id}>
					<h4>
					{entry.date} {" "} <Icon enabled name='stethoscope' size='big'/> {" "} <EmployerName entry={entry}/>
					</h4>
					<div style={{color:'lightgrey', fontStyle: 'italic'}}>{entry.description}</div>
					<div>
					{
						(entry && entry.diagnosisCodes !== undefined) ? (entry.diagnosisCodes.map((code: string)  => <li key={code}><DiagnoseCode code={code} /></li>) ) : null 
					}
					</div>
					<div style={{paddingTop:10}}>{(entry.healthCheckRating === HealthCheckRating.Healthy) ? (<Icon enabled name='heart' color="green"/>) : (entry.healthCheckRating === HealthCheckRating.LowRisk) ? (<Icon enabled name='heart' color="yellow"/>) : (entry.healthCheckRating === HealthCheckRating.HighRisk) ? (<Icon enabled name='heart outline'/>) : null }</div>
				</div>
			</Segment>
		);
	}

	// 9.22
	const EntryDetails: React.FC<{entry: Entry}> = ({entry}) => {

		console.log('EntryDetails', entry.type);

		switch (entry.type) {
			case "HealthCheck":
				return <HealthCheckEntry entry={entry}/>
			case "Hospital":
				return <HospitalEntry entry={entry}/>
			case "OccupationalHealthcare":
				return <OccupationalHealthcareEntry entry={entry}/>
			default:
				console.log('assertNever', entry);
				return assertNever(entry);
			}
		};

	// 9.20
	return (
		<div className="PatientPage">
			{Object.values(patients).map((patient: Patient) => patient.id === id ? 
				<div key={patient.id}>
					<h3>{patient.name} 
					<span>{(patient.gender === 'male') ? (<Icon enabled name='mars' size='big'/>) : (patient.gender === 'female') ? (<Icon enabled name='venus' size='big'/>) : (<Icon enabled name='genderless' size='big'/>)}</span>
					</h3>
					<div style={{fontWeight: 'bold'}}>
					ssn: {patient.ssn}
					</div>
					<div style={{fontWeight: 'bold'}}> 
					occupation: {patient.occupation}
					</div>
					<div>
					{
						(patient.entries && patient.entries.length > 0) ?
						<h4 style={{paddingTop:25}}>entries</h4> : null 
					}
					<div>
					{ 
						(patient.entries && patient.entries.length > 0) ? 
							(patient.entries.map((entry: Entry) =>
								<EntryDetails key={entry.id} entry={entry} />
							)
						) : null
					}
					</div>
					</div>
				</div> : <div></div> ) 
			}
			<div style={{paddingTop:25}}>
				<AddEntryModal
					modalOpen={modalOpen}
					onSubmit={submitNewEntry}
					error={error}
					onClose={closeModal}
				/>
				<Button onClick={() => openModal()}>Add New Entry</Button>
			</div>
		</div>
	);
};

export default PatientPage;