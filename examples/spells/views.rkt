#lang at-exp racket

(require racket-react/client
	 racket-react/components/code-editor)

;Factor out more here

(define-component DomainSpecificUI
		  @js{
                  const display = (thing)=>{
		    if(thing.type=="script") {
                      return @(CodeEditor 'script: @~{thing})
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

			@js{{result ? @(ObjectExplorer 'object: @~{result}) : "" }}

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

(displayln (compile-app components))

(save-app #:to "my-spell-app/src/App.js")

