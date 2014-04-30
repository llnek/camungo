###
# file: scaling.coffee
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

class AutoScaling extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.scaling')
    @cm0= [ @tct('%id'), @tct('%name'),  @tct('%lcfg.id'),@tct('%scale.range.target'), @tct('%dc.cnt'), @tct('%vm.cnt'), @tct('%creation') ]
    @gid= 'scaling-grid'
    @tids= [ @gid ]

  moniker: 'scaling'
  id: 'scaling-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.asg'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.asg'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getAutoScalingSupport()
    @onSync(svc,svc.listScalingGroups, [''], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderScalingGroupId()
    [id, [ id, id, row.getProviderLaunchConfigurationId(), [row.getMinServers(), row.getMaxServers(), row.getTargetCapacity()].join('/'), row.getProviderDataCenterIds()?.length || 0, row.getProviderServerIds()?.length || 0, row.getCreationTimestamp() ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelGrp() )
    $('#'+ @btnid('add')).click( ()-> me.onAddGrp() )

  onAddGrp: () ->

  postDelGrp: (r, rc)->
    delete @cache[ @gid][ r.getProviderScalingGroupId() ]
    @delOneRow(@gid)
  onDelGrp: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelASGDlg(r).show( (rc) -> me.postDelGrp(r, rc) )

#}

`

gcc.AutoScaling=AutoScaling;

})(window, window.document, jQuery);


`
