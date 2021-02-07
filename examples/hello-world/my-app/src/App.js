import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

window.server_call = (host,server_function,data,cb) =>{
fetch(host + server_function + "?data=" + encodeURI(JSON.stringify(data))).then((r)=>r.json())
.then((r)=>{
      cb(r)
      })
}

function NumberField (props){
  return <input type="text" onChange={(e)=>{ 
 props.onChange(+e.target.value) 
 }} />
}

function Hi (props){
  var [count, setCount] = useState(0)
var [next, setNext] = useState("")
var [mult, setMult] = useState(1)

useEffect(() => {
             if(count === 0)
             {
             console.log("INIT")
             window.server_call('http://localhost:8081',
                                "/counter",
                                {},
                                (r)=>{
                                setCount(r.value);
                                setNext(r.next);
                                })
             }
             })

return <div><NumberField onChange={setMult}></NumberField><div onClick={()=> 
 { 
 setCount('') 
 
 setTimeout(()=>{ 
             window.server_call('http://localhost:8081', 
                         next, 
                         {current: count, mult: mult}, 
                         (r)=>{ 
                         setCount(r.value); 
                         setNext(r.next); 
                         }) 
             }, 500) 
 }}>{props.prefix} {count}</div></div>
}

function TestCall (props){
  var [message, setMessage] = useState("")
var [next, setNext] = useState(undefined)
useEffect(()=>{
          if(next === undefined)
          window.server_call('http://localhost:8081',
                             "/message",
                             {},
                             (r)=>{
                             setMessage(r.value);
                             setNext(r.next);
                             })
          })

return <div onClick={()=>{ 
 if(next) 
 window.server_call('http://localhost:8081', 
                     next, 
                     {}, 
                     (r)=>{ 
                     setMessage(r.value); 
                     setNext(r.next); 
                     }) 
 } }>{message}</div>
}

function App (props){
  return <div className="App"><header className="App-header"><TestCall></TestCall><Hi prefix="A->"></Hi><Hi prefix="B->"></Hi></header></div>
}

export default App;
