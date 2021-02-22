#lang at-exp racket

(provide CytoscapeComponent)

(require racket-react/client)

(add-import!
  @js{ 
  import CytoscapeComponent from 'react-cytoscapejs';
  })

  (add-dependency! "react-cytoscapejs")

(define-foreign-component CytoscapeComponent)

