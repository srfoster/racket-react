#lang web-server

(require web-server/servlet-env)
(require json)

; start: request -> response
(define (start request)
  (show-counter 1 request))

; show-counter: number request -> doesn't return
; Displays a number that's hyperlinked: when the link is pressed,
; returns a new page with the incremented number.
(define (show-counter n request)
  (define (response-generator embed/url)
    (response/json/cors
      (hash
	'next (embed/url next-number-handler)
	'value n)))

  (define (next-number-handler request)
    ;Hacky way of getting parameter from
    ; url.  Can use this trick to send along
    ; json from the React runtime state of the component.
    (define arg
      (last
	(string-split (url->string (request-uri request)) "/")))

    (define mult (or (string->number arg) 1))

    (show-counter (+ n mult) request))

  (send/suspend/dispatch response-generator))

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
