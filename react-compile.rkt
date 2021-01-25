#lang at-exp racket

(provide
  component
  compile-app
  save-app
  compile-component
  js
  return
  ~
  class: 
  (all-from-out website))

(require website)

(define class: 'className:)

(struct component (name body))

(define js ~a)

(define (compile-component c)
  (match-define (component name body) c)

  @js{
    function @name (props){
      @body
    }
  })

(define (compile-app components)
  (define pass1
  @js{
  import logo from './logo.svg';
  import './App.css';
  import React, { useState } from 'react';

  @(string-join
     (map compile-component components)
     "\n\n")

  export default App;
  })


  ;Hacking to produce JSX that wouldn't be valid xml
  (regexp-replaces pass1
		   '(
		     [#rx"\"!@#\\$" "{"]
		     [#rx"\\$#@!\"" "}"]

		     [#rx"!@#\\$" "{"]
		     [#rx"\\$#@!" "}"]
		     
		     [#rx"&gt;" ">"] ;Bug: Should only be between delimiters!
		     ))
  )
  

(define (save-app #:to file 
		  components)
  (with-output-to-file 
    file
    #:exists 'replace
    (thunk
      (displayln
	(compile-app components)))))

(define (return thing)
  @js{
    return @(element->string thing)
  })

(define (~ . things )
  (~a "!@#$" (string-join things " ") "$#@!"))


