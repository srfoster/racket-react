#lang at-exp racket

(provide Draggable)

(require racket-react/client)

(add-import!  @js{ import Draggable from 'react-draggable' })

(add-dependency! "react-draggable")

(define-foreign-component Draggable)
