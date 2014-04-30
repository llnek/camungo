###
# file: gates.coffee
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

class Gateways extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.gates')
    @cm0= [ @tct('%id'), @tct('%gate.id'), @tct('%vlan.id'),@tct('%state'),@tct('%type') ]
    @gid= 'gates-grid'
    @tids= [ @gid ]

  moniker: 'gates'
  id: 'gates-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.gate'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.gate'),icon:'minus'}
    icons.push {linkid: @btnid('addconn'), title: @l10n('%new.conn'),icon:'link'}
    icons.push {linkid: @btnid('linkvpc'), title: @l10n('%link.vpc'),icon:'tab-in'}
    icons.push {linkid: @btnid('unlinkvpc'), title: @l10n('%unlink.vpc'),icon:'tab-out'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    @onSync(svc,svc.listGateways, [], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderVpnGatewayId()
    a= row.getTag('attachments') || []
    vpc=''
    if a.length > 0 then vpc=a[0].vpcId
    [id, [ id, id, vpc,row.getCurrentState() || '', row.getCategory() ]]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('unlinkvpc')).click( ()-> me.onUnlinkVPC() )
    $('#'+ @btnid('linkvpc')).click( ()-> me.onLinkVPC() )
    $('#'+ @btnid('addconn')).click( ()-> me.onAddConn() )
    $('#'+ @btnid('del')).click( () -> me.onDelGate() )
    $('#'+ @btnid('add')).click( ()-> me.onAddGate() )

  postUnlinkVPC:(r,rc)->
  onUnlinkVPC: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      m= @cache[ @gid]
      r= m[r[0]]
      if r.getCategory() isnt 'private'
        new gcc.UnlinkVPCDlg(r).show( (rc) -> me.postUnlinkVPC(r, rc))

  postLinkVPC:(r,rc)->
  onLinkVPC: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      m= @cache[ @gid]
      r= m[r[0]]
      if r.getCategory() isnt 'private'
        new gcc.LinkVPCDlg(r).show( (rc) -> me.postLinkVPC(r, rc))

  postAddConn:(r,rc)->
    fc=()-> new gcc.VPNConnStylesDlg(rc).show()
    genv.setTimeout( fc,500)
  onAddConn: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      m= @cache[ @gid]
      r= m[r[0]]
      if r.getCategory() isnt 'internet'
        new gcc.AddVpnDlg(r,_.values(m)).show( (rc) -> me.postAddConn(r, rc))

  postAddGate:(rec)->
    @addOneRow( @dtbl(@gid), rec, @cache[@gid])
  onAddGate: () ->
    me=this
    new gcc.AddGateWDlg().show( (r) -> me.postAddGate(r))

  postDelGate:(r,rc)->
    delete @cache[ @gid][r.getProviderVpnGatewayId()]
    @delOneRow( @gid)
  onDelGate: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelGateWDlg(r).show( (rc)-> me.postDelGate(r,rc))

#}

`

gcc.Gateways=Gateways;

})(window, window.document, jQuery);


`
