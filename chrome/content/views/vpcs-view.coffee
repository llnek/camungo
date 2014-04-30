###
# file: vpcs-view.coffee
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

class VPCsView extends gcc.HtmlPage #{
  constructor: () -> super()
  getPivots: () ->
    a=[]
    a.push {id:'vlans',pivot: new gcc.VLANs() }
    a.push {id:'subnets', pivot: new gcc.Subnets() }
    a.push {id:'dhcps',pivot: new gcc.DHCPSets() }
    a.push {id:'gates',pivot: new gcc.Gateways() }
    a.push {id:'conns',pivot: new gcc.VlanConns() }
    a
  maybeUseHint:(hint) ->
    switch hint
      when 'vv-vv1' then 0
      when 'vv-vv2' then 1
      when 'vv-vv3' then 2
      when 'vv-vv4' then 3
      when 'vv-vv5' then 4
      else 0
#}

`

gcc.VPCsView=VPCsView;

})(window, window.document, jQuery);


`
