###
# file: pivotitem.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gc= genv.ComZotoh,
gcc=gc.Camungo,
gcx=genv.ComZotoh.XUL,
g_nfc=function() {},
g_prefs=new gcx.Prefs(),
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();

`

class PivotItem #{
  constructor: (hdr) ->
    @header= if is_alive(hdr) then @header=gcc.L10N(hdr) else ''
    @renderedOnce=false
    @cache={}
    @tids=null
  isRendered: () -> @renderedOnce
  getTitle: () -> @header
  busyWait: (flag) ->
    if flag then g_ute.maskOverlay() else g_ute.undoOverlay()
  onPivotChange: (metro, index) ->
    p=$('div.headers span.header[index="'+index+'"]', metro)
    if @header is p?.text() then @invalidate()
  onPivotChanged: (metro, index) ->
    p=$('div.headers span.header[index="'+index+'"]', metro)
    if @header is p?.text() then @onRefresh()
  addOneRow:(dt, row,bin)->
    [id, data] = @fmtAsRow(dt, row)
    dt.fnAddData( data)
    bin[ id ]=row
  fmtAsRow: (dt,row) -> ['', ['' ] ]
  delOneRow: (id) ->
    t= @dtbl(id)
    r= @getCurRowTR(t)
    if is_alive(r) then t.fnDeleteRow(r,null,true)
  invalidate: () ->
    if is_alive( @tids )
      # repaint all tables by clearing
      me=this
      _.each( @tids, (id)-> me.dtbl(id)?.fnClearTable() )
  onRefresh: () ->
  onSync: (svc, webfc, pms, id) ->
    @busyWait(true)
    pms= pms || []
    me=this
    nok=(err)->
      me.busyWait()
      fc=()-> new gcc.ErrorDlg().show(err?.getFaultMsg())
      genv.setTimeout(fc,0)
    ok=(rc) ->
      me.uploadTable(id,rc)
      me.busyWait()
    pms.push(PivotItem.CBS(ok,nok))
    webfc.apply(svc, pms)
  uploadTable: (id,rc) ->
    dt= @dtbl(id)
    cur=dt.fnGetData(0)
    purge=false
    if is_alive(cur)
      purge=true
      if $.isArray(cur) and cur.length is 0 then purge=false
    if purge then dt.fnClearTable()
    me=this
    c={}
    _.each(rc, (r) -> me.addOneRow(dt,r,c) )
    @cache[id ]=c
    @tableEvents(dt)
  render: () ->
    if not @renderedOnce
      $('#'+ @id).html( @getTpl())
      @postDraw()
      @setEvents()
      @renderedOnce=true
  postDraw: () ->
  setEvents: () ->
    me=this
    s= @btnid('ref-sync')
    $('#'+s).on('click', ()-> me.onRefresh() )
    s= @btnid('ref-home')
    $('#'+s).on('click', ()-> me.onHome() )
  onHome: () -> g_xul.getBrowser().loadURI('chrome://camungo/content/views/app.html')
  stdTblCBObj: (id) ->
    me=this
    { fnDrawCallback: ()-> me.onTableDraw(id) }
  btnid: (id) -> @moniker+'-'+id
  basicIcons: () ->
    me=this
    [ { linkid: @btnid('ref-home'), title: @l10n('%home'),icon:'home' }, { linkid: @btnid('ref-sync'), title: @l10n('%refresh'),icon:'refresh' } ]
  footerMenu: (icons) ->
    pms= { count: icons.length; menuicons: icons }
    Mustache.render(@fMenu, pms)
  fMenu:"""
    <div class="spacer100"></div>
    <div id="pivot-content-menu">
    <ul class="pivot-cm-icons pivot-cm-icons-{{count}}">
    {{#menuicons}}
      <li><a id="{{linkid}}" href="#" rel="tooltip" title="{{title}}">
          <img src='chrome://camungo/skin/images/{{icon}}.png'/></a></li>
    {{/menuicons}}
    </ul>
    </div>
  """

  tableHtml:(id) ->
    s= """
      <div class="vspacer6"></div>
      <div class="container-fluid">
         <table cellpadding="0" cellspacing="0" border="0" class="table table-bordered " id="{{gid}}" width="100%"></table>
      </div>
    """
    Mustache.render(s, {gid: id})

  tableEvents: (table) ->
    table.$( PivotItem.C_TR_ROWSELED)?.removeClass( PivotItem.C_ROWSELED)
    id= table.attr('id')
    em=$('#'+id+' tbody tr').off('contextmenu click')
    me=this
    cb=(e) ->
      r=table.fnGetData(this)
      tt=$(this)
      if not tt.hasClass( PivotItem.C_ROWSELED)
        table.$( PivotItem.C_TR_ROWSELED).removeClass( PivotItem.C_ROWSELED)
        tt.addClass( PivotItem.C_ROWSELED)
        sync=true
      me.onTableClicked(1,table, this, r)
    em.on('click',cb)
    cm=(e) ->
      tt=$(this)
      if tt.hasClass( PivotItem.C_ROWSELED)
        r=table.fnGetData(this)
        me.onTableClicked(3,table, this, r)
    em.on('contextmenu',cm)

  onTableDraw: (id) -> if @isRendered() then @tableEvents(@dtbl(id))
  onTableClicked: ( type,table, tr, r) ->
    if type is 1 then @onTableLClicked(table,tr,r)
    if type is 3 then @onTableRClicked(table,tr,r)
    ###
    g_xul.debug('type===='+ type)
    g_xul.debug( JSON.stringify(tr))
    g_xul.debug( JSON.stringify(r))
    ###
  onTableLClicked: (table,tr,r) ->
  onTableRClicked: (table,tr,r) ->
  getCurRowTR: (tableObj) -> 
    r= tableObj?.$( PivotItem.C_TR_ROWSELED)
    if is_alive(r) and r.length > 0 then r[0] else null
  getCurRow: (tableObj) -> 
    r=tableObj?._( PivotItem.C_TR_ROWSELED)
    if is_alive(r) and r.length > 0 then r[0] else null
  popCTMenuXXX: (row, hides) ->
    hides= hides || {}
    b=[]
    fc=(v,k)->
      h= _.has(hides,k)
      if h and hides[k] is -1
        v='****'
        h=false
      if not h
        v=g_xul.safeStr(v)
        if v.length > 48 then v=v.slice(0,48)+"..."
        s=['<tr>', '<td>', k, '</td>', '<td>', v, '</td>', '</tr>' ].join('')
        b.push(s)
    _.each(row,fc)
    th=['<thead><tr><th>',gcc.L10N('%name'),'</th><th>',gcc.L10N('%value'),'</th></tr></thead>'].join('')
    htm=['<table class="table table-bordered" >',th, '<tbody>',b.join(''),'</tbody>','</table>'].join('')
    dlg=$('#table-row-desc')
    $('.modal-body', dlg).empty().html(htm)
    dlg.modal({backdrop:'static'})
  dtbl: (id) -> $('#'+id).dataTable()
  l10n: (s,pms) -> gcc.L10N(s,pms)
  tct: (s,pms) -> { sTitle: gcc.L10N(s,pms) }

#}

PivotItem.C_ROWSELED='row_selected'
PivotItem.C_TR_ROWSELED='tr.'+ PivotItem.C_ROWSELED
PivotItem.BusyMask=null
PivotItem.CBS=(ok,nok)->
  gcx.XULLib.AjaxTweaks(new gc.Net.AjaxCBS(ok,nok),g_prefs.getREQWait())

# A pivot with 2 tables (parent-child)
class PivotItemPC extends PivotItem #{
  constructor: (hdr,pid,cid) ->
    super(hdr)
    @par_gid=pid
    @c_gid=cid
    @tids= [ @par_gid, @c_gid ]
  onTableDraw: (id) ->
    super(id)
    if @isRendered() then @dtbl(@c_gid).fnClearTable()
  postDraw: () ->
    gcc.Grid.create( @par_gid, @cm0, 10, @stdTblCBObj( @par_gid ) )
    gcc.Grid.createSimple( @c_gid, @cm1, 5)
    @cache[@par_gid]={}
    @cache[@c_gid]={}
    super()
  onTableLClicked: (table,tr,data) ->
    id=table.attr('id')
    if @par_gid is id then @onParClicked(table,data) else @onChildClicked(table,data)
  onTableRClicked: (table,tr,data) -> @popTableRow(table, data)
  popTableRow: (table, data) ->
    if @par_gid is table.attr('id') then @popPar( data[0]) else @popChild( data[0])
  popPar: (pk) ->
    row= @cache[ @par_gid][pk]
    if is_alive(row) then @popCTMenuXXX(row, @parFilter)
  popChild: (pk) ->
    row= @cache[ @c_gid][pk]
    if is_alive(row) then @popCTMenuXXX(row, @childFilter)
  onChildClicked: (table, data) ->
    pr=@getCurRow(  @dtbl( @par_gid) )
    cr=@cache[@c_gid][ data[0] ]
  showChildBusy:(flag,cid)->
    em=$('#'+cid)
    em=$('.pcpivot-child-section-loader',em)
    if flag
      em.html('<img src="chrome://camungo/skin/images/loader_16x51.gif"/>')
    else
      em.empty()
  midsect: """
      <div id="{{cid}}" class="pcpivot-child-section">
      <p>{{tbar}}:</p>
      <ul>
        {{#btns}}
        <li><a id="{{bid}}" href="#">{{btn}}</a></li>
        {{/btns}}
      </ul>
      <div class="pcpivot-child-section-loader" ></div>
      </div>
  """

#}



`

gcc.PivotItemPC=PivotItemPC;
gcc.PivotItem=PivotItem;

})(window, window.document, jQuery);


`
