###
# file: subnets.coffee
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

class Subnets extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.subnets')
    @cm0= [ @tct('%id'), @tct('%subnet.id'),@tct('%vlan.id'),@tct('%state'),@tct('%cidr'), @tct('%dc') ]
    @gid= 'subnets-grid'
    @tids= [ @gid ]

  moniker: 'subnets'
  id: 'subnets-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.subnet'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.subnet'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    @onSync(svc,svc.listSubnets, [''], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderSubnetId()
    [id,[id,id,row.getProviderVlanId(),row.getCurrentState(),row.getCidr(),row.getProviderDataCenterId()]]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelSNet() )
    $('#'+ @btnid('add')).click( ()-> me.onAddSNet() )

  postAddSNet:(rec)-> @addOneRow( @dtbl(@gid), rec, @cache[@gid])
  onAddSNet: () ->
    me=this
    new gcc.AddSNetDlg().show( (r) -> me.postAddSNet(r))

  postDelSNet:(rec)->
    delete @cache[ @gid][rec.getProviderSubnetId()]
    @delOneRow( @gid)
  onDelSNet: () ->
    r= @getCurRow( @dtbl(@gid) )
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      me=this
      new gcc.DelSNetDlg(r).show( (rec)-> me.postDelSNet(rec))

#}

`

gcc.Subnets=Subnets;

})(window, window.document, jQuery);


`
