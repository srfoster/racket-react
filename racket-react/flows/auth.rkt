#lang web-server

(provide require-login login signup)

(require racket-react/server)

(define (is-logged-in?)
  (define auth-token (arg 'authToken))
  (and (string=? "ABCD" (~a auth-token))))

(define (jwt-for username)
  "ABCD")

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


(define dummy-creds (hash "user" "asdfasdf"))
(define (creds-correct username password)
  (and
    (hash-has-key? dummy-creds username)
    (string=? (hash-ref dummy-creds username) password)))


(define (login then)
  (define username (arg 'username))
  (define password (arg 'password))

  ; TODO: Check these... How?? 
  ; TODO: Issue JWT

  (if (creds-correct username password)
      (with-embeds
	(response/json/cors 
	  (hash 
	    'type "success"
	    'message "You logged in"
	    'authToken (jwt-for username)
	    'continue (continue-function-object (embed then))
	    )))
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

(define (continue-function-object continue-function)
  (hash
    'type "function"
    'name "???"
    'userDescription "Now that you're logged in, you can do this."
    'devDescription "Allows the user to continue with whatever they were requesting prior to being logged in"
    'function continue-function))

(define (signup)
  (with-embeds
    (response/json/cors 
      (hash 
	))))
