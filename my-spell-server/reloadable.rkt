#lang racket

(require reloadable)

(define start-server (reloadable-entry-point->procedure
		       (make-reloadable-entry-point 'start-server "./main.rkt")))

(reload!)

(start-server)
