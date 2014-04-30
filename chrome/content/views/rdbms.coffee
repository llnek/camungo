###
# file: rdbms.coffee
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

class RDBMS extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.rdbms')
    @cm0= [ @tct('%id'), @tct('%db.id'), @tct('%db.engine'), @tct('%host'),@tct('%port'), @tct('%state'), @tct('%db.size'),@tct('%dc') ]
    @gid= 'rdbms-grid'
    @tids= [ @gid ]

  moniker: 'rdbms'
  id: 'rdbms-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.db'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.db'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getPlatformServices().getRelationalDatabaseSupport()
    @onSync(svc,svc.listDatabases, [], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderDatabaseId()
    [ id, [id, id, row.getEngine(),row.getHostName(), row.getHostPort(), row.getCurrentState(), row.getAllocatedStorageInGb(), row.getProviderDataCenterId()  ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelDB() )
    $('#'+ @btnid('add')).click( ()-> me.onAddDB() )

  postAddDB:(rc)-> @addOneRow( @dtbl(@gid), rc, @cache[@gid] )
  onAddDB: () ->
    me=this
    new gcc.AddRDBDlg().show( (rc)->me.postAddDB(rc))

  postDelDB:(r,rc)->
    delete @cache[@gid][r.getProviderDatabaseId()]
    @delOneRow(@gid)
  onDelDB: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelRDBDlg(r).show( (rc)-> me.postDelDB(r,rc))

#}

`

gcc.RDBMS=RDBMS;

})(window, window.document, jQuery);


`
