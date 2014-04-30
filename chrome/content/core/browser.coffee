###
# file: browser.coffee
###
`
(function(genv,document,$,undefined){
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var C_AWSURLS= {
  'EC2AcctActivity' : 'http://aws.amazon.com/account/',
  'EC2Status' : 'http://status.aws.amazon.com/',
  'EC2InstanceTypes' : 'http://aws.amazon.com/ec2/instance-types/',
  'EC2Pricing' : 'http://aws.amazon.com/ec2/#pricing'
},
g_nfc= function() {},
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_ute= new gcc.Ute(),
g_xul= new gcx.XULLib(),
g_prefs= new gcx.Prefs();

`

class Browser extends gcc.HtmlPage #{
  constructor: () -> super()
  render: () ->
  start: () ->
    b=g_xul.getBrowser()
    me=this
    b.setUserData('db.acctprops', new gcc.AcctPropsDB(), g_nfc)
    b.setUserData('db.accts', new gcc.AcctsDB(), g_nfc)
    b.setUserData('db.users', new gcc.UsersDB(), g_nfc)
    ok=(user,rec) -> me.onLoginOK(user,rec)
    nok=(user) -> me.onLoginError(user)
    new gcc.Login().doAuth('admin','', ok, nok)
  onLoginNOK: (user) -> alert(user + ' BIG TROUBLE!')
  onLoginOK: (user, rec) ->
    db= g_prefs.getAcctsDB()
    c=db.getCurAcct(rec.key)
    if is_alive(c)
      db= g_prefs.getAcctPropsDB()
      ps=db.find(c.key)
    if g_prefs.getJSCons() then g_xul.openJSConsole()
    b=g_xul.getBrowser()
    b.setUserData('cloud.acct.props', ps || {}, g_nfc)
    b.setUserData('cloud.acct', c || {} , g_nfc)
    b.setUserData('cloud.user.name', user, g_nfc)
    b.setUserData('cloud.user.key', rec.key, g_nfc)
    b.setUserData('log.flags', { log: g_prefs.getEnableLog(), debug: g_prefs.getEnableDebug() }, g_nfc)
    b.loadURI('chrome://camungo/content/views/app.html')
  finz: () ->
    g_xul.finzJSConsole()

#}


`
gcc.Browser=Browser;

})(window, window.document,jQuery);


`
