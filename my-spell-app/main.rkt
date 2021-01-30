#lang at-exp racket

(require "../client.rkt")

;Redo continuation viewer now that json payloads can have multiple continuations.  Make it a general JSON viewer with the added ability to call continuations and pass in values of the appropriate types (will need fancy dynamic loading -- i.e. checkboxes for booleans.  Will need to serve up meta-data with JSON responses.

; Show specially: {type: 'function'}


;Allow nesting s-expression jsx inside at-squiggles.  Annoying to have to switch to <This><shit/></This>

;Fix the single quotes issue.  
;Try to macroify stuff.
;Try to get rid of boilerplate compilation stuff at bottom
;Declare props like path: so we don't have to 'path:

(define-component FunctionViewer
		  @js{var [result, setResult] = useState()} ;Can we macroify??
		  @js{
		  const call = ()=>{
		    window.server_call("http://localhost:8081",
				       props.wrapper.function,
				       {},
				       (r)=>{
				       setResult(r)
				       }) 
		  }
		  }
		  @js{
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
		  })

(define-component ObjectExplorer
		  @js{var displayResponse = (r)=>{
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
		      return response ? <ObjectExplorer object={response} /> : "waiting..." 
		      }
		  )

(define-component App
		  (return
		    (Container 'maxWidth: "sm"
		      (Paper
			(Paper style: @~{{padding: 20, margin: 10}}
			     (ContinuationViewer 'path: "/top"))
			(Paper style: @~{{padding: 20, margin: 10}}
			     (ContinuationViewer 'path: "/top"))))))

(define components
  (list FunctionViewer-component ObjectExplorer-component ContinuationViewer-component App-component))

(displayln (compile-app components))

(save-app #:to "my-spell-app/src/App.js" components)
