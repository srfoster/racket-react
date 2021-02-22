var React = require('react')
var ReactDOMServer = require('react-dom/server')

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

	}
}

var E = e(
	'button',
	{ onClick: () => this.setState({ liked: true }) },
	'Like'
)

console.log(ReactDOMServer.renderToString(E))
