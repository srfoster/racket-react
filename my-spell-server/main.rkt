#lang at-exp web-server

(provide start-server)

(require "../server.rkt")

;Hmmm.  Top-alt might be preferable.
;  Maybe we just return json objects but with continuations serialized into them.
;  The client can decide what to call based on its own logic, and/or the meta-data associated with the continuations...
;  Just clean up the send/suspend/dispatch + lambda + embed/url + lambda + with-current-request-args...

(define top-alt
  (thunk 
    (send/suspend/dispatch
      (lambda (embed/url)
	(response/json/cors 
	  (hash 'next (embed/url (lambda (r) 
				   (with-current-request-args r (top))))
		'value "Welcome"))))))

(define top3
  (thunk 
    (response/json/cors 
      (hash 'next #f
	    'value "End of the story"))))

(define (top2)
  (send/suspend/dispatch/json-continuation 
    top3
    "Once upon a time"))

(define (top)
  (send/suspend/dispatch/json-continuation 
    top2
    "Hello World!!"))

(define-values (do-routing url)
  (dispatch-rules
    [("top")
     (lambda (r) 
       (top-alt)
       )]))

(define (start-server)
  (serve/servlet (start do-routing)
		 #:port 8081
		 #:servlet-regexp #rx""
		 #:launch-browser? #f
		 #:stateless? #t))
