###
# file: queues.coffee
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

class Queues extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.queues')
    @cm0= [ @tct('%id'), @tct('%queue.id') ]
    @gid= 'queues-grid'
    @tids= [ @gid ]

  moniker: 'queues'
  id: 'queues-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.queue'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.queue'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getPlatformServices().getMessageQueueSupport()
    @onSync(svc,svc.list, [ '' ], @gid)

  fmtAsRow: (dtb,row) ->
    id=row
    [ id, [id, id ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelQueue() )
    $('#'+ @btnid('add')).click( ()-> me.onAddQueue() )

  postAddQ: (rc) -> @addOneRow( @dtbl( @gid), rc.result, @cache[ @gid] )
  onAddQueue: () ->
    me=this
    new gcc.AddMsgQDlg().show( (rc) -> me.postAddQ(rc))

  postDelQ: (r, rc) ->
    delete @cache[ @gid][r]
    @delOneRow(@gid)
  onDelQueue: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelMsgQDlg(r).show( (rc) -> me.postDelQ(r, rc) )

#}

`

gcc.Queues=Queues;

})(window, window.document, jQuery);


`
