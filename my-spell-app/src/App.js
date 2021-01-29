import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

import * as Mui from '@material-ui/core';

window.server_call = (host,server_function,data,cb) =>{
fetch(host + server_function + "?data=" + encodeURI(JSON.stringify(data))).then((r)=>r.json())
.then((r)=>{
      cb(r)
      })
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

return <div>{Object.keys(response).map((k)=>{ 
    return <div><Mui.Chip label={k}></Mui.Chip><span>{response[k].substring(0,10)+'...'}</span></div> 
 }) 
}</div>
}

function App (props){
  return <Mui.Container maxWidth="sm"><Mui.Paper><Mui.Paper style={{padding: 20, margin: 10}}><ContinuationViewer path="/top"></ContinuationViewer></Mui.Paper><Mui.Paper style={{padding: 20, margin: 10}}><ContinuationViewer path="/top"></ContinuationViewer></Mui.Paper></Mui.Paper></Mui.Container>
}

export default App;
