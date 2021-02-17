#lang at-exp racket

(require website)

(define (hydrate.html)
  (page hydrate.html
	(thunk
	  (displayln
	    @~a{
	    <html>
	    <script src="https://unpkg.com/react@"@"17/umd/react.development.js" crossorigin></script>
	    <script src="https://unpkg.com/react-dom@"@"17/umd/react-dom.development.js" crossorigin></script>
	    <body>
	    <div id="root">@(string-trim (with-output-to-string (thunk (system "nodejs server-test.js"))))</div>
	    <script>
	    const e = React.createElement;

	    class LikeButton extends React.Component {
	    constructor(props) {
	    super(props);
	    this.state = { liked: false };
	    }

	    render() {
	    if (this.state.liked) {
	    return 'You liked this.';
	    }

	    return e(
		     'button',
		     { onClick: () => this.setState({ liked: true }) },
		     'Like'
		     );
	    }
	    }

	    ReactDOM.hydrate(e(LikeButton), document.getElementById("root"))

	    //ReactDOM.render(e(LikeButton), document.getElementById("root"))
	    </script>
	    </div>
	    </html>
	    }))))

(define (index.html)
  (page index.html
	(div
	  (br)
	  (br)
	  (a href: "/build/index.html" "Goto react app")
	  (br)
	  (a href: "hydrate.html" "Hydration test..."))
	))

(render
  #:to "out" 
  (list
    (hydrate.html)
    (index.html)))
