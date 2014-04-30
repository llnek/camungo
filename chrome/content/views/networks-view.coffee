###
# file: networks-view.coffee
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

class NetworksView extends gcc.HtmlPage #{
  constructor: () -> super()
  getPivots: () ->
    a=[]
    a.push {id:'fwalls', pivot: new gcc.FireWalls() }
    a.push {id:'keys',pivot: new gcc.SSHKeys() }
    a.push {id:'ipaddrs',pivot: new gcc.IPAddrs() }
    a
  maybeUseHint:(hint) ->
    switch hint
      when 'nw-nw2' then 0
      when 'nw-nw3' then 1
      when 'nw-nw4' then 2
      else 0
#}

`

gcc.NetworksView=NetworksView;

})(window, window.document, jQuery);


`
