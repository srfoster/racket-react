#lang at-exp web-server

(provide start-server)

(require racket-react/server 
	 json)

(define (welcome [count 0])
  (with-embeds
    (response/json/cors 
      (hash 
	'welcome-msg "Welcome"
	'count count
	'again (hash
		 'type "function"
		 'name "welcome"
		 'userDescription "Keeps track of a counter"
		 'devDescription "Demonstrates serialized continutions.  See @dir/controllers.rkt"
		 'function (embed (curry welcome (add1 count))))))))

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
