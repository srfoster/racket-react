#lang at-exp racket

(require racket-react/client
	 racket-react/components/api-explorer
	 racket-react/components/auth
	 )

(define-component App
		  (return
		    (Container 
		      (LoginForm 'path: "/welcome"

				 ;afterLogin: ApiExplorer...
				 )

		      #;
		      (APIExplorer 'path: "/welcome"))))

(displayln (compile-app components))

(save-app)
