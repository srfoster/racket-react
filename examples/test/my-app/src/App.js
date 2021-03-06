import logo from './logo.svg';
import './App.css';
import React, { useState, useEffect } from 'react';

import * as Mui from '@material-ui/core';
import * as I from '@material-ui/icons';





window.server_call = (host,server_function,data,cb) =>{
fetch(host + server_function + "?data=" + encodeURI(JSON.stringify({...data ,...{authToken: window.localStorage.getItem("authToken")}}))).then((r)=>r.json())
.then((r)=>{
      cb(r)
      })
}


function App (props){
  return <Mui.Container><LogoutButton></LogoutButton><LoginForm path="/welcome" afterLogin={(response)=><APIExplorer path="/welcome"/>}></LoginForm></Mui.Container>
}

function LoginForm (props){
  var [loaded, setLoaded] = useState(false)

var [loggedIn, setLoggedIn] = useState(false)

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

return localStorage.getItem("authToken") ? props.afterLogin(response) :
<Mui.Paper style={{padding: 10, margin: 10}}><LoginResponseViewer response={response} afterLogin={(response)=>{ 
 setLoggedIn(true); 
 setResponse(response) 
 }} onNextResponse={setResponse}></LoginResponseViewer></Mui.Paper>
}

function LoginResponseViewer (props){
  let thing = <span>LoginResponseViewer: error.  Report this as a bug.</span>

if(props.response.type == "error")
  thing = <ErrorResponse response={props.response}
                         onNextResponse={props.onNextResponse} />

if(props.response.type == "success"){
  thing = <SuccessResponse response={props.response}
                           afterLogin={props.afterLogin} />
                           }

return thing
}

function ErrorResponse (props){
  var [username, setUsername] = useState()

var [password, setPassword] = useState()

return <div><p>{props.response.message}</p><div><Mui.TextField label="username" onChange={(e)=>setUsername(e.target.value)}></Mui.TextField></div><div><Mui.TextField label="password" onChange={(e)=>setPassword(e.target.value)}></Mui.TextField></div><br /><Mui.Button variant="contained" color="secondary" onClick={()=>{window.server_call( 
                         "http://localhost:8081", 
                         props.response.login.function, 
                         {username: username, 
                         password: password}, 
                         (r)=>{ 
                         props.onNextResponse(r) 
                         })}}>Submit</Mui.Button></div>
}

function SuccessResponse (props){
  useEffect(()=>{
 window.localStorage.setItem("authToken", props.response.authToken)
window.server_call(
                   "http://localhost:8081",
                   props.response.continue.function,
                   {},
                   (r)=>{
                   props.afterLogin(r)
                   })

})

return <div>One moment...</div>
}

function LogoutButton (props){
  return <Mui.Button variant="contained" color="secondary" onClick={()=>{ 
 localStorage.removeItem("authToken") 
 }}>Logout</Mui.Button>
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

export default App;
