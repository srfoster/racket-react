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
  useState
  add-import
  (all-from-out website))

(require website
	 syntax/parse/define)

(require (for-syntax racket/syntax)
	 (only-in scribble/text with-writer ))

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
	   (apply element/not-empty 'name attrs)


#;
	   (lambda ()
	     (with-writer write-string ;Maybe fixes special characters in attrs?
			  (with-output-to-string
			    (thunk
			      (output-xml 
				(apply element/not-empty 'name attrs))))))))]))

(define (js . s)
  (define (->string s)
    (cond 
      [(string? s) s]
      [(procedure? s) (->string (s))]
      [(symbol? s) (~a s)]
      [else (remove-special-characters (element->string s))]))
	
  (apply ~a (map ->string s)))

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

  @(string-join
     imports
     "\n\n")

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
  (remove-special-characters pass1)
  )


(define (remove-special-characters s)
  (regexp-replaces s
		   '(
		     [#rx"\"!@#\\$" "{"]
		     [#rx"\\$#@!\"" "}"]

		     [#rx"!@#\\$" "{"]
		     [#rx"\\$#@!" "}"]

		     [#rx"&quot;" "\""] ;Bug: Should only be between delimiters!
		     [#rx"&gt;" ">"] ;Bug: Should only be between delimiters!
		     [#rx"&lt;" "<"] ;Bug: Should only be between delimiters!
		     )))
  

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

(define (useState id [input ""])
  @js{var [@id, set@(string-titlecase (substring (~a id) 0 1))@(substring (~a id) 1 )] = useState(@input)} ;Can we macroify??
  )


(define imports '())
(define (add-import line)
  (set! imports (cons line imports)))

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

(provide (rename-out [Mui.TextField TextField]))
(define-component Mui.TextField)

(provide (rename-out [Mui.TableContainer TableContainer]))
(define-component Mui.TableContainer)

(provide (rename-out [Mui.Table Table]))
(define-component Mui.Table)

(provide (rename-out [Mui.TableHead TableHead]))
(define-component Mui.TableHead)

(provide (rename-out [Mui.TableBody TableBody]))
(define-component Mui.TableBody)

(provide (rename-out [Mui.TableRow TableRow]))
(define-component Mui.TableRow)

(provide (rename-out [Mui.TableCell TableCell]))
(define-component Mui.TableCell)

(provide (rename-out [Mui.Switch Switch]))
(define-component Mui.Switch)

(provide (rename-out [I.Code CodeIcon]))
(define-component I.Code)

(provide (rename-out [I.Person PersonIcon]))
(define-component I.Person)
