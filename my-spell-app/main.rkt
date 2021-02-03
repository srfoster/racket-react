#lang at-exp racket

(require "../client.rkt")

;Redo continuation viewer now that json payloads can have multiple continuations.  Make it a general JSON viewer with the added ability to call continuations and pass in values of the appropriate types (will need fancy dynamic loading -- i.e. checkboxes for booleans.  Will need to serve up meta-data with JSON responses.

; Show specially: {type: 'function'}

;Argument types, generate
;   components for different kinds of input, strings, integers (ranges?), booleans,  
;   other types
;   Auto generate the right widget
;
;   Support default values, optional values, 

; Make dynamic editors take current value.  How to pass along current value in json??


;Widget "tree" is a bit hard to read.
;  How to show cyclical workflow? Get value and (continually) edit that value

;Hook widgets up to each other.  Build your own workflows...



;Factor out components into libraries
;Try to macroify stuff.
;Try to get rid of boilerplate compilation stuff at bottom
;Declare props like path: so we don't have to 'path:

;Code has the power to make things that are pretty bad, that work just fine

(define (useState id [input ""])
  @js{var [@id, set@(string-titlecase (substring (~a id) 0 1))@(substring (~a id) 1 )] = useState(@input)} ;Can we macroify??
  )

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
		  })
#;
		  (
			   TextField 
			    'onChange: @~{(e) => props.onChange(e.target.value)} 
			    'label: @~{props.label} 'variant: "outlined")

(define-component FunctionViewer
		  (useState 'result)
		  (useState 'outgoingArgs @js{{}})
		  @js{
		  const call = ()=>{
		    window.server_call("http://localhost:8081",
				       props.wrapper.function,
				       outgoingArgs,
				       (r)=>{
				       console.log(r)
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
						     outgoingArgs[arg] = s
						     setOutgoingArgs(outgoingArgs);
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
		      (Paper
			(Paper style: @~{{padding: 20, margin: 10}}
			     (ContinuationViewer 'path: "/top"))
			(Paper style: @~{{padding: 20, margin: 10}}
			     (ContinuationViewer 'path: "/top"))))))

(define components
  (list BasicBooleanEditor-component BasicStringEditor-component FunctionViewer-component ObjectExplorer-component ContinuationViewer-component App-component))

(displayln (compile-app components))

(save-app #:to "my-spell-app/src/App.js" components)


;(displayln @js{@(ObjectExplorer 'object: @~{response})})




