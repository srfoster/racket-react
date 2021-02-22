#lang at-exp racket

(provide RuneSurface)

(require 
  racket-react/client
  racket-react/components/drag-and-drop)

(define-component
  Rune
  (useState 'x @js{props.x})
  (useState 'y @js{props.x})
  (useState 'width 50)
  (useState 'height 50)
  @js{
  const round = (n)=>{
  return Math.floor(n/25) * 25
  }
  }
  (return 
    (Draggable
      'onStop: @~{(e,d)=>{
      //Hmmm.  Parent here is brittle
      var t = e.target.parentElement.style.transform;  
      if(t.match(/translate/)){
      var x = Number(t.match(/[0-9]*px/g)[0].replace("px",""));
      var y = Number(t.match(/[0-9]*px/g)[1].replace("px",""));
      setX(x); setY(y); 
      props.compile(x,y,props.children)}
      }
      } 
      'grid: @~{[25,25]}
      (Card
	style: @~{{cursor: "pointer", position: "absolute", width: width, height: height}}
	;'onMouseEnter: @~{()=>{setWidth(100); setHeight(100)}}
	;'onMouseLeave: @~{()=>{setWidth(50); setHeight(50)}}
	(CardContent
	  style: @~{{textOverflow: "ellipsis", whiteSpace: "nowrap", display: "block", overflow: "hidden"}}
	  @~{props.content}

	  #;
	  (Tooltip 'title: @~{props.content}
		   (Button
		     @~{props.content[0]}
		     ))
	 ; (br)
	 ; "(" @~{x} "," @~{y} ")"
	  )))))

(define-component 
  RuneSurface
  (useState 'runes 
	    @js{
	     {
	      "1": {x: 0, y: 0, content: "("},
	      "2": {x: 0, y: 0, content: "RUNE"},
	      "3": {x: 0, y: 0, content: ")"} 
	      }})
  @js{

  const compile = (runes) =>{
    var sorted = Object.values(runes).sort((a,b)=>{
      if(a.y > b.y) return 1
      if(a.y < b.y) return -1

      if(a.x > b.x) return 1
      if(a.x < b.x) return -1
			    
      return 0
    })

    return sorted.map((r)=>r.content).join(" ")
  }

  return(
	 @(div 'style: @~{{width: 500, height: 500}}
	    @~{compile(runes)}

	    (button 

	      'onClick: 
	      @~{()=>{
	        var newRunes = JSON.parse(JSON.stringify(runes))
		newRunes[""+(Object.keys(newRunes).length+1)] = {x:0, y:0, content: "NEW"}
                setRunes(newRunes)
	      }}

	      "Add Rune")



	    @js{{Object.keys(runes).map((d)=>
					     <Rune id={d} 
					           content={runes[d].content} 
						   x={runes[d].x}
						   y={runes[d].y}
						   compile={(x,y,content)=>{
						    var newRunes = JSON.parse(JSON.stringify(runes))
						    newRunes[d].x = x
						    newRunes[d].y = y
						    setRunes(newRunes) 
						   }}
						   />
					     )}})
	 )
  })
