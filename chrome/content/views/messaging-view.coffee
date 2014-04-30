###
# file: messaging-view.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class MessagingView extends gcc.HtmlPage #{
  constructor: () -> super()
  getPivots: () ->
    a=[]
    a.push {id:'metrics',pivot: new gcc.Metrics() }
    a.push {id:'queues',pivot: new gcc.Queues() }
    a.push {id:'notify', pivot: new gcc.PushServices() }
    a
  maybeUseHint:(hint) ->
    switch hint
      when 'mg-mg1' then 0
      when 'mg-mg2' then 1
      when 'mg-mg3' then 2
      else 0
#}

`

gcc.MessagingView=MessagingView;

})(window, window.document, jQuery);


`
