Continuations + React + Material UI + Racket Module system

React components bound to server-side continuations

# Getting Started

`raco react-new project-name`

Running the server:


Running the client (dev server): 


Example `project-name/views.rkt`:

```
#lang at-exp racket

(require racket-react/client
	 racket-react/components/code-editor)

(define-component App
  (return
    (CodeEditor 'script: "(hello-world)")))

(save-app)

```

# Handy packages

## Authentication

On the server:

```
(require racket-react/flows/auth)

(dispatch-rules
    [("protected-endpoint")
     (lambda (r) 
       (require-login my-protected-function))])

```

The given endpoint is now protected and will (until there is a successful login) respond with payloads that can be handled by the `LoginForm` in `racket-react/compnents/auth`

On the client: 

```
(require racket-react/components/auth)

(define-component App
		  (return
		    (Container 
		      (LoginForm 'path: "/welcome"

				 'afterLogin: @~{(props)=><APIExplorer path="/welcome"/>})
				 ) 
		      )))

```

Pass in to `LoginForm`'s `afterLogin:` prop whatever component you want to be viewed after the login flow successfully completes (the user logs in).




```
racket-react/file-editor
```

```
racket-react/postgres
```


# TODOS

Authentication components (views) and server-side flows that go with them

* Use actual bcrypt library for JWT token gen/checking
* ~~Make client-side component send localStorage'd JWT token in request.  Show afterLogin if logged in...~~
* ~~Make server-side send actual JWT~~


;Wishlist /  Spellbook
  * Component editor (with server-side rendering flow / send back to client and inject in page?)
    - have started on this in `examples/website-integration`.  

  * Code editor component and server-side flows for: saving editable fields to a db, saving to a file
    - Eval Racket code...

  * Combine client and server for deployment.  Serve react from a server endpoint.
  * Tie in with website/website-js.  Static apps with react embedded (inject with website-js??).

  * File browser component?


  * ffmpeg
  * vim wasm
  * cytoscape
  * racket REPL
  * JSON Api explorer / webapp construction tools
  * Racket IDE
  * p5 embeds
  * Codepen
  * Prezi / impress.js

;Figure out how to serve react frontend from racket-react/server

;Design cool JSON API based on continuations
  * Maybe make the tree-based viewer into one where following a function call replaces the current explorer with the result... (maybe with back buffer...)


;Try server-side rendering of components!  React.hydrate()???


# Example apps

Spell server:

;Argument types, generate
;   components for different kinds of input, strings, integers (ranges?), booleans,  
;   other types


# Minor fixes


;Declare props like path: so we don't have to 'path:


# Future ideas

;Hook widgets up to each other.  Build your own workflows...

# Quotes

;Code has the power to make things that are pretty bad, that work just fine
