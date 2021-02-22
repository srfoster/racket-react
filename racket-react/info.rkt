#lang info
(define collection "racket-react")
(define deps '("base"))
(define build-deps '("scribble-lib" "racket-doc" "rackunit-lib"))
(define scribblings '(("scribblings/racket-react.scrbl" ())))
(define pkg-desc "Description Here")
(define version "0.0")
(define pkg-authors '(stephen))
(define raco-commands
  '(
    ("react-new" (submod racket-react/raco-tools/new main) "" 100)
    ))
