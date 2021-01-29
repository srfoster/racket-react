#lang at-exp web-server

(provide start-server)

(require "../server.rkt")

;Hmmm.  Top-alt might be preferable.
;  Maybe we just return json objects but with continuations serialized into them.
;  The client can decide what to call based on its own logic, and/or the meta-data associated with the continuations...
;  Just clean up the send/suspend/dispatch + lambda + embed/url + lambda + with-current-request-args...

; Factor out this fancy macro

(define (load-script)
  (with-embeds
    (response/json/cors 
      (hash 
	'script "(hello-world)"))))

(define (welcome)
  (with-embeds
    (response/json/cors 
      (hash 
	'welcome-msg "Welcome"
        'load-script (embed load-script)))))

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
