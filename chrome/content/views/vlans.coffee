###
# file: vlans.coffee
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

class VLANs extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.vlans')
    @cm0= [ @tct('%id'), @tct('%vlan.id'), @tct('%state'), @tct('%cidr')  ]
    @gid= 'vlans-grid'
    @tids=[ @gid ]

  moniker: 'vlans'
  id: 'vlans-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.vlan'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.vlan'),icon:'minus'}
    icons.push {linkid: @btnid('addsubnet'), title: @l10n('%new.subnet'),icon:'net'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    @onSync(svc,svc.listVlans, [], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderVlanId()
    [ id, [id, id, row.getCurrentState(), row.getCidr() ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('addsubnet')).click( ()-> me.onAddSNet() )
    $('#'+ @btnid('del')).click( () -> me.onDelVLan() )
    $('#'+ @btnid('add')).click( ()-> me.onAddVLan() )

  postAddSNet: (rc)->
  onAddSNet:()->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.AddSNetDlg(r).show( (rc) -> me.postAddSNet(rc))

  onAddVLan: () -> new gcc.AddVLanDlg().show()
  onDelVLan: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelVLanDlg(r).show()

#}

`

gcc.VLANs=VLANs

})(window, window.document, jQuery);


`
