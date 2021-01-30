import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

import * as Mui from '@material-ui/core';
import * as I from '@material-ui/icons';


window.server_call = (host,server_function,data,cb) =>{
fetch(host + server_function + "?data=" + encodeURI(JSON.stringify(data))).then((r)=>r.json())
.then((r)=>{
      cb(r)
      })
}

function FunctionViewer (props){
  var [result, setResult] = useState()

const call = ()=>{
  window.server_call("http://localhost:8081",
                     props.wrapper.function,
                     {},
                     (r)=>{
                     setResult(r)
                     })
}

console.log(props.wrapper)
 return props.wrapper.type == "function" ?
 <Mui.Card>

 <Mui.CardContent>
 <Mui.Typography component="p" variant="h5">
 function
 <Mui.Chip style={{marginLeft: 5}} label={props.wrapper.name}>
 </Mui.Chip>
 </Mui.Typography>

 <Mui.List>

 <Mui.ListItem>
 <Mui.ListItemIcon>
 <I.Person fontSize="small" />
 </Mui.ListItemIcon>
 <Mui.ListItemText>
 {props.wrapper.userDescription}
 </Mui.ListItemText>
 </Mui.ListItem>

 <Mui.ListItem>
 <Mui.ListItemIcon>
 <I.Code fontSize="small" />
 </Mui.ListItemIcon>
 <Mui.ListItemText>
 {props.wrapper.devDescription}
 </Mui.ListItemText>
 </Mui.ListItem>

 </Mui.List>


 <Mui.Button onClick={call} color="primary">Call</Mui.Button>

 {result ? <ObjectExplorer object={result}></ObjectExplorer> : "" }

 </Mui.CardContent>
 </Mui.Card>
 : <Mui.Chip color="secondary" label={"Not a function: "+ JSON.stringify(props.wrapper)}></Mui.Chip>
}

function ObjectExplorer (props){
  var displayResponse = (r)=>{
  if(r.type){
    if(r.type == "function"){
      return <FunctionViewer wrapper={r}></FunctionViewer>
    }
  }

  if(typeof(r) == "object"){
    return Object.keys(r).map((k)=>{
      return (<Mui.List>
        <Mui.ListItem>
        <Mui.ListItemIcon>
          <Mui.Chip label={k}></Mui.Chip>
        </Mui.ListItemIcon>
        <Mui.ListItemText>
          <Mui.Paper style={{margin: 5}}>{displayResponse(r[k])}</Mui.Paper>
        </Mui.ListItemText>
        </Mui.ListItem>
      </Mui.List>)
    })
  }

  if(typeof(r) == "string"){
    return "String: " + r
  }

  return typeof(r)
}

return displayResponse(props.object)
}

function ContinuationViewer (props){
  var [loaded, setLoaded] = useState(false)

var [response, setResponse] = useState({})

useEffect(()=>{
 if(!loaded){
window.server_call("http://localhost:8081",
                   props.path,
                   {},
                   (r)=>{
                   setResponse(r)
                   })
setLoaded(true)
}
})

return response ? <ObjectExplorer object={response} /> : "waiting..."
}

function App (props){
  return <Mui.Container maxWidth="sm"><Mui.Paper><Mui.Paper style={{padding: 20, margin: 10}}><ContinuationViewer path="/top"></ContinuationViewer></Mui.Paper><Mui.Paper style={{padding: 20, margin: 10}}><ContinuationViewer path="/top"></ContinuationViewer></Mui.Paper></Mui.Paper></Mui.Container>
}

export default App;
