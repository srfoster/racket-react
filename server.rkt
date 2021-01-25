#lang web-server

;TODO: Abstract away requests.
;  Just let peope make logic based on passing functions out to front end UI to call with user-produced data

(require web-server/servlet-env)
(require json)

(require web-server/lang/web-param)

(define current-request-args
  (make-web-parameter (void)))

(define-syntax-rule (with-current-request-args request lines ...)
  (web-parameterize
    ([current-request-args (parse-args request)])
    lines ...))

(define (json-continuation next current)
  ;Next is a function with no params, but which may use (current-request-args) within it
  (lambda (embed/url)
    (response/json/cors
      (hash
	'next (embed/url (lambda (request) 
			   (with-current-request-args request
			     (next))))
	'value current))))

(define (parse-args request)
  ;Hacky way of getting parameter from
  ; url.  Can use this trick to send along
  ; json from the React runtime state of the component.
  (define s
    (string-split (url->string (request-uri request)) "/"))
  (define arg
    (if (empty? s)
	(void)
	(last s)))

  ;Assume number for now, generalized to json strings later
  (define n (or (string->number (~a arg)) 1))

  n)

(define (start request)
  (with-current-request-args request
    (show-counter 1)))

(define (show-counter n)
  (define (next-number-handler) ; I guess this is the shape of json-continuable functions: No params; uses current-request-args
    (define mult (current-request-args))
    (show-counter (+ n mult)))

  (send/suspend/dispatch (json-continuation next-number-handler n)))

(define (response/json json)
  (response/full
    200 #"Success"
    (current-seconds) APPLICATION/JSON-MIME-TYPE
    '()
    (list 
      (string->bytes/utf-8 
	(jsexpr->string json)))))

(define (response/json/cors html)
  (local-require 
    web-server/http/response-structs
    web-server/http/request-structs)

  (define r (response/json html))

  (struct-copy response r
	       [headers 
		 (append
		   (list
		     (header 
		       #"Access-Control-Allow-Origin"
		       #"*"))
		   (response-headers r))]))

(define (start-server)
  (serve/servlet start
		 #:port 8081
		 #:servlet-regexp #rx""
		 #:launch-browser? #f
		 #:stateless? #t
		 ))

(start-server)
