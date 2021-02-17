TODO:

* Automate the moving of the relevant app's `build` folder and `build/static` folder to `out/build` and `out/static`

* Figure out how racket server can serve up the code to eval to create the react component (currently inlined in main.rkt), while also using it on the server side (server-test.js) to produce the React string.  Maybe serve the React string and the js code together?  
