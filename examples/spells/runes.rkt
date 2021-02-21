#lang at-exp racket

(provide RuneSurface)

(require 
  racket-react/client
  racket-react/components/drag-and-drop)

(define-component
  Rune
  (return 
    (Draggable
      'onStop: @~{(e,d)=>{console.log(e,d); props.compile(d.x,d.y,props.children)}} 
      (div @~{props.children}))))

(define-component 
  RuneSurface
  (useState 'draggables 

	    @js{[

	    @(Rune 
	       'compile: @~{(x,y,val)=>console.log(x,y,val)}
	       "("),

	    @(Rune 
	       'compile: @~{(x,y,val)=>console.log(x,y,val)}
	       "RUNE!"),

	    @(Rune 
	       'compile: @~{(x,y,val)=>console.log(x,y,val)}
	       ")")

           ]})
  @js{

  return(
	 @(div 

	    (button 

	      'onClick: 
	      @~{()=>{
                setDraggables([...draggables, @(Draggable (div "new")) ])
	      }}

	      "Add Rune")

	    @js{{draggables}})
	 )
  })
