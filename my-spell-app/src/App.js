import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

window.server_call = (host,server_function,data,cb) =>{
fetch(host + server_function + "?data=" + encodeURI(JSON.stringify(data))).then((r)=>r.json())
.then((r)=>{
      cb(r)
      })
}

function ContinuationViewer (props){
  var [next, setNext] = useState()

var [value, setValue] = useState()

var [other, setOther] = useState()

useEffect(()=>{
 if(next == undefined){
console.log("...")
window.server_call("http://localhost:8081",
                   props.path,
                   {},
                   (r)=>{
                   setNext(r.next)
                   setOther(r.other)
                   setValue(r.value)
                   })
}
})

return <div><div>Value: {value}</div><div onClick={()=>{ 
 if(next) 
 window.server_call('http://localhost:8081', 
                     next, 
                     {}, 
                     (r)=>{ 
                     setNext(r.next) 
                     setOther(r.other) 
                     setValue(r.value) 
                     }) 
 }}>Next: {next}</div><div onClick={()=>{ 
 if(next) 
 window.server_call('http://localhost:8081', 
                     other, 
                     {}, 
                     (r)=>{ 
                     setNext(r.next) 
                     setOther(r.other) 
                     setValue(r.value) 
                     }) 
 }}>Other: {other}</div></div>
}

function App (props){
  return <div><div style={{padding: 10, border: '1px solid black'}}><ContinuationViewer path="/top"></ContinuationViewer></div><div style={{padding: 10, border: '1px solid black'}}><ContinuationViewer path="/top"></ContinuationViewer></div></div>
}

export default App;
