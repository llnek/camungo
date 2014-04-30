###
# file: sshkeys.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gc=genv.ComZotoh,
gcc=gc.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class SSHKeys extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.keys')
    @cm0= [ @tct('%id'), @tct('%key.name'), @tct('%finger.print') ]
    @gid= 'sshkeys-grid'
    @tids= [ @gid ]

  moniker: 'sshkeys'
  id: 'sshkeys-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )

  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.key'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.key'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getIdentityServices().getShellKeySupport()
    @onSync(svc,svc.list, [], @gid)

  fmtAsRow: (dtb,row) ->
    prt=row.keyFingerprint
    id=row.keyName
    [ id, [id, id, prt ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelKey() )
    $('#'+ @btnid('add')).click( ()-> me.onAddKey() )

  postAddKey:(rec)-> @addOneRow( @dtbl(@gid), rec, @cache[@gid])
  onAddKey: () ->
    me=this
    new gcc.AddKeyDlg().show( (r) -> me.postAddKey(r))
  postDelKey:(rec)->
    delete @cache[ @gid][rec.keyName]
    @delOneRow( @gid)
  onDelKey: () ->
    r= @getCurRow( @dtbl(@gid) )
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      me=this
      new gcc.DelKeyDlg(r).show( (rec)-> me.postDelKey(rec))

#}

`

gcc.SSHKeys=SSHKeys;

})(window, window.document, jQuery);


`
