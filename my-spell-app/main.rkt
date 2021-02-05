#lang at-exp racket

(require "../client.rkt")

;Factor out css, abstract away the code mirror imports.  Make
; this something I can reuse across react projects

;Argument types, generate
;   components for different kinds of input, strings, integers (ranges?), booleans,  
;   other types

;Widget "tree" is a bit hard to read.
;  How to show cyclical workflow? Get value and (continually) edit that value

;Hook widgets up to each other.  Build your own workflows...


;Factor out components into libraries
;Try to macroify stuff.
;Try to get rid of boilerplate compilation stuff at bottom
;Declare props like path: so we don't have to 'path:

;Code has the power to make things that are pretty bad, that work just fine

(add-import
  @js{
  require('codemirror/mode/scheme/scheme');
  })
(add-import
  @js{import {UnControlled as CodeMirror} from 'react-codemirror2' }
  )
(define-component ScriptEditor
		  @(useState 'value @js{props.script.script})
		  @js{
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
		  })

(define-component DomainSpecificUI
		  @js{
                  const display = (thing)=>{
		    if(thing.type=="script") {
                      return @(ScriptEditor 'script: @~{thing})
		    } else {
                      return "Unknown Type: " + thing.type
		    }
		  }
		  }
		  @js{
		  return display(props.wrapper) 
		  })



(define-component BasicStringEditor
		  (useState 'value @js{props.value})
		  @js{
		  return @(TextField 
			    'onChange: @~{(e) => {setValue(e.target.value); props.onChange(e.target.value)}} 
			    'label: @~{props.label} 
			    'value: @~{value} 
			    'variant: "outlined"
			    )
		  }
		  )

(define-component BasicBooleanEditor
		  (useState 'checked @js{props.value})
		  @js{
		  return @(Switch
		    'checked: @~{checked}
		    'onChange: @~{(e)=>{setChecked(!checked);props.onChange(!checked)}}) 
		  }
		  )

(define-component FunctionViewer
		  (useState 'result)
		  (useState 'outgoingArgs @js{{}})
		  @js{
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
		  }

		  @js{

		  const editorForType = (t, onChange) => {
		    if(t.argumentType ==="string")
		    return @(BasicStringEditor 
			      'value: @~{t.defaultValue}
			      'label: @~{t.argumentType}
			      'onChange: @~{onChange}) 

		    if(t.argumentType ==="boolean")
		    return @(BasicBooleanEditor 
			      'value: @~{t.defaultValue}
			      'label: @~{t.argumentType}
			      'onChange: @~{onChange})

		    return @(div "What's this??")
		  }
		  }

		  @js{
		   return props.wrapper.type == "function" ? 
		   @(Card

		      (CardContent
			(Typography 
			  'component: "p" 'variant: "h5"
			  "function: "
			  (Chip style: @~{{marginLeft: 5}}
				'label: @~{props.wrapper.name}))

			(List
			  (ListItem
			    (ListItemIcon
			      (PersonIcon 'fontSize: "small"))
			    (ListItemText
			      @~{props.wrapper.userDescription}))

			  (ListItem
			    (ListItemIcon
			      (CodeIcon 'fontSize: "small"))
			    (ListItemText
			      @~{props.wrapper.devDescription})))

			(Button 'onClick: @~{call} 'color: "primary" "Call")

			@js{
			{
			props.wrapper.arguments ? 
			@(TableContainer
			   (TableBody
			   @js{
			   {
				Object.keys(props.wrapper.arguments).map((arg)=>
				@(TableRow
				 (TableCell
				    (Chip 'label: @~{arg}) 
				      
				   )
				 @(TableCell
				   @~{editorForType(props.wrapper.arguments[arg],
						     (s)=>{
						     console.log(s)
						     var newArgs = {...outgoingArgs}
						     newArgs[arg] = s
						     setOutgoingArgs(newArgs);
						     }
						     )}
				   )
				  )
				)}}) )
			: ""
			}}



			;JSX lingers.  Can't ref ObjectExplorer component here
			@~{result ? <ObjectExplorer object={result}/> : "" }

			))
		   : @(Chip 'color: "secondary" 'label: @~{"Not a function: "+ JSON.stringify(props.wrapper)}) 
		  })

(define-component ObjectExplorer
		  @js{var displayResponse = (r)=>{
		    if(r.type){
		      if(r.type == "function"){
		        return @(FunctionViewer 'wrapper: @~{r})
		      }
		      if(r.type == "argument"){
		        return "Arg"
		      }
		      return @(DomainSpecificUI 'wrapper: @~{r})
		    }

		    if(typeof(r) == "object"){
		      return Object.keys(r).map((k)=>{
		        return @(List
				   (ListItem
				     (ListItemIcon (Chip 'label: @~{k}))
				     (ListItemText
				       (Box style: @~{{margin: 5, padding: 5}} 
					    @~{displayResponse(r[k])}))))
		      })
		    } 

		    if(typeof(r) == "string"){
		      return "\"" + r + "\""
		    }

		    if(typeof(r) == "boolean"){
		      return ""+r 
		    }

		    return typeof(r) 
		  }}

		  @js{
		  return displayResponse(props.object)
		  }
		  )


(define-component ContinuationViewer
		  @js{var [loaded, setLoaded] = useState(false)} ;Can we macroify??
		  @js{var [response, setResponse] = useState({})} ;Can we macroify??

		  (useEffect
		    @js{
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
		  @js{
		      return response ? @(ObjectExplorer 'object: @~{response}) : "waiting on response..." 
		      }
		  )

(define-component App
		  (return
		    (Container 
		      (ContinuationViewer 'path: "/top")
		      )))

(define components
  (list ScriptEditor-component DomainSpecificUI-component BasicBooleanEditor-component BasicStringEditor-component FunctionViewer-component ObjectExplorer-component ContinuationViewer-component App-component))

(displayln (compile-app components))

(save-app #:to "my-spell-app/src/App.js" components)


;(displayln @js{@(ObjectExplorer 'object: @~{response})})




