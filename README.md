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

TODO: figure this out

```
racket-react/auth
```

```
racket-react/file-editor
```

```
racket-react/postgres
```


# TODOS

Clean up
  How to Factor out components into modules?
    CodeMirror almost done
      npm import

;Start personal component library!  Spellbook
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
