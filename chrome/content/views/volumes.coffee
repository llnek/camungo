###
# file: volumes.coffee
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
g_prefs=new gcx.Prefs(),
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class Volumes extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.vols')
    @cm0= [ @tct('%id'), @tct('%vol.id'), @tct('%state'), @tct('%vol.size'), @tct('%dc'), @tct('%vm.id'), @tct('%device'), @tct('%creation') ]
    @gid= 'vols-grid'
    @tids= [ @gid ]
    @dcs={}

  moniker: 'vols'
  id: 'vols-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )

  getTpl: () ->
    icons= @basicIcons()
    icons.push { title: @l10n('%new.vol'), icon:'add', linkid: @btnid('add') }
    icons.push { title: @l10n('%del.vol'), icon:'minus', linkid: @btnid('del') }
    icons.push { title: @l10n('%snap.vol'), icon:'files' , linkid: @btnid('snap')}
    icons.push { title: @l10n('%mount.vol'), icon:'mnt', linkid: @btnid('mount') }
    icons.push { title: @l10n('%unmount.vol'), icon:'unmnt', linkid: @btnid('unmount') }
    g_ute.trim [ @tableHtml(@gid), @footerMenu(icons) ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVolumeSupport()
    @onSync(svc,svc.listVolumes, [], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getProviderVolumeId()
    [id, [ id, id, row.getCurrentState(), row.getSizeInGigabytes(), row.getProviderDataCenterId(), row.getProviderVirtualMachineId() || '', row.getDeviceId() || '', row.getCreationTimestamp() ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelVol() )
    $('#'+ @btnid('add')).click( ()-> me.onAddVol() )
    $('#'+ @btnid('snap')).click( ()-> me.onSnapVol() )
    $('#'+ @btnid('mount')).click( ()-> me.onMntVol() )
    $('#'+ @btnid('unmount')).click( ()-> me.onUnmntVol() )

  postAddVol: (rec) -> @addOneRow( @dtbl( @gid), rec, @cache[ @gid] )
  onAddVol: () ->
    bw=g_xul.getBrowser()
    c=bw.getUserData('cloud.acct')
    dcs=bw.getUserData('cloud.'+c.vendor+'.dcs') || {}
    me=this
    new gcc.AddVolDlg(_.keys(dcs)).show( (rec) -> me.postAddVol(rec) )
  postDelVol: (rec)->
    delete @cache[ @gid][ rec.getProviderVolumeId() ]
    @delOneRow( @gid)
  onDelVol: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelVolDlg(r).show( (rc) -> me.postDelVol(r,rc) )

  postSnapVol: ()->
    # dont care
  onSnapVol: ()->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.SnapVolDlg(r).show( (rc) -> me.postSnapVol(r,rc) )

  postMntVol: (vo,rc)->
    r= @getCurRow( @dtbl(@gid) )
    m= @cache[ @gid]
    r= m[r[0]]
    r.setCurrentState( rc.getCurrentState())
    r.setDeviceId( rc.getDeviceId())
    r.setAttachedTimestamp(rc.getAttachedTimestamp() )
    r.setProviderVirtualMachineId( rc.getProviderVirtualMachineId() )
    @uploadTable( @gid, m)
  onMntVol: ()->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.MntVolDlg(r).show( (rc) -> me.postMntVol(r,rc) )

  postUnmntVol: (vo,rc)->
    r= @getCurRow( @dtbl(@gid) )
    m= @cache[ @gid]
    r= m[r[0]]
    r.setCurrentState('detaching')
    #r.setDeviceId('')
    #r.setProviderVirtualMachineId('')
    #r.setAttachedTimestamp(null)
    @uploadTable( @gid, m)
  onUnmntVol: ()->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.UnmntVolDlg(r).show( (rc) -> me.postUnmntVol(r,rc) )

#}

`

gcc.Volumes=Volumes;

})(window, window.document, jQuery);


`
