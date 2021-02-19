#lang at-exp web-server

(provide start-server)

(require racket-react/server
         json
	 racket-react/components/code-editor
	 (only-in racket-react/client
		  compile-component))

#;
(define-component LikeButton
		  (useState 'clicked)
		  (return
		    @js{
		    clicked ? "Liked!" : <button onClick={()=> setClicked(true)}>Like?</button>
		    }))

(define (welcome [count 0])
  (with-embeds
    (response/json/cors
      (hash
        'type "dynamic-component"
	#|
	'source @~a{
	    (function(){
	    const e = React.createElement;

	    @(compile-component (CodeEditor-component))

	    return <CodeEditor script="(hi)"/>
	    })()
	}
	|#
	'source @~a{
	    (function(){
	    const e = React.createElement;

	    const LikeButton = (props) => {

            var [clicked, setClicked] = useState(false) 
	    return clicked ? "Liked!" : <button onClick={()=> setClicked(true)}>{props.label || "Like??"}</button>
	    }
	    

	    return <LikeButton />

	    })()
	}

       ))))

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

