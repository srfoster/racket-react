#lang at-exp web-server

(provide start-server)

(require "../server.rkt")

;  The client can decide what to call based on its own logic, and/or the meta-data associated with the continuations...

(define (load-script)
  (with-embeds
    (response/json/cors 
      (hash 
	'script "(hello-world)"
	'isPrivate #t
	'edit-script (edit-script-object (embed edit-script))
	))))

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

(define (edit-script)
  (define new-script (arg 'script))
  (define new-is-private (arg 'isPrivate))

  (with-embeds
    (response/json/cors 
      (hash 
	'script new-script
	'isPrivate new-is-private
	'edit-script (edit-script-object (embed edit-script))
	))))

(define (edit-script-object function-embed)
  ;Defines the shape of a function json object
  (hash 
    'type "function"
    'name "edit-script"
    'arguments (hash 'script "string" 
		     'isPrivate "boolean")
    'userDescription "Sets your most recently edited script to the given 'script value."
    'devDescription "Sets the logged in user's current script to the given 'script value."
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
