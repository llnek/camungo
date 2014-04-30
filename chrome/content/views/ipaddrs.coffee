###
# file: ipaddrs.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gc=genv.ComZotoh,
gcc=gc.Camungo,
gcx=gc.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class IPAddrs extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.ipaddrs')
    @cm0= [ @tct('%id'), @tct('%ip.addr'), @tct('%vm.id') ]
    @gid= 'ipaddrs-grid'
    @tids=[ @gid ]

  moniker: 'ipaddrs'
  id: 'ipaddrs-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {title: @l10n('%new.ip'),icon:'add',linkid: @btnid('add') }
    icons.push {title: @l10n('%del.ip'),icon:'minus', linkid: @btnid('del') }
    icons.push {title: @l10n('%bind.ip'),icon:'tab-in', linkid: @btnid('bind') }
    icons.push {title: @l10n('%unbind.ip'),icon:'tab-out', linkid: @btnid('unbind') }
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getIpAddressSupport()
    @onSync(svc,svc.listPublicIpPool, [ false] , @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderIpAddressId()
    [ id, [id, id, row.getServerId() || '' ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelAddr() )
    $('#'+ @btnid('add')).click( ()-> me.onAddAddr() )
    $('#'+ @btnid('unbind')).click( ()-> me.noBindAddr() )
    $('#'+ @btnid('bind')).click( () -> me.bindAddr() )

  postNobindAddr: (r) ->
    m=@cache[ @gid]
    r=m[r.getProviderIpAddressId()]
    r.setServerId('')
    @uploadTable(@gid, _.values(m))

  noBindAddr: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      if is_alive(r) and g_ute.vstr( r.getServerId())
        new gcc.UnbindAddrDlg(r).show( (rc) -> me.postNobindAddr(r, rc) )

  postBindAddr: (r,vm) ->
    m=@cache[ @gid]
    r=m[r.getProviderIpAddressId()]
    r.setServerId(vm)
    @uploadTable(@gid, _.values(m))

  bindAddr: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      if is_alive(r) and not g_ute.vstr( r.getServerId() )
        new gcc.BindAddrDlg(r).show( (vm) -> me.postBindAddr(r,vm) )

  postAddAddr: (rec)-> @addOneRow( @dtbl(@gid), rec, bin)
  onAddAddr: () -> 
    me=this
    new gcc.AddAddrDlg().show( (rec) -> me.postAddAddr(rec) )

  postDelAddr: (rec)->
    delete @cache[@gid][ rec.getProviderIpAddressId() ]
    @delOneRow( @gid)
  onDelAddr: () ->
    r= @getCurRow( @dtbl(@gid) )
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      me=this
      new gcc.DelAddrDlg(r).show( (rec) -> me.postDelAddr(rec) )

#}

`

gcc.IPAddrs=IPAddrs;

})(window, window.document, jQuery);


`
