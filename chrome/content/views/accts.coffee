###
# file: accts.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gc=genv.ComZotoh,
g_nfc=function(){},
gcc=gc.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_prefs=new gcx.Prefs(),
g_ute=new gcc.Ute();


`

class CloudAccounts extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.accts')
    @cm0= [ @tct('%id'), @tct('%acct.num'), @tct('%acct.id'), @tct('%acct.pwd'), @tct('%acct.email'), @tct('%in.use'),@tct('%acct.vendor') ]
    @gid= 'accts-grid'
    @tids= [ @gid ]
  moniker: 'accts'
  id: 'accts-tpl'
  postDraw: () ->
    gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.acct'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.acct'),icon:'minus'}
    icons.push {linkid: @btnid('edit'), title: @l10n('%edt.acct'),icon:'edit'}
    icons.push {linkid: @btnid('tick'), title: @l10n('%dft.acct'),icon:'check'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')
  onRefresh: () ->
    bw=g_xul.getBrowser()
    #bw.getUserData('cloud.user.name')
    key=bw.getUserData('cloud.user.key')
    [cur, cc]= g_prefs.getAcctsDB().getAccts(key)
    @uploadTable( @gid, _.values(cc))
  fmtAsRow: (dtb,row) ->
    pwd= if g_ute.vstr(row.pwd) then '****' else ''
    c=g_xul.getBrowser().getUserData('cloud.acct')
    dft= if c.key is row.key then @l10n('%yes') else ''
    [ row.key, [ row.key, row.acctno, row.id, pwd, row.email, dft, @l10n(row.vendor) ] ]
  onTableRClicked: (table,tr,data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0, pwd: -1 })
  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelAcct() )
    $('#'+ @btnid('add')).click( ()-> me.onAddAcct() )
    $('#'+ @btnid('edit')).click( ()-> me.onEditAcct() )
    $('#'+ @btnid('tick')).click( ()-> me.onDftAcct() )
  addNewAcct: (row) -> @maybeSyncAcct()
  delAcct: (row) -> @maybeSyncAcct()
  maybeSyncAcct: ()->
    bw=g_xul.getBrowser()
    uk=bw.getUserData('cloud.user.key')
    [ cur, cc ]= g_prefs.getAcctsDB().getAccts(uk)
    if g_ute.vstr(cur)
      row= cc[cur]
      ps=g_prefs.getAcctPropsDB().find(row.key) || {}
      bw.setUserData('cloud.acct', row, g_nfc)
      bw.setUserData('cloud.acct.props', ps , g_nfc)
    @uploadTable(@gid, _.values(cc) )
    gcc.HtmlPage.cloud=null

  onDftAcct: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      bw=g_xul.getBrowser()
      uk=bw.getUserData('cloud.user.key')
      g_prefs.getAcctsDB().setCurAcct(uk, r.key)
      #@onRefresh()
      ps=g_prefs.getAcctPropsDB().find(r.key) || {}
      bw.setUserData('cloud.acct', r , g_nfc)
      bw.setUserData('cloud.acct.props', ps , g_nfc)
      gcc.HtmlPage.cloud=null
      bw.loadURI('chrome://camungo/content/views/app.html')
  postEditDlg:(r,rc)-> @maybeSyncAcct()
  onEditAcct: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.EditAcctDlg(r).show( (rc)->me.postEditDlg(r,rc))
  onAddAcct: () ->
    me=this
    new gcc.AddAcctDlg().show( (c)-> me.addNewAcct(c) )
  onDelAcct: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelAcctDlg(r).show( (c)-> me.delAcct(c) )

#}

`

gcc.CloudAccounts=CloudAccounts;

})(window, window.document, jQuery);


`
