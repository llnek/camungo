###
# file: snapshots.coffee
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
g_ute=new gcc.Ute();


`

class Snapshots extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.snaps')
    @gid= 'snaps-grid'
    @tids= [ @gid ]
    @cm0=[ @tct('%id'),@tct('%snap.id'),@tct('%desc'),@tct('%vol.id'),@tct('%state'),@tct('%creation')  ]

  moniker: 'snaps'
  id: 'snaps-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl:() ->
    icons= @basicIcons()
    icons.push { title: @l10n('%new.vol'), icon: 'add', linkid: @btnid('add') }
    icons.push { title: @l10n('%del.snap'), icon: 'minus', linkid: @btnid('del') }
    g_ute.trim [ @tableHtml(@gid), @footerMenu(icons) ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getSnapshotSupport()
    @onSync(svc,svc.listSnapshots, [], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderSnapshotId()
    [id, [ id, id, row.getDescription() || '', row.getVolumeId(), row.getCurrentState(), row.getSnapshotTimestamp() || '' ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelSnap() )
    $('#'+ @btnid('add')).click( ()-> me.onAddVol() )

  postAddVol: () ->
  onAddVol: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.NewVolDlg(r).show( () -> me.postAddVol() )

  postDelSnap: (s0, rc) ->
    r= @getCurRow( @dtbl(@gid) )
    r=@cache[ @gid][ r[0]]
    r.setCurrentState('deleting')
    @addOneRow( @dtbl(@gid), r, @cache[@gid])
  onDelSnap: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelSnapDlg(r).show( (rc) -> me.postDelSnap(r, rc) )

#}

`

gcc.Snapshots=Snapshots;

})(window, window.document, jQuery);


`
