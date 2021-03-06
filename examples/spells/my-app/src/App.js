import logo from './logo.svg';
import './App.css';
//import * as babel from '@babel/standalone';
import ReactDOM from 'react-dom';
import React, { useState, useEffect } from 'react';

import * as Mui from '@material-ui/core';
import * as I from '@material-ui/icons';

 import Draggable from 'react-draggable' 

import CytoscapeComponent from 'react-cytoscapejs';

import {UnControlled as CodeMirror} from 'react-codemirror2' 

require('codemirror/mode/scheme/scheme');

//Supporting dynamic component eval
//window.babel = babel
window.React = React
window.useState = useState

window.server_call = (host,server_function,data,cb) =>{
fetch(host + server_function + "?data=" + encodeURI(JSON.stringify({...data }))).then((r)=>r.json())
.then((r)=>{
      cb(r)
      })
}


function App (props){
return <Mui.Container><RuneSurface></RuneSurface><APIExplorer path="/top" domainSpecific={DomainSpecificUI}></APIExplorer></Mui.Container>
}

function DomainSpecificUI (props){
const display = (thing)=>{
  if(thing.type=="script") {
    return <div><CodeEditor script={thing.script} onChange={(editor, data, value) => { 
 console.log(thing) 
 window.server_call("http://localhost:8081", 
                     thing.editScript.function, 
                     {script: value, 
                     isPrivate: true}, 
                     (r)=>{ 
                     }) 
 
 }}></CodeEditor><ObjectExplorer object={thing}></ObjectExplorer></div>
  } else {
    return "Unknown Type: " + thing.type
  }
}

return display(props.wrapper)
}

function RuneSurface (props){
var [runes, setRunes] = useState({
 "1": {x: 0, y: 0, content: "("},
 "2": {x: 0, y: 0, content: "RUNE"},
 "3": {x: 0, y: 0, content: ")"}
 })


const compile = (runes) =>{
  var sorted = Object.values(runes).sort((a,b)=>{
    if(a.y > b.y) return 1
    if(a.y < b.y) return -1

    if(a.x > b.x) return 1
    if(a.x < b.x) return -1

    return 0
  })

  return sorted.map((r)=>r.content).join(" ")
}

return(
       <div style={{width: 500, height: 500}}>{compile(runes)}<button onClick={()=>{ 
    var newRunes = JSON.parse(JSON.stringify(runes)) 
    newRunes[""+(Object.keys(newRunes).length+1)] = {x:0, y:0, content: "NEW"} 
    setRunes(newRunes) 
 }}>Add Rune</button>{Object.keys(runes).map((d)=>
                             <Rune id={d}
                                   content={runes[d].content}
                                   x={runes[d].x}
                                   y={runes[d].y}
                                   compile={(x,y,content)=>{
                                    var newRunes = JSON.parse(JSON.stringify(runes))
                                    newRunes[d].x = x
                                    newRunes[d].y = y
                                    setRunes(newRunes)
                                   }}
                                   />
                             )}</div>
       )
}

function Rune (props){
var [x, setX] = useState(props.x)

var [y, setY] = useState(props.x)

var [width, setWidth] = useState(50)

var [height, setHeight] = useState(50)

const round = (n)=>{
return Math.floor(n/25) * 25
}

return <Draggable onStop={(e,d)=>{ 
 //Hmmm.  Parent here is brittle 
 var t = e.target.parentElement.style.transform; 
 if(t.match(/translate/)){ 
 var x = Number(t.match(/[0-9]*px/g)[0].replace("px","")); 
 var y = Number(t.match(/[0-9]*px/g)[1].replace("px","")); 
 setX(x); setY(y); 
 props.compile(x,y,props.children)} 
 }} grid={[25,25]}><Mui.Card style={{cursor: "pointer", position: "absolute", width: width, height: height}}><Mui.CardContent style={{textOverflow: "ellipsis", whiteSpace: "nowrap", display: "block", overflow: "hidden"}}>{props.content}</Mui.CardContent></Mui.Card></Draggable>
}

function APIExplorer (props){
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

return response ? <ObjectExplorer object={response} onApiCall={setResponse} domainSpecific={props.domainSpecific}></ObjectExplorer> : "waiting on response..."
}

function ObjectExplorer (props){
var displayResponse = (r)=>{
  if(r.type){
    if(r.type == "function"){
      return <FunctionViewer wrapper={r} onCall={props.onApiCall}>domainSpecific{props.domainSpecific}</FunctionViewer>
    }
    if(r.type == "argument"){
      return "Arg"
    }
    let DS = props.domainSpecific
    if(DS) return <DS wrapper={r} />
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

  if(typeof(r) == "number"){
    return ""+r
  }

  return typeof(r)
}

return displayResponse(props.object)
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
                     if(!props.onCall)
                       setResult(r);
                     else
                       props.onCall(r);
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
                 var newArgs = {...outgoingArgs} 
                 newArgs[arg] = s 
                 setOutgoingArgs(newArgs); 
                 } 
                 )}</Mui.TableCell></Mui.TableRow>
     )}</Mui.TableBody></Mui.TableContainer>
: ""
}{result ? <ObjectExplorer object={result} domainSpecific={props.domainSpecific}></ObjectExplorer> : "" }</Mui.CardContent></Mui.Card>
: <Mui.Chip color="secondary" label={"Not a function: "+ JSON.stringify(props.wrapper)}></Mui.Chip>
}

function BasicBooleanEditor (props){
var [checked, setChecked] = useState(props.value)

return <Mui.Switch checked={checked} onChange={(e)=>{setChecked(!checked);props.onChange(!checked)}}></Mui.Switch>
}

function BasicStringEditor (props){
var [value, setValue] = useState(props.value)

return <Mui.TextField onChange={(e) => {setValue(e.target.value); props.onChange(e.target.value)}} label={props.label} value={value} variant="outlined"></Mui.TextField>
}

function CodeEditor (props){
var [value, setValue] = useState(props.script.script)

return <div>

<CodeMirror
value={props.script}
options={{
mode: 'scheme',
theme: 'material',
lineNumbers: true
}}
onChange={props.onChange}
/>

</div>
}

export default App;
