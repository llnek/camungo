###
# file: machines-view.coffee
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

class MachinesView extends gcc.HtmlPage #{
  constructor: () -> super()
  getPivots: () ->
    a=[]
    a.push {id:'vms', pivot: new gcc.VirtualMachines() }
    a.push {id:'images',pivot: new gcc.Images() }
    a.push {id:'scaling',pivot: new gcc.AutoScaling() }
    a.push {id:'lcfg',pivot: new gcc.LaunchCfg() }
    a.push {id:'lbs',pivot: new gcc.LoadBalancers() }
    a
  maybeUseHint:(hint) ->
    switch hint
      when 'ma-ma1' then 0
      when 'ma-ma2' then 1
      when 'ma-ma3' then 2
      when 'ma-ma4' then 3
      when 'ma-ma5' then 4
      else 0
#}

`

gcc.MachinesView=MachinesView;

})(window, window.document, jQuery);


`
