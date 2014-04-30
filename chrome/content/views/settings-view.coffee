###
# file: settings-view.coffee
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

class SettingsView extends gcc.HtmlPage #{
  constructor: () -> super()
  getPivots: () ->
    a=[]
    a.push {id:'accts',pivot: new gcc.CloudAccounts() }
    a.push {id:'sshcfg', pivot: new gcc.SSHConfig() }
    a.push {id:'prefs',pivot: new gcc.GeneralPrefs() }
    a.push {id:'jsrun',pivot: new gcc.JSRun() }
    a
#}

`

gcc.SettingsView=SettingsView;

})(window, window.document, jQuery);


`
