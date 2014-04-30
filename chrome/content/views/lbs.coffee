###
# file: lbs.coffee
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

class LoadBalancers extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.lbs')
    @cm0= [ @tct('%id'), @tct('%name'), @tct('%addr'), @tct('%dc.cnt'), @tct('%subnet.cnt'),@tct('%vm.cnt'), @tct('%creation') ]
    @gid= 'lbs-grid'
    @tids= [ @gid ]

  moniker: 'lbs'
  id: 'lbs-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.lb'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.lb'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getLoadBalancerSupport()
    @onSync(svc,svc.listLoadBalancers, [], @gid)

  fmtAsRow: (dtb,row) ->
    id= row.getProviderLoadBalancerId()
    [id, [ id, id, row.getAddress(), row.getProviderDataCenterIds().length, row.getTag('Subnets').length,row.getProviderServerIds().length, row.getCreationTimestamp() ]]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelELB() )
    $('#'+ @btnid('add')).click( ()-> me.onAddELB() )

  postAddELB:(rc)-> @addOneRow( @dtbl(@gid), rc, @cache[@gid] )
  onAddELB: () ->
    me=this
    new gcc.AddELBDlg().show( (rc) -> me.postAddELB(rc) )

  postDelELB:(r,rc)->
    delete @cache[@gid][r.getProviderLoadBalancerId()]
    @delOneRow( @gid)
  onDelELB: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelELBDlg(r).show( (rc) -> me.postDelELB(r, rc))

#}

`

gcc.LoadBalancers=LoadBalancers;

})(window, window.document, jQuery);


`
