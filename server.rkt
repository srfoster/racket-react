#lang web-server

;TODO: Abstract away requests.
;  Just let peope make logic based on passing functions out to front end UI to call with user-produced data
;
; Figure out how client and server code interact.  How does a component get bound to a continued function?

; * Make client-side helper for doing fetches. And for constructing hashes.
;   -> @~{...} injecting extra curlies.  When to use vs @js?
; * How to connect component to a server function?
;   -> window.server_call...
;   -> Patterns for starting off a continuation and passing around references to the continuation path?
;   -> Should all continuations store result as {value: ...}?  See message below.



; * Parameterize localhost...
; * Make a way to easily include react stuff in websites via (render...)
; * Make macros for useState and define local values for get and set.
; * Allow quotes and greater thans etc. in attrs.  Need to hack around scribble/html's limitation there.
; * Make a better way of aggregating all the components together.  Not (list A-component B-component).  Maybe detect during rendering when component (div (A (B))) gets rendered and have A and B be functions that add the appropriate component to some global list somewhere (if not already there), and then they compile into <A><B/></A> etc.

(require web-server/servlet-env)
(require json)
(require net/uri-codec)
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
    (extract-binding/single
      'data
      (request-bindings request)))

  (define j (string->jsexpr (uri-decode s)))

  j)

(define (arg key)
  (hash-ref (current-request-args) key))

(define-values (do-routing url)
  (dispatch-rules
    [("message")
     (lambda (r) 
       (response/json/cors
	 (hash
	   'message "Hello world"
	   )))]
    [("counter")
     (lambda (r) (show-counter 1))
     ]))

(define (start request)
  (with-current-request-args 
    request
    (do-routing request)))

(define (show-counter n)
  (define (next-number-handler) ; I guess this is the shape of json-continuable functions: No params; uses current-request-args
    (show-counter (+ n (arg 'mult))))

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
