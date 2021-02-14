#lang at-exp racket

(require racket-react/client
	 racket-react/components/api-explorer
	 racket-react/components/auth
	 )

(define-component App
		  (return
		    (Container 
		      (LogoutButton)
		      (LoginForm 'path: "/welcome"
				 'afterLogin: 
				 @~{(response)=><APIExplorer path="/welcome"/>}
				 ;@~{(response)=><span>In!</span>}
				 ))))

(displayln (compile-app components))

(save-app)
