###
# file: conns.coffee
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

class VlanConns extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.conns')
    @cm0= [ @tct('%id'), @tct('%conn.id'),@tct('%state'),@tct('%protocol'),@tct('%vlan.id'),@tct('%prv.gate.id') ]
    @gid= 'conns-grid'
    @tids= [ @gid ]

  moniker: 'conns'
  id: 'conns-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    #icons.push {linkid: @btnid('add') , title: @l10n('%new.conn'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.conn'),icon:'minus'}
    icons.push {linkid: @btnid('expcfg'), title: @l10n('%exp.cfg'),icon:'doc'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')
  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    @onSync(svc,svc.listVPNs, [], @gid)
  fmtAsRow: (dtb,row) ->
    id=row.getProviderVpnId()
    [id,[id, id, row.getCurrentState(), row.getProtocol(), row.getTag('vpnGatewayId'), row.getTag('customerGatewayId') ]]
  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })
  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('expcfg')).click( () -> me.onExportCfg() )
    $('#'+ @btnid('del')).click( () -> me.onDelConn() )
    #$('#'+ @btnid('add')).click( ()-> me.onAddConn() )

  onExportCfg: ()->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.VPNConnStylesDlg(r).show()

  postAddConn:(rec)->
    @addOneRow( @dtbl(@gid), rec, @cache[@gid])
  onAddConn: () ->
    me=this
    new gcc.AddVpnDlg().show( (r) -> me.postAddConn(r))
  postDelConn:(r,rc)->
    delete @cache[ @gid][r.getProviderVpnId()]
    @delOneRow( @gid)
  onDelConn: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelVpnDlg(r).show( (rc)-> me.postDelConn(r,rc))

#}

`

gcc.VlanConns=VlanConns;

})(window, window.document, jQuery);


`
