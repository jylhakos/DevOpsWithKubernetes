import React, { Component } from 'react'
import axios from 'axios'
import './App.css'
import { Icon, Input, Header, Image, Segment } from 'semantic-ui-react'

export default class App extends Component {
  constructor() {
    super()

    this.state = {
      selectedFile: null,
      fileUrl: '',
      mopoChance: undefined
    }
  }

  fileChangedHandler = (event) => {
    this.setState({ selectedFile: event.target.files[0], fileUrl: URL.createObjectURL(event.target.files[0]) })
  }

  uploadHandler = () => {
    if (!this.state.selectedFile) {
      return
    }
    const formData = new FormData()
    formData.append('img', this.state.selectedFile, this.state.selectedFile.name)
    axios({
      method: 'post',
      url: 'http://localhost:5000/kurkkuvaimopo',
      data: formData,
      config: {
        headers: [
          { 'Content-Type': 'multipart/form-data' },
          { 'Access-Control-Allow-Origin': '*' }]
      }
    })
      .then((response) => {
        this.setState({ mopoChance: response.data })
      }
      )
      .catch(function (response) {
        //handle error
        console.log(response);
      })
  }

  render() {
    return (
      <Segment style={{
        width: '50%', margin: 'auto', padding: '10px'
      }}>
        <Header style={{ width: '50%', margin: 'auto', textAlign: 'center' }}>Is it a Cucumber or a Moped?</Header>
        <div style={{ width: '50%', margin: 'auto' }}>
          {this.state.fileUrl ?
            <Image src={this.state.fileUrl} />
            :
            <Image src={'https://react.semantic-ui.com/images/wireframe/image.png'} />
          }
          <span>
            <Input
              type="file"
              onChange={this.fileChangedHandler}
              icon={<Icon name='upload' inverted circular link onClick={this.uploadHandler} disabled={!this.state.selectedFile} />} />
          </span>
          {this.state.mopoChance ? this.state.mopoChance >= 0.5 ?
            <h1>{(this.state.mopoChance * 100).toFixed(2)}% sure this is a moped</h1> :
            <h1>{((1 - this.state.mopoChance) * 100).toFixed(2)}% sure this is a cucumber</h1>
            : ''}</div>
          <hr/>
          <p>This model can be pretty stupid, especially if you get unlucky with the training.
            Don't worry if you get results that don't make sense, the important thing is that you get something. 
            Feel free to try to re-train to maybe get better results =). 
            P.S. this is not the way to operate models in production, if you want more information on how to do this properly see <a href="https://cloud.google.com/architecture/mlops-continuous-delivery-and-automation-pipelines-in-machine-learning">here.</a></p>
      </Segment>
      
    )
  }
}