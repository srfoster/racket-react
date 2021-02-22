#lang at-exp racket

(provide CodeEditor
	 CodeEditor-component)

(require racket-react/client)

(add-css!
  @js{
  @"@"import 'codemirror/lib/codemirror.css';
  @"@"import 'codemirror/theme/material.css';
  })

(add-post-import
  @js{
  require('codemirror/mode/scheme/scheme');
  })

(add-import
  @js{import {UnControlled as CodeMirror} from 'react-codemirror2' })

(add-dependency! "react-codemirror2")
(add-dependency! "codemirror")

(define-component CodeEditor
		  @(useState 'value @js{props.script.script})
		  @js{
		  return <div>

		  <CodeMirror
		  value={props.script}
		  options={{
		  mode: 'scheme',
		  theme: 'material',
		  lineNumbers: true
		  }}
		  onChange={props.onChange}
		  />

		  </div>
		  })

