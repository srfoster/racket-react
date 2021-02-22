#lang at-exp racket

(provide LoginForm
	 LogoutButton)

(require racket-react/client)


(add-for-server-calls!
  @js{
   {authToken: window.localStorage.getItem("authToken")} 
  })

(define-component LogoutButton
		  (return
		    (Button 
		      'variant: "contained" 
		      'color: "secondary"
		      'onClick: @~{()=>{
		      localStorage.removeItem("authToken")
		      }}
		      "Logout")))

(define-component SuccessResponse
		  (useEffect
		    @js{
		        window.localStorage.setItem("authToken", props.response.authToken)
			window.server_call(
					   "http://localhost:8081",
					   props.response.continue.function,
					   {},
					   (r)=>{
					   props.afterLogin(r)
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
		      let thing = <span>LoginResponseViewer: error.  Report this as a bug.</span> 

                      if(props.response.type == "error")
		        thing = <ErrorResponse response={props.response} 
			                       onNextResponse={props.onNextResponse} />

                      if(props.response.type == "success"){
		        thing = <SuccessResponse response={props.response}
			                         afterLogin={props.afterLogin} />
						 }
		    
		      return thing
		   })

(define-component LoginForm
		  @js{var [loaded, setLoaded] = useState(false)} 
		  @js{var [loggedIn, setLoggedIn] = useState(false)} 
		  @js{var [response, setResponse] = useState({})} 

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
		    }})

		  (return
		    @js{
		    localStorage.getItem("authToken") ? props.afterLogin(response) :
		    @(Paper 'style: @~{{padding: 10, margin: 10}}
			    (LoginResponseViewer 'response: @~{response}
						 'afterLogin: @~{(response)=>{
						 setLoggedIn(true);
						 setResponse(response)
						 }}
						 'onNextResponse: @~{setResponse})

			    )
		    }))



