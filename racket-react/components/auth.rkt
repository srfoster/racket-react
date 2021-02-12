#lang at-exp racket

(provide LoginForm)

(require racket-react/client)


(add-for-server-calls!
  @js{
   {authToken: window.localStorage.getItem("authToken")} 
  })

(define-component SuccessResponse
		  (useEffect
		    @js{
			window.server_call(
					   "http://localhost:8081",
					   props.response.continue.function,
					   {},
					   (r)=>{
					   props.onNextResponse(r)
					   })

		    })
		  (return
		    (div
		      "One moment..."
		      )))

(define-component ErrorResponse
		  @js{var [username, setUsername] = useState()} 
		  @js{var [password, setPassword] = useState()} 
		  (return
		    (div
		      (p @~{props.response.message})
		      (div
			(TextField 'label: "username"
				   'onChange: @~{(e)=>setUsername(e.target.value)}
				   ))
		      (div
			(TextField 'label: "password"
				   'onChange: @~{(e)=>setPassword(e.target.value)}
				   ))
		      (br)
		      (Button 
			'variant: "contained" 
			'color: "secondary"
			'onClick: @~{()=>{window.server_call(
							    "http://localhost:8081",
							    props.response.login.function,
							    {username: username,
							    password: password},
							    (r)=>{
							    props.onNextResponse(r)
							    })}}
			"Submit")
		   )))

(define-component LoginResponseViewer
		  @js{
		      let thing = <ObjectExplorer object={props.response} />

                      if(props.response.type == "error")
		        thing = <ErrorResponse response={props.response} 
			                       onNextResponse={props.onNextResponse} />

                      if(props.response.type == "success")
		        thing = <SuccessResponse response={props.response} 
			                         onNextResponse={props.onNextResponse} />
		    
		      return thing
		   })

(define-component LoginForm
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
		    (Paper 'style: @~{{padding: 10, margin: 10}}
		      "Login..."
		      (LoginResponseViewer 'response: @~{response}
					   'onNextResponse: @~{setResponse}))))
