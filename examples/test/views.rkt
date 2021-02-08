#lang at-exp racket

(require racket-react/client
	 racket-react/components/api-explorer)

(define-component App
		  (return
		    (Container 
		      (APIExplorer 'path: "/top"))))

(displayln (compile-app components))

(save-app #:to "my-app/src/App.js")
