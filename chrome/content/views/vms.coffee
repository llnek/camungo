###
# file: vms.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_prefs=new gcx.Prefs(),
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class VirtualMachines extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.vms')
    @cm0= [ @tct('%id'), @tct('%vm.id'), @tct('%image.id'), @tct('%type'), @tct('%state'), @tct('%dc'), @tct('%launch.time') ]
    @gid= 'vms-grid'
    @tids= [ @gid ]

  moniker: 'vms'
  id: 'vms-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {title: @l10n('%vm.start'),icon:'power', linkid: @btnid('power') }
    icons.push {title: @l10n('%vm.pause'),icon:'standby', linkid: @btnid('stop') }
    icons.push {title: @l10n('%vm.halt'),icon:'halt', linkid: @btnid('halt') }
    icons.push {title: @l10n('%vm.console'),icon:'terminal', linkid: @btnid('getcons') }
    icons.push {title: @l10n('%vm.ssh'),icon:'connect', linkid: @btnid('sshcmd') }
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    @onSync(svc,svc.listVirtualMachines, [ {} ], @gid)

  fmtAsRow: (dtb,row) ->
    pid= row.getProduct()?.getProductId() || ''
    id=row.getProviderVirtualMachineId()
    [ id, [id, id, row.getProviderMachineImageId(), pid, row.getCurrentState(), row.getProviderDataCenterId(), row.getLastBootTimestamp() ? '' ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('getcons')).click( ()-> me.onGetConsole() )
    $('#'+ @btnid('halt')).click( () -> me.onDelVm() )
    $('#'+ @btnid('stop')).click( ()-> me.onPauseVm() )
    $('#'+ @btnid('power')).click( ()-> me.onBootVm() )
    $('#'+ @btnid('sshcmd')).click( ()-> me.onSSHVm() )

  postSSHVm: (v0, rc) ->
    if v0.getCurrentState() isnt rc.getCurrentState()
      @addOneRow( @dtbl(@gid), rc, @cache[@gid])
    host=rc.getPublicDnsAddress()
    a=rc.getPublicIpAddresses()
    if is_alive(a) and a.length > 0 then host= a[0]
    kn=rc.getTag('keyName')
    g_prefs.sshHost(host,kn)
  onSSHVm: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.SSHVmDlg(r).show( (rc) -> me.postSSHVm(r,rc) )

  postPauseVm: (r0) ->
    m= @cache[ @gid]
    r= m[r0.getProviderVirtualMachineId() ]
    r.setCurrentState('stopping')
    @uploadTable( @gid, m)
  onPauseVm: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.PauseVmDlg(r).show( (rc) -> me.postPauseVm(r,rc) )

  postDelVm: (r0) ->
    m= @cache[ @gid]
    r= m[r0.getProviderVirtualMachineId() ]
    r.setCurrentState('shutting-down')
    @uploadTable( @gid, m)
  onDelVm: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.HaltVmDlg(r).show( (rc) -> me.postDelVm(r,rc) )

  postBootVm: (r0, rc) ->
    m= @cache[ @gid]
    r= m[r0.getProviderVirtualMachineId() ]
    s= rc.getCurrentState()
    if 'running' is s or 'stopped' is s
      if 'running' is s then r.setCurrentState('rebooting')
      if 'stopped' is s then r.setCurrentState('pending')
      @uploadTable( @gid, m)
  onBootVm: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.BootVmDlg(r).show( (rc) -> me.postBootVm(r,rc) )

  postGetConsole: (rc)->
  onGetConsole: ()->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.GetVmConsDlg(r).show( () -> me.postGetConsole() )

#}

`

gcc.VirtualMachines=VirtualMachines;

})(window, window.document, jQuery);


`
