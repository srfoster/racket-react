#lang at-exp racket

(require racket-react/client
	 racket-react/components/code-editor
	 racket-react/components/impress
	 racket-react/components/api-explorer
	 racket-react/components/cytoscape)

;Factor out more here

(define-component DomainSpecificUI
		  @js{
                  const display = (thing)=>{
		    if(thing.type=="script") {
                      return @(div
				(CodeEditor 'script: @~{thing})
				(ObjectExplorer 'object: @~{thing}))
		    } else {
                      return "Unknown Type: " + thing.type
		    }
		  }
		  }
		  @js{
		  return display(props.wrapper) 
		  })


(define-component App
		  (return
		    (Container 
		      (CytoscapeComponent 
			'style: @~{ { width: '600px', height: '600px' } }
			
				      'elements: @~{
				      [
				       { data: { id: 'one', label: 'Node 1' }, position: { x: 300, y: 300 } },
				       { data: { id: 'two', label: 'Node 2' }, position: { x: 400, y: 300 } },
				       { data: { source: 'one', target: 'two', label: 'Edge from Node1 to Node2' } }
				       ]
				      } )

		      (APIExplorer 'path: "/top"
				   'domainSpecific: @~{DomainSpecificUI})

		      ;For a good time...
		      #;
		      (Impress 
			'progress: @~{true}
			(Step 'id: @~{'hi'} 'data: @~{{x: -10000, y: -10000}}
			      "Are you ready?")
			@(Step 'duration: @~{1500}
			       (h1 "Here's the API explorer")
			       (ContinuationViewer 'path: "/top")))
		      )))

(displayln (compile-app components))

(save-app)

