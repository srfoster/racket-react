(this["webpackJsonpmy-app"]=this["webpackJsonpmy-app"]||[]).push([[0],{65:function(e,t,n){},66:function(e,t,n){},71:function(e,t,n){"use strict";n.r(t);var c=n(0),a=n.n(c),r=n(11),o=n.n(r),s=(n(65),n(14)),i=n(40),j=(n.p,n(66),n(100)),l=n(73),u=n(115),b=n(104),p=n(103),O=n(105),f=n(106),d=n(119),h=n(107),x=n(117),g=n(108),m=n(109),v=n(41),w=n(112),y=n(113),S=n(114),C=n(120),k=n(118),T=n(110),L=n(111),I=n(5);function N(e){var t=Object(c.useState)(!1),n=Object(s.a)(t,2),a=n[0],r=n[1],o=Object(c.useState)(!1),i=Object(s.a)(o,2),j=(i[0],i[1]),u=Object(c.useState)({}),b=Object(s.a)(u,2),p=b[0],O=b[1];return Object(c.useEffect)((function(){a||(window.server_call("http://localhost:8081",e.path,{},(function(e){O(e)})),r(!0))})),localStorage.getItem("authToken")?e.afterLogin(p):Object(I.jsx)(l.a,{style:{padding:10,margin:10},children:Object(I.jsx)(R,{response:p,afterLogin:function(e){j(!0),O(e)},onNextResponse:O})})}function R(e){var t=Object(I.jsx)("span",{children:"LoginResponseViewer: error.  Report this as a bug."});return"error"==e.response.type&&(t=Object(I.jsx)(_,{response:e.response,onNextResponse:e.onNextResponse})),"success"==e.response.type&&(t=Object(I.jsx)(E,{response:e.response,afterLogin:e.afterLogin})),t}function _(e){var t=Object(c.useState)(),n=Object(s.a)(t,2),a=n[0],r=n[1],o=Object(c.useState)(),i=Object(s.a)(o,2),j=i[0],l=i[1];return Object(I.jsxs)("div",{children:[Object(I.jsx)("p",{children:e.response.message}),Object(I.jsx)("div",{children:Object(I.jsx)(u.a,{label:"username",onChange:function(e){return r(e.target.value)}})}),Object(I.jsx)("div",{children:Object(I.jsx)(u.a,{label:"password",onChange:function(e){return l(e.target.value)}})}),Object(I.jsx)("br",{}),Object(I.jsx)(b.a,{variant:"contained",color:"secondary",onClick:function(){window.server_call("http://localhost:8081",e.response.login.function,{username:a,password:j},(function(t){e.onNextResponse(t)}))},children:"Submit"})]})}function E(e){return Object(c.useEffect)((function(){window.localStorage.setItem("authToken",e.response.authToken),window.server_call("http://localhost:8081",e.response.continue.function,{},(function(t){e.afterLogin(t)}))})),Object(I.jsx)("div",{children:"One moment..."})}function F(e){return Object(I.jsx)(b.a,{variant:"contained",color:"secondary",onClick:function(){localStorage.removeItem("authToken")},children:"Logout"})}function J(e){var t=Object(c.useState)(!1),n=Object(s.a)(t,2),a=n[0],r=n[1],o=Object(c.useState)({}),i=Object(s.a)(o,2),j=i[0],l=i[1];return Object(c.useEffect)((function(){a||(window.server_call("http://localhost:8081",e.path,{},(function(e){l(e)})),r(!0))})),j?Object(I.jsx)(V,{object:j,onApiCall:l,domainSpecific:e.domainSpecific}):"waiting on response..."}function V(e){return function t(n){if(n.type){if("function"==n.type)return Object(I.jsxs)(A,{wrapper:n,onCall:e.onApiCall,children:["domainSpecific",e.domainSpecific]});if("argument"==n.type)return"Arg";var c=e.domainSpecific;if(c)return Object(I.jsx)(c,{wrapper:n})}return"object"==typeof n?Object.keys(n).map((function(e){return Object(I.jsx)(p.a,{children:Object(I.jsxs)(O.a,{children:[Object(I.jsx)(f.a,{children:Object(I.jsx)(d.a,{label:e})}),Object(I.jsx)(h.a,{children:Object(I.jsx)(x.a,{style:{margin:5,padding:5},children:t(n[e])})})]})})})):"string"==typeof n?'"'+n+'"':"boolean"==typeof n||"number"==typeof n?""+n:typeof n}(e.object)}function A(e){var t=Object(c.useState)(),n=Object(s.a)(t,2),a=n[0],r=n[1],o=Object(c.useState)({}),j=Object(s.a)(o,2),l=j[0],u=j[1];return"function"==e.wrapper.type?Object(I.jsx)(g.a,{children:Object(I.jsxs)(m.a,{children:[Object(I.jsxs)(v.a,{component:"p",variant:"h5",children:["function: ",Object(I.jsx)(d.a,{style:{marginLeft:5},label:e.wrapper.name})]}),Object(I.jsxs)(p.a,{children:[Object(I.jsxs)(O.a,{children:[Object(I.jsx)(f.a,{children:Object(I.jsx)(T.a,{fontSize:"small"})}),Object(I.jsx)(h.a,{children:e.wrapper.userDescription})]}),Object(I.jsxs)(O.a,{children:[Object(I.jsx)(f.a,{children:Object(I.jsx)(L.a,{fontSize:"small"})}),Object(I.jsx)(h.a,{children:e.wrapper.devDescription})]})]}),Object(I.jsx)(b.a,{onClick:function(){Object.keys(e.wrapper.arguments||{}).map((function(t){var n=e.wrapper.arguments[t].defaultValue;n&&void 0===l[t]&&(l[t]=n)})),window.server_call("http://localhost:8081",e.wrapper.function,l,(function(t){e.onCall?e.onCall(t):r(t)}))},color:"primary",children:"Call"}),e.wrapper.arguments?Object(I.jsx)(w.a,{children:Object(I.jsx)(y.a,{children:Object.keys(e.wrapper.arguments).map((function(t){return Object(I.jsxs)(S.a,{children:[Object(I.jsx)(C.a,{children:Object(I.jsx)(d.a,{label:t})}),Object(I.jsx)(C.a,{children:(n=e.wrapper.arguments[t],c=function(e){var n=Object(i.a)({},l);n[t]=e,u(n)},"string"===n.argumentType?Object(I.jsx)(z,{value:n.defaultValue,label:n.argumentType,onChange:c}):"boolean"===n.argumentType?Object(I.jsx)(D,{value:n.defaultValue,label:n.argumentType,onChange:c}):Object(I.jsx)("div",{children:"What's this??"}))})]});var n,c}))})}):"",a?Object(I.jsx)(V,{object:a,domainSpecific:e.domainSpecific}):""]})}):Object(I.jsx)(d.a,{color:"secondary",label:"Not a function: "+JSON.stringify(e.wrapper)})}function D(e){var t=Object(c.useState)(e.value),n=Object(s.a)(t,2),a=n[0],r=n[1];return Object(I.jsx)(k.a,{checked:a,onChange:function(t){r(!a),e.onChange(!a)}})}function z(e){var t=Object(c.useState)(e.value),n=Object(s.a)(t,2),a=n[0],r=n[1];return Object(I.jsx)(u.a,{onChange:function(t){r(t.target.value),e.onChange(t.target.value)},label:e.label,value:a,variant:"outlined"})}window.server_call=function(e,t,n,c){fetch(e+t+"?data="+encodeURI(JSON.stringify(Object(i.a)(Object(i.a)({},n),{authToken:window.localStorage.getItem("authToken")})))).then((function(e){return e.json()})).then((function(e){c(e)}))};var B=function(e){return Object(I.jsxs)(j.a,{children:[Object(I.jsx)(F,{}),Object(I.jsx)(N,{path:"/welcome",afterLogin:function(e){return Object(I.jsx)(J,{path:"/welcome"})}})]})},P=function(e){e&&e instanceof Function&&n.e(3).then(n.bind(null,123)).then((function(t){var n=t.getCLS,c=t.getFID,a=t.getFCP,r=t.getLCP,o=t.getTTFB;n(e),c(e),a(e),r(e),o(e)}))};o.a.render(Object(I.jsx)(a.a.StrictMode,{children:Object(I.jsx)(B,{})}),document.getElementById("root")),P()}},[[71,1,2]]]);
//# sourceMappingURL=main.07862930.chunk.js.map