#lang at-exp racket

(require "../client.rkt")

;Redo continuation viewer now that json payloads can have multiple continuations.  Make it a general JSON viewer with the added ability to call continuations and pass in values of the appropriate types (will need fancy dynamic loading -- i.e. checkboxes for booleans.  Will need to serve up meta-data with JSON responses.

;Allow nesting s-expression jsx inside at-squiggles.  Annoying to have to switch to <This><shit/></This>

;Fix the single quotes issue.  
;Try to macroify stuff.
;Try to get rid of boilerplate compilation stuff at bottom
;Declare props like path: so we don't have to 'path:


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
		  (return 
		    (div
		      @~{
		      Object.keys(response).map((k)=>{
		        return <div><Mui.Chip label={k}></Mui.Chip><span>{response[k].substring(0,10)+'...'}</span></div>				
		      })

		      }
		      )))

(define-component App
		  (return
		    (Container 'maxWidth: "sm"
		      (Paper
			(Paper style: @~{{padding: 20, margin: 10}}
			     (ContinuationViewer 'path: "/top"))
			(Paper style: @~{{padding: 20, margin: 10}}
			     (ContinuationViewer 'path: "/top"))))))

(define components
  (list ContinuationViewer-component App-component))

(displayln (compile-app components))

(save-app #:to "my-spell-app/src/App.js" components)
