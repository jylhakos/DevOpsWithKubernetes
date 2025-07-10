import React from "react";

import { Grid, Button } from "semantic-ui-react";

import { Field, Formik, Form } from "formik";

// $ npm install react-datepicker --save

// $ npm install @types/react-datepicker --save-dev

import DatePicker from "react-datepicker";

import "react-datepicker/dist/react-datepicker.css";

import { TextField, NumberField, TypeOption, SelectType } from "../AddPatientModal/FormField";

import { Entry } from "../types";

export type EntryFormValues = Omit<Entry, "id">;

interface Props {
  onSubmit: (values: EntryFormValues) => void;
  onCancel: () => void;
}

const typeOptions: TypeOption[] = [
  { value: "HealthCheck", label: "HealthCheck" },
  { value: "Hospital", label: "Hospital" },
  { value: "OccupationalHealthcare", label: "OccupationalHealthcare" }
];

// 9.24
export const AddEntryForm = ({ onSubmit, onCancel } : Props ) => {

  function getDate(): any {
    return (new Date().toJSON().split("T")[0]);
  }

  function setDate(date: any): any {
    //console.log('date', date);
    const year = String(date.getFullYear());
    //console.log('year', year);
    const month = Number(date.getMonth())+1;
    //console.log('month', month);
    const day = String(date.getDate());
    //console.log('day', day);
    const local = year + "-" + String(month) + "-" + day;
    console.log('local', local);
    return local;
  }

  return (
    <Formik
      initialValues={{
        //date: "",
        date: getDate(),
        specialist: "",
        type: "HealthCheck",
        description: ""
      }}

      onSubmit={onSubmit}

      // 9.25
      validate={values => {

        const requiredError = "Field is required";

        const errors: { [field: string]: string } = {};

        if (!values.specialist) {

          errors.specialist = requiredError;
        }

        if (!values.description) {

          errors.description = requiredError;
        }

        return errors;

      }}
    >
      {({ setFieldValue, values, isValid, dirty }) => {

        return (
          <Form className="form ui">

            <span style={{fontWeight: 'bold'}}>Date</span>

            <DatePicker
              name="date"
              dateFormat="yyyy-MM-dd"
              value={values.date}
              //selected={values.date}
              onChange={(date: Date | any | null | undefined ) => setFieldValue('date', setDate(date))}
            />

            <Field
              label="Specialist"
              placeholder="specialist"
              name="specialist"
              component={TextField}
            />

            <SelectType
              label="Type"
              name="type"
              options={typeOptions}
            />

            <Field
              label="Description"
              placeholder="description"
              name="description"
              component={TextField}
            />

            <Field
              label="HealthCheckRating"
              name="healthCheckRating"
              component={NumberField}
              min={0}
              max={3}
              //defaultValue={0}
            />

            <Grid>
              <Grid.Column floated="left" width={5}>
                <Button type="button" onClick={onCancel} color="red">
                  Cancel
                </Button>
              </Grid.Column>
              <Grid.Column floated="right" width={5}>
                <Button
                  type="submit"
                  floated="right"
                  color="green"
                  disabled={!dirty || !isValid}
                >
                  Add
                </Button>
              </Grid.Column>
            </Grid>
          </Form>
        );
      }}
    </Formik>
  );
};

export default AddEntryForm;
