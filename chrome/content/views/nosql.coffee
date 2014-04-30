###
# file: nosql.coffee
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

class NoSQL extends gcc.PivotItemPC #{

  constructor: () ->
    super('%topic.nosql', 'nosql-grid', 'item-grid')
    @cm0= [ @tct('%id'), @tct('%db.id') ]
    @cm1= [ @tct('%id'), @tct('%item.name') ]

  moniker: 'nosql'
  id: 'nosql-tpl'
  cid: 'nsqltb'

  postDraw: () ->
    super()
    me=this
    $('#btn-additem').on('click', () -> me.onAddItem(false) )
    $('#btn-delitem').on('click', () -> me.onDelItem() )
    $('#btn-edtitem').on('click', () -> me.onAddItem(true) )

  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.db'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.db'),icon:'minus'}
    bObj=[]
    bObj.push { bid:'btn-additem', btn: @l10n('%add') }
    bObj.push { bid: 'btn-delitem', btn: @l10n('%remove') }
    bObj.push { bid: 'btn-edtitem', btn: @l10n('%edit') }
    s=Mustache.render( @midsect,{tbar: @l10n('%items'), cid: @cid, btns: bObj })
    g_ute.trim [ @tableHtml( @par_gid) , s,  @tableHtml(@c_gid), @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getPlatformServices().getKeyValueDatabaseSupport()
    @onSync(svc,svc.list, [ '' ], @par_gid)

  childFilter: {tags:0 }
  parFilter: {tags:0}

  fmtAsRow: (dtb,row) ->
    if dtb.attr('id') is @par_gid
      id=row.getProviderDatabaseId()
      data= [id, id ]
    else
      id=row.getName()
      data= [ id, id ]
    [ id, data ]

  onParClicked: (table,data) ->
    row=@cache[@par_gid][ data[0] ]
    svc=gcc.HtmlPage.cloud.getPlatformServices().getKeyValueDatabaseSupport()
    me=this
    nok=(err)-> me.showChildBusy(false, me.cid)
    ok=(rc)->
      me.showChildBusy(false, me.cid)
      me.uploadTable( me.c_gid, rc)
    cbs=gcc.PivotItem.CBS(ok,nok)
    @showChildBusy(true, @cid)
    svc.getItemNames(row.getProviderDatabaseId(),cbs)

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelDB() )
    $('#'+ @btnid('add')).click( ()-> me.onAddDB() )

  postDelItem: (r, rc)->
    delete @cache[@c_gid][r.getName()]
    @delOneRow(@c_gid)
  onDelItem: () ->
    p= @getCurRow( @dtbl(@par_gid) )
    r= @getCurRow( @dtbl(@c_gid) )
    me=this
    if is_alive(p) and is_alive(r)
      r= @cache[ @c_gid][r[0]]
      new gcc.DelSQLItemDlg(p[0], r).show( (rc) -> me.postDelItem(r, rc) )
  postAddItem:(flag,r, rc)->
    if not flag
      r=new gc.CloudAPI.Platform.KeyValueItem(rc)
      @addOneRow( @dtbl(@c_gid), r, @cache[ @c_gid])
  onAddItem: (flag) ->
    r= if flag then @getCurRow( @dtbl(@c_gid) ) else null
    p= @getCurRow( @dtbl(@par_gid) )
    me=this
    if is_alive(p)
      nm=if is_alive(r) then r[0] else null
      new gcc.AddSQLItemDlg(p[0],nm).show( (rc) -> me.postAddItem(flag, r, rc) )

  postAddDB:(rc) -> @addOneRow( @dtbl(@par_gid), rc, @cache[@par_gid])
  onAddDB: () ->
    me=this
    new gcc.AddNoSQLDlg().show( (rc)-> me.postAddDB(rc) )

  postDelDB: (r,rc)->
    delete @cache[@par_gid][r.getProviderDatabaseId()]
    @delOneRow(@par_gid)
  onDelDB: () ->
    r= @getCurRow( @dtbl(@par_gid) )
    me=this
    if is_alive(r)
      r= @cache[ @par_gid][r[0]]
      new gcc.DelNoSQLDlg(r).show( (rc) -> me.postDelDB(r, rc) )

#}

`

gcc.NoSQL=NoSQL;

})(window, window.document, jQuery);


`
