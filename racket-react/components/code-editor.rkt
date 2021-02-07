#lang at-exp racket

(provide CodeEditor)

(require racket-react/client)

(define-component CodeEditor
		  (add-import
		    @js{
		    require('codemirror/mode/scheme/scheme');
		    })
		  (add-import
		    @js{import {UnControlled as CodeMirror} from 'react-codemirror2' })
		  @(useState 'value @js{props.script.script})
		  @js{
		  return <div>

		  <CodeMirror
		  value='(define x 2)'
		  options={{
		  mode: 'scheme',
		  theme: 'material',
		  lineNumbers: true
		  }}
		  onChange={(editor, data, value) => {
		  window.server_call("http://localhost:8081",
				     props.script.editScript.function,
				     {script: value,
				     isPrivate: true},
				     (r)=>{
				     setValue(r.script)
				     }) 

		  }}
		  />

		  </div>
		  })

