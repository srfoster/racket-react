Look at `my-app/main.rkt`.  Basic example of using website syntax to produce
a react app, which then gets compiled in the usual `create-react-app` toolchain.

Value?  Can create react components in racket.  Faster UI prototyping.

Should pull in material UI as the default UI lib.

Should make the `npm start` happen on the first Racket run of main.rkt.  Subsequent
runs just save on top of App.js or whatever file.  Hot reload will automatically work.

=== Full stack

Look at `server.rkt`.  It contains the basics for demartialing client-side arguments
and using them as input on the server side. 

Clean this up and we can have a great rewrite of `webapp`:

Continuations + React + Material UI + Racket Module system

React components bound to server-side continuations

