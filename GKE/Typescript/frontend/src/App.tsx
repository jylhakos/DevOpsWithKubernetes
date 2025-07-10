import React from "react";
import axios from "axios";
import { BrowserRouter as Router, Route, Link, Switch } from "react-router-dom";
import { Button, Divider, Header, Container } from "semantic-ui-react";

import { apiBaseUrl } from "./constants";

import { Patient, Diagnosis } from "./types";

import { usePatientStateValue, setPatientList } from "./state";
import { useDiagnoseStateValue, setDiagnosisList } from "./state";

import PatientListPage from "./PatientListPage";

// 9.17
import PatientPage from "./components/PatientPage";

const App = () => {

  const [, dispatch] = usePatientStateValue();

  const [, dispatch2] = useDiagnoseStateValue();

  React.useEffect(() => {

    void axios.get<void>(`${apiBaseUrl}/ping`);

    const fetchPatientList = async () => {

      try {

        const { data: patientListFromApi } = await axios.get<Patient[]>(
          `${apiBaseUrl}/api/patients`
        );

        console.log('fetchPatientList', patientListFromApi)
        
        // 9.18
        //dispatch({ type: "SET_PATIENT_LIST", payload: patientListFromApi });
        dispatch(setPatientList(patientListFromApi));

      } catch (e) {
        console.error(e);
      }
    };
    void fetchPatientList();
  }, [dispatch]);

  React.useEffect(() => {

    const fetchDiagnosesList = async () => {

      try {

        const { data: diagnosesListFromApi } = await axios.get<Diagnosis[]>(
          `${apiBaseUrl}/api/diagnoses`
        );

        console.log('fetchDiagnosesList', diagnosesListFromApi)
        
        // 9.21
        dispatch2(setDiagnosisList(diagnosesListFromApi));

      } catch (e) {
        console.error(e);
      }
    };
    void fetchDiagnosesList();
  }, [dispatch]);


  return (
    <div className="App">
      <Router>
        <Container>
          <Header as="h1">Patientor</Header>
          <Button as={Link} to="/" primary>
            Home
          </Button>
          <Divider hidden />
          <Switch>
            <Route path="/patients/:id">
              <PatientPage />
            </Route>
            <Route path="/">
              <PatientListPage />
            </Route>
          </Switch>
        </Container>
        
      </Router>
    </div>
  );
};

export default App;
