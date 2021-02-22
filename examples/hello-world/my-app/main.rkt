#lang at-exp racket

(require "../client.rkt")

(define-component 
  TestCall
  @js{
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

  @(return 
     (div 
       onClick: @~{
       ()=>{
       if(next)
       window.server_call('http://localhost:8081',
			  next,
			  {},
			  (r)=>{
			  setMessage(r.value);
			  setNext(r.next);
			  })
       } }
       @~{message}))})

(define-component 
  NumberField 
  (return 
    (input type: "text"
	   'onChange:
	   @~{
	   (e)=>{
	   props.onChange(+e.target.value)
	   }})))

(define-component 
  Hi 

  @js{
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

  @(return 
     (div  
       (NumberField 'onChange: @~{setMult})
       (div onClick: @~{()=>
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
	    }}
	    @~{props.prefix} " "
	    @~{count})))
  })


(define-component
  App
  (return
    (div class: "App"
	 (header class: "App-header"
		 (TestCall)
		 (Hi 'prefix: "A->")
		 (Hi 'prefix: "B->")))))

(define components
  (list NumberField-component Hi-component TestCall-component App-component))

(displayln (compile-app components))

(save-app #:to "my-app/src/App.js" components)
