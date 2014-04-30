###
# file: databases-view.coffee
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

class DatabasesView extends gcc.HtmlPage #{
  constructor: () -> super()
  getPivots: () ->
    a=[]
    a.push {id:'rdbms', pivot: new gcc.RDBMS() }
    a.push {id:'nosql',pivot: new gcc.NoSQL() }
    a
  maybeUseHint:(hint) ->
    switch hint
      when 'db-db1' then 0
      when 'db-db2' then 1
      else 0
#}

`

gcc.DatabasesView=DatabasesView;

})(window, window.document, jQuery);


`
