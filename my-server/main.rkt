#lang at-exp web-server

(require "../server.rkt")

(define-values (do-routing url)
  (dispatch-rules
    [("message")
     (lambda (r) 
       (send/suspend/dispatch/json-continuation 
	 (thunk 
	   (response/json/cors 
	     (hash 'next #f
		   'value "End of the story")))
	 "Hello World"))]
    [("counter") ;Gets a new counter continuation.  
     (lambda (r) (show-counter 1))]))

(define (start-server)
  (serve/servlet (start do-routing)
		 #:port 8081
		 #:servlet-regexp #rx""
		 #:launch-browser? #f
		 #:stateless? #t))

(define (show-counter n)
  (define (next-number-handler) ; I guess this is the shape of json-continuable functions: No params; uses current-request-args
    (show-counter (+ n (arg 'mult))))

  (send/suspend/dispatch (json-continuation next-number-handler n)))

(start-server)
