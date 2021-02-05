import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

import * as Mui from '@material-ui/core';
import * as I from '@material-ui/icons';

import {UnControlled as CodeMirror} from 'react-codemirror2' 

require('codemirror/mode/scheme/scheme');

window.server_call = (host,server_function,data,cb) =>{
fetch(host + server_function + "?data=" + encodeURI(JSON.stringify(data))).then((r)=>r.json())
.then((r)=>{
      cb(r)
      })
}


function ScriptEditor (props){
  var [value, setValue] = useState(props.script.script)

return <div>

<CodeMirror
value='(define x 2)'
options={{
mode: 'scheme',
theme: 'material',
lineNumbers: true
}}
onChange={(editor, data, value) => {
  window.server_call("http://localhost:8081",
                     props.script.editScript.function,
                     {script: value,
                     isPrivate: true},
                     (r)=>{
                     setValue(r.script)
                     })

}}
/>

</div>
}

function DomainSpecificUI (props){
  const display = (thing)=>{
  if(thing.type=="script") {
    return <ScriptEditor script={thing}></ScriptEditor>
  } else {
    return "Unknown Type: " + thing.type
  }
}

return display(props.wrapper)
}

function BasicBooleanEditor (props){
  var [checked, setChecked] = useState(props.value)

return <Mui.Switch checked={checked} onChange={(e)=>{setChecked(!checked);props.onChange(!checked)}}></Mui.Switch>
}

function BasicStringEditor (props){
  var [value, setValue] = useState(props.value)

return <Mui.TextField onChange={(e) => {setValue(e.target.value); props.onChange(e.target.value)}} label={props.label} value={value} variant="outlined"></Mui.TextField>
}

function FunctionViewer (props){
  var [result, setResult] = useState()

var [outgoingArgs, setOutgoingArgs] = useState({})

const call = ()=>{
  Object.keys(props.wrapper.arguments || {}).map((k)=>{
    let defaultValue = props.wrapper.arguments[k].defaultValue;
    if(defaultValue && outgoingArgs[k] === undefined)
      outgoingArgs[k] = defaultValue
  })

  window.server_call("http://localhost:8081",
                     props.wrapper.function,
                     outgoingArgs,
                     (r)=>{
                     setResult(r)
                     })
}


const editorForType = (t, onChange) => {
  if(t.argumentType ==="string")
  return <BasicStringEditor value={t.defaultValue} label={t.argumentType} onChange={onChange}></BasicStringEditor>

  if(t.argumentType ==="boolean")
  return <BasicBooleanEditor value={t.defaultValue} label={t.argumentType} onChange={onChange}></BasicBooleanEditor>

  return <div>What's this??</div>
}

return props.wrapper.type == "function" ?
<Mui.Card><Mui.CardContent><Mui.Typography component="p" variant="h5">function: <Mui.Chip style={{marginLeft: 5}} label={props.wrapper.name}></Mui.Chip></Mui.Typography><Mui.List><Mui.ListItem><Mui.ListItemIcon><I.Person fontSize="small"></I.Person></Mui.ListItemIcon><Mui.ListItemText>{props.wrapper.userDescription}</Mui.ListItemText></Mui.ListItem><Mui.ListItem><Mui.ListItemIcon><I.Code fontSize="small"></I.Code></Mui.ListItemIcon><Mui.ListItemText>{props.wrapper.devDescription}</Mui.ListItemText></Mui.ListItem></Mui.List><Mui.Button onClick={call} color="primary">Call</Mui.Button>{
props.wrapper.arguments ?
<Mui.TableContainer><Mui.TableBody>{
     Object.keys(props.wrapper.arguments).map((arg)=>
     <Mui.TableRow><Mui.TableCell><Mui.Chip label={arg}></Mui.Chip></Mui.TableCell><Mui.TableCell>{editorForType(props.wrapper.arguments[arg], 
                 (s)=>{ 
                 console.log(s) 
                 var newArgs = {...outgoingArgs} 
                 newArgs[arg] = s 
                 setOutgoingArgs(newArgs); 
                 } 
                 )}</Mui.TableCell></Mui.TableRow>
     )}</Mui.TableBody></Mui.TableContainer>
: ""
}{result ? <ObjectExplorer object={result}/> : "" }</Mui.CardContent></Mui.Card>
: <Mui.Chip color="secondary" label={"Not a function: "+ JSON.stringify(props.wrapper)}></Mui.Chip>
}

function ObjectExplorer (props){
  var displayResponse = (r)=>{
  if(r.type){
    if(r.type == "function"){
      return <FunctionViewer wrapper={r}></FunctionViewer>
    }
    if(r.type == "argument"){
      return "Arg"
    }
    return <DomainSpecificUI wrapper={r}></DomainSpecificUI>
  }

  if(typeof(r) == "object"){
    return Object.keys(r).map((k)=>{
      return <Mui.List><Mui.ListItem><Mui.ListItemIcon><Mui.Chip label={k}></Mui.Chip></Mui.ListItemIcon><Mui.ListItemText><Mui.Box style={{margin: 5, padding: 5}}>{displayResponse(r[k])}</Mui.Box></Mui.ListItemText></Mui.ListItem></Mui.List>
    })
  }

  if(typeof(r) == "string"){
    return "\"" + r + "\""
  }

  if(typeof(r) == "boolean"){
    return ""+r
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

return response ? <ObjectExplorer object={response}></ObjectExplorer> : "waiting on response..."
}

function App (props){
  return <Mui.Container><ContinuationViewer path="/top"></ContinuationViewer></Mui.Container>
}

export default App;
