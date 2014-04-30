###
# file: login.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_prefs= new gcx.Prefs(),
g_xul= new gcx.XULLib(),
g_ute=new gcc.Ute();


`


class Login #{
  constructor: () ->
  doAuth: (user,pwd, ok,nok) ->
    db= g_prefs.getUsersDB()
    rec=db.find(user)
    ack=false
    if is_alive(rec)
      ack= rec.pwd is g_xul.obfuscate(pwd)
    if ack then ok(user,rec) else nok(user)
#}


`

gcc.Login=Login;

})(window, window.document, jQuery);


`
