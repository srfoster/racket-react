#lang at-exp racket

(require "../client.rkt")

;Fix the single quotes issue.  
;Try to macroify stuff.
;Try to get rid of boilerplate compilation stuff at bottom
;Declare props like path: so we don't have to 'path:

(define-component ContinuationViewer
		  @js{var [next, setNext] = useState()} ;Can we macroify??
		  @js{var [value, setValue] = useState()} ;Can we macroify??
		  (useEffect
		    @js{
		    if(next == undefined){
		    console.log("...")
		    window.server_call("http://localhost:8081",
				       props.path,
				       {},
				       (r)=>{
				       setNext(r.next)
				       setValue(r.value)
				       }) 
		    }
		    })
		  (return 
		    (div
		      (div "Value: " @~{value})
		      (div 
			onClick: @~{()=>{
			if(next)
			window.server_call('http://localhost:8081',
					   next,
					   {},
					   (r)=>{
					   setNext(r.next)
					   setValue(r.value)
					   }) 
			}}
			"Next: "  @~{next}))))

(define-component App
		  (return
		    (div
		      (div style: @~{{padding: 10, border: '1px solid black'}}
			(ContinuationViewer 'path: "/top"))
		      (div style: @~{{padding: 10, border: '1px solid black'}}
		       (ContinuationViewer 'path: "/top")))))

(define components
  (list ContinuationViewer-component App-component))

(displayln (compile-app components))

(save-app #:to "my-spell-app/src/App.js" components)
