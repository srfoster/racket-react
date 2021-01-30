#lang at-exp racket

(provide
  define-component
  component
  compile-app
  save-app
  compile-component
  js
  return
  ~
  class: 
  useEffect
  (all-from-out website))

(require website
	 syntax/parse/define)

(require (for-syntax racket/syntax))

(define class: 'className:)

(struct component (name body))

(define-syntax (define-component stx)
  (syntax-parse 
    stx
    [(_ name content ...)
     #:with name-component (format-id stx "~a-component" #'name)
     #'(begin
	 (define name-component
	   (component 'name (list content ...)))
	
	 (define (name . attrs)
	   (apply element/not-empty 'name attrs))
	 
	)
     ]))

(define js ~a)

(define (compile-component c)
  (match-define (component name body) c)

  @js{
    function @name (props){
      @(string-join body "\n\n")
    }
  })

(define (compile-app components)
  (define pass1
  @js{
  import logo from './logo.svg';
  import './App.css';
  import React, { useState, useEffect } from 'react';

  import * as Mui from '@"@"material-ui/core';
  import * as I from '@"@"material-ui/icons';


  window.server_call = (host,server_function,data,cb) =>{
  fetch(host + server_function + "?data=" + encodeURI(JSON.stringify(data))).then((r)=>r.json())
  .then((r)=>{
	cb(r)
	})
  }

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
		     [#rx"&lt;" "<"] ;Bug: Should only be between delimiters!
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


(define (useEffect . content)
  @js{
  useEffect(()=>{
   @(string-join content "\n")
  }) 
  })

(provide (rename-out [Mui.Button Button]))
(define-component Mui.Button)

(provide (rename-out [Mui.Paper Paper]))
(define-component Mui.Paper)

(provide (rename-out [Mui.Container Container]))
(define-component Mui.Container)

(provide (rename-out [Mui.Chip Chip]))
(define-component Mui.Chip)

(provide (rename-out [Mui.List List]))
(define-component Mui.List)

(provide (rename-out [Mui.ListItem ListItem]))
(define-component Mui.ListItem)

(provide (rename-out [Mui.ListItemIcon ListItemIcon]))
(define-component Mui.ListItemIcon)

(provide (rename-out [Mui.ListItemText ListItemText]))
(define-component Mui.ListItemText)

(provide (rename-out [Mui.Box Box]))
(define-component Mui.Box)

(provide (rename-out [Mui.Card Card]))
(define-component Mui.Card)

(provide (rename-out [Mui.CardContent CardContent]))
(define-component Mui.CardContent)

(provide (rename-out [Mui.Typography Typography]))
(define-component Mui.Typography)

(provide (rename-out [Mui.Icon Icon]))
(define-component Mui.Icon)

