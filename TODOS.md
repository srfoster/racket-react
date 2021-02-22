# TODOS

Authentication components (views) and server-side flows that go with them

* Use actual bcrypt library for hashing pwords
* Do JWT token gen/checking (hide the secret).
* Do better ui on the sign in page (password field, lol)

New Rune editor...
 -> Canvas of draggable components, compiles to s-expressions
 -> Have starter in examples/spells/runes.rkt
    - Make compilation "tree"acutally work.  Children reliably call onCompile in parents
    - Make children report back correct x and y in onStop (make relative to same parent?)
    - Make runes square
    - Try grid snapping
    - Make runes push other runes out of the way on drop?
    - Make alternative parens (grouping component? interlocking blocks?)
    - Make alternative runes (rune widgets.  Modals, expandables, checkboxes, text editors, etc.) 
    - Reverse compilation: Parse s-expressions into tree of components


;Wishlist /  Spellbook
  * Component editor (with server-side rendering flow / send back to client and inject in page?)
    - have started on this in `examples/website-integration`.  

  * Code editor component and server-side flows for: saving editable fields to a db, saving to a file
    - Eval Racket code...

  * Combine client and server for deployment.  Serve react from a server endpoint.
  * Tie in with website/website-js.  Static apps with react embedded (inject with website-js??).

  * File browser component?


  * ffmpeg
  * vim wasm
  * cytoscape
  * racket REPL
  * JSON Api explorer / webapp construction tools
  * Racket IDE
  * p5 embeds
  * Codepen
  * Prezi / impress.js

;Figure out how to serve react frontend from racket-react/server

;Design cool JSON API based on continuations
  * Maybe make the tree-based viewer into one where following a function call replaces the current explorer with the result... (maybe with back buffer...)


;Try server-side rendering of components!  React.hydrate()???

