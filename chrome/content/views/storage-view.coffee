###
# file: storage-view.coffee
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

class StorageView extends gcc.HtmlPage #{
  constructor: () -> super()
  getPivots: () ->
    a=[]
    a.push {id:'vols', pivot: new gcc.Volumes() }
    a.push {id:'snaps',pivot: new gcc.Snapshots() }
    a.push {id:'cfiles',pivot: new gcc.CloudFiles() }
    a
  maybeUseHint:(hint) ->
    switch hint
      when 'cf-cf1' then 0
      when 'cf-cf2' then 1
      when 'cf-cf3' then 2
      else 0
#}

`

gcc.StorageView=StorageView;

})(window, window.document, jQuery);


`
