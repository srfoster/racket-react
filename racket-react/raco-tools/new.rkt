#lang at-exp racket

(require racket/cmdline)

(module+ main
	 (define (->file f . ss)
	   (with-output-to-file
	     f

	   (thunk
	     (displayln
	       (apply ~a ss)))))

	 (define dir
	   (command-line
	     #:program "compiler"
	     #:args (dir) 
	     dir))

	 (make-directory dir)
	
	 @->file[(build-path dir "controllers.rkt")]{
	       #lang at-exp web-server

	       (provide start-server)

	       (require racket-react/server 
			json)

	       (define (welcome [count 0])
		 (with-embeds
		   (response/json/cors 
		     (hash 
		       'welcome-msg "Welcome"
		       'count count
		       'again (hash
				'type "function"
				'name "welcome"
				'userDescription "Keeps track of a counter"
				'devDescription "Demonstrates serialized continutions.  See @dir/controllers.rkt"
				'function (embed (curry welcome (add1 count))))))))

	       (define-values (do-routing url)
		 (dispatch-rules
		   [("top")
		    (lambda (r) 
		      (welcome))]))

	       (define (start-server)
		 (serve/servlet (start do-routing)
				#:port 8081
				#:servlet-regexp #rx""
				#:launch-browser? #f
				#:stateless? #t))

	       }

	 @->file[(build-path dir "reloadable.rkt")]{
	 #lang racket

	 (require reloadable)

	 (define start-server (reloadable-entry-point->procedure
				(make-reloadable-entry-point 'start-server "./controllers.rkt")))

	 (reload!)

	 (start-server)
	 }

	 @->file[(build-path dir "views.rkt")]{
	 #lang at-exp racket

	 (require racket-react/client
		  racket-react/components/api-explorer)

	 (define-component App
			   (return
			     (Container 
			       (APIExplorer 'path: "/top"))))

	 (displayln (compile-app components))

	 (save-app #:to "my-app/src/App.js")

	 }

	 (system (~a "cd " dir ";npx create-react-app my-app"))
	 (system (~a "cd " dir "/my-app;npm install @material-ui/core"))
	 (system (~a "cd " dir "/my-app;npm install @material-ui/icons"))
	 (system (~a "cd " dir "/my-app;npm install react-codemirror2 codemirror"))

	 (displayln "Run racket reloadable.rkt to run the server.  Run `cd my-app/; npm start`, then `racket views.rkt` when you make changes")

	 )

