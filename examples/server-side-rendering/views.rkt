#lang at-exp racket

(require racket-react/client
         racket-react/components/api-explorer)

;(define-component )

;ReactDOM.hydrate(e(LikeButton), document.getElementById("root"))

(define-component App
		  (useState 'loaded)
		  (useState 'DynamicComponent)
		  (useEffect
		    @js{
		    if(loaded) return
		      window.server_call("http://localhost:8081", "/top", {}, 
			(r)=>{
			var s = babel.transform(r.source, { plugins: ["transform-react-jsx"] }).code
			console.log(s)
			var X =eval(s)

			setDynamicComponent(X)
			}) 
		    setLoaded(true)
		    })
                  (return
		    @js{
		    DynamicComponent ?
		    DynamicComponent :
		    "loading"
		    }
		    ))

(displayln (compile-app components))

(save-app)

