#lang web-server

(provide require-login login signup)

(require racket-react/server)

(define (is-logged-in?)
  #f)

(define (require-login then)
  (if (is-logged-in?)
      (then)
      (with-embeds
	(response/json/cors 
	  (hash 
	    'type "error"
	    'message "You are not logged in"
	    'login (login-function-object 
		     (embed (curry login then))) 
	    )))))

(define (creds-correct username password)
  #f
  )

(define (login then)
  (define username (arg 'username))
  (define password (arg 'password))

  ; TODO: Check these... How?? 
  ; TODO: Issue JWT

  (if (creds-correct username password)
      (then)
      (with-embeds
	(response/json/cors 
	  (hash 
	    'type "error"
	    'message "Creds did not match"
	    'login (login-function-object 
		     (embed (curry login then))))))))


(define (login-function-object login-function)
  (hash
    'type "function"
    'name "login"
    'arguments 
    (hash 'username (hash 'type "argument" 
			  'argumentType "string")
	  'password (hash 'type "argument" 
			  'argumentType "string"))

    'userDescription "Logs you in"
    'devDescription "Checks the provided username and password against server-side credentials"
    'function login-function))

(define (signup)
  (with-embeds
    (response/json/cors 
      (hash 
	))))
