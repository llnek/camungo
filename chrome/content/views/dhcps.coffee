###
# file: dhcps.coffee
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

class DHCPSets extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.dhcps')
    @cm0= [ @tct('%id'), @tct('%dhcp.id'), @tct('%domain.name'),@tct('%dnss') ]
    @gid= 'dhcps-grid'
    @tids= [ @gid ]

  moniker: 'dhcps'
  id: 'dhcps-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.dhcp'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.dhcp'),icon:'minus'}
    icons.push {linkid: @btnid('linkvpc'), title: @l10n('%link.vpc'),icon:'clip'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')
  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    @onSync(svc,svc.listDHCPSets, [], @gid)
  uploadTable: (id,rc) ->
    rc.push(new gc.CloudAPI.Network.DHCPSet('default'))
    super(id,rc)
  fmtAsRow: (dtb,row) ->
    id=row.getProviderDhcpId()
    dns=row.getKey('domain-name-servers') || []
    dn=row.getKey('domain-name') || []
    [id,[id,id, dn.join(''), dns.join('') ]]
  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })
  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('linkvpc')).click( ()-> me.onLinkVPC() )
    $('#'+ @btnid('del')).click( () -> me.onDelDHCP() )
    $('#'+ @btnid('add')).click( ()-> me.onAddDHCP() )
  postLinkVPC:()->
  onLinkVPC: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.LinkDhcpSetDlg(r).show( (rc) -> me.postLinkVPC(rc))
  postAddDHCP:(rec)->
    @addOneRow( @dtbl(@gid), rec, @cache[@gid])
  onAddDHCP: () ->
    me=this
    new gcc.AddDhcpSetDlg().show( (r) -> me.postAddDHCP(r))
  postDelDHCP:(r,rc)->
    delete @cache[ @gid][r.getProviderDhcpId() ]
    @delOneRow( @gid)
  onDelDHCP: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      if r.getProviderDhcpId() isnt 'default'
        new gcc.DelDhcpSetDlg(r).show( (rc)-> me.postDelDHCP(r,rc))

#}

`

gcc.DHCPSets=DHCPSets;

})(window, window.document, jQuery);


`
