#lang at-exp web-server

(provide start-server)

(require "../server.rkt" json)

;  The client can decide what to call based on its own logic, and/or the meta-data associated with the continuations...

(define (load-script)
  (with-embeds
    (response/json/cors 
      (hash 
	'script "(hello-world)"
	'isPrivate #t
	'edit-script (edit-script-object 
		       #:script "(hello-world)"
		       #:isPrivate #t
		       (embed edit-script))
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
	'edit-script (edit-script-object 
		       #:script new-script
		       #:isPrivate new-is-private
		       (embed edit-script))
	))))

(define (edit-script-object function-embed
			    ;Params are for when a function takes arguments
			    ;  that have "current values" -->
			    ;Meaning that passing in the same values twice in a row
			    ;  should not change the world:
			    ;Pass in the same script and isPrivate variable, then
			    ;  the script shouldn't change
			    ;(Not all functions will have side effects, so won't always use)
			    #:script [script (json-null)]
			    #:isPrivate [isPrivate (json-null)])
  ;Defines the shape of a function json object
  (hash 
    'type "function"
    'name "edit-script"
    'arguments (hash 'script (hash 'type "argument" 'argumentType "string"
				   'defaultValue script)
		     'isPrivate (hash 'type "argument" 'argumentType "boolean"
				      'defaultValue isPrivate))
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
