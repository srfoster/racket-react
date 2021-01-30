#lang at-exp web-server

(provide start-server)

(require "../server.rkt")

;  The client can decide what to call based on its own logic, and/or the meta-data associated with the continuations...

(define (load-script)
  (with-embeds
    (response/json/cors 
      (hash 
	'script "(hello-world)"))))

(define (load-script-object function-embed)
  ;Defines the shape of a function json object
  (hash 
    'type "function"
    'name "load-script"
    ;TODO: Can describe input to function

    ;Save time: Build front end for users while building dev api docs
    'userDescription "Loads your most recently edited script so you can keep editing it."
    'devDescription "Loads the logged in user's current script from the database."
    'function function-embed))

(define (welcome)
  (with-embeds
    (response/json/cors 
      (hash 
	'welcome-msg "Welcome"
        'load-script (load-script-object
		       (embed load-script))
	))))

(define-values (do-routing url)
  (dispatch-rules
    [("top")
     (lambda (r) 
       (welcome))]))

(define (start-server)
  (serve/servlet (start do-routing)
		 #:port 8081
		 #:servlet-regexp #rx""
		 #:launch-browser? #f
		 #:stateless? #t))
