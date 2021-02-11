#lang at-exp racket

(provide
  define-component
  define-foreign-component
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
  components
  add-component!
  add-css!
  add-dependency!
  add-import
  add-post-import
  (rename-out [add-import add-import!]
	      [add-post-import add-post-import!])
  (all-from-out website))

(require website
	 syntax/parse/define)

(require (for-syntax racket/syntax)
	 (only-in scribble/text with-writer ))

(define class: 'className:)

(struct component (name body))

(define components '())
(define (add-component! c)
  (set! components (cons c components)))

(define csss '())
(define (add-css! css)
  (set! csss (cons css csss)))

;Not used yet.  Should drive npm installs
(define deps '())
(define (add-dependency! dep)
  (set! deps (cons dep deps)))

(define-syntax (define-foreign-component stx)
  (syntax-parse 
    stx
    [(_ name content ...)
     #:with name-component (format-id stx "~a-component" #'name)
     #'(begin
	 (define (name . attrs)
	   (apply element/not-empty 'name attrs))
	 )]))

(define-syntax (define-component stx)
  (syntax-parse 
    stx
    [(_ name content ...)
     #:with name-component (format-id stx "~a-component" #'name)
     #'(begin
	 (define (name-component)
	   (component 'name (list content ...)))

	 (define (name . attrs)
	   (apply element/not-empty 'name attrs))

	 (add-component! name-component)

	 )]))

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
      @(string-join (filter (not/c void?) body) "\n\n")
    }
  })

(define (installed? dep)
  ;Buggy.  Should parse the JSON.
  (regexp-match
    dep
    (file->string "my-app/package.json")
    ))

(define (install-deps)
  (define to-install
    (filter (not/c installed?)
	    deps))
  
  (when (not (empty? to-install))
    (system @~a{cd my-app; npm i @(string-join to-install " ")})))

(define (compile-app components)
  (install-deps)

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

  @(string-join
     post-imports
     "\n\n")

  window.server_call = (host,server_function,data,cb) =>{
  fetch(host + server_function + "?data=" + encodeURI(JSON.stringify(data))).then((r)=>r.json())
  .then((r)=>{
	cb(r)
	})
  }


  @(string-join
     (map (lambda (c) 
	    (compile-component (c))) components)
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
  

(define (save-app)
  (with-output-to-file 
    (build-path "my-app" "src" "App.css")
    #:exists 'replace
    (thunk
      (map displayln csss)))
  (with-output-to-file 
    (build-path "my-app" "src" "App.js")
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

(define post-imports '())
(define (add-post-import line)
  (set! post-imports (cons line post-imports)))

(provide (rename-out [Mui.Button Button]))
(define-foreign-component Mui.Button)

(provide (rename-out [Mui.Paper Paper]))
(define-foreign-component Mui.Paper)

(provide (rename-out [Mui.Container Container]))
(define-foreign-component Mui.Container)

(provide (rename-out [Mui.Chip Chip]))
(define-foreign-component Mui.Chip)

(provide (rename-out [Mui.List List]))
(define-foreign-component Mui.List)

(provide (rename-out [Mui.ListItem ListItem]))
(define-foreign-component Mui.ListItem)

(provide (rename-out [Mui.ListItemIcon ListItemIcon]))
(define-foreign-component Mui.ListItemIcon)

(provide (rename-out [Mui.ListItemText ListItemText]))
(define-foreign-component Mui.ListItemText)

(provide (rename-out [Mui.Box Box]))
(define-foreign-component Mui.Box)

(provide (rename-out [Mui.Card Card]))
(define-foreign-component Mui.Card)

(provide (rename-out [Mui.CardContent CardContent]))
(define-foreign-component Mui.CardContent)

(provide (rename-out [Mui.Typography Typography]))
(define-foreign-component Mui.Typography)

(provide (rename-out [Mui.Icon Icon]))
(define-foreign-component Mui.Icon)

(provide (rename-out [Mui.TextField TextField]))
(define-foreign-component Mui.TextField)

(provide (rename-out [Mui.TableContainer TableContainer]))
(define-foreign-component Mui.TableContainer)

(provide (rename-out [Mui.Table Table]))
(define-foreign-component Mui.Table)

(provide (rename-out [Mui.TableHead TableHead]))
(define-foreign-component Mui.TableHead)

(provide (rename-out [Mui.TableBody TableBody]))
(define-foreign-component Mui.TableBody)

(provide (rename-out [Mui.TableRow TableRow]))
(define-foreign-component Mui.TableRow)

(provide (rename-out [Mui.TableCell TableCell]))
(define-foreign-component Mui.TableCell)

(provide (rename-out [Mui.Switch Switch]))
(define-foreign-component Mui.Switch)

(provide (rename-out [I.Code CodeIcon]))
(define-foreign-component I.Code)

(provide (rename-out [I.Person PersonIcon]))
(define-foreign-component I.Person)
