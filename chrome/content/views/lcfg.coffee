###
# file: lcfg.coffee
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

class LaunchCfg extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.lcfg')
    @cm0= [ @tct('%id'), @tct('%name'), @tct('%image.id'), @tct('%type'), @tct('%key.name'), @tct('%vm.watch') ]
    @gid= 'lcfg-grid'
    @tids= [ @gid ]

  moniker: 'lcfg'
  id: 'lcfg-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.asg'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.lcfg'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getAutoScalingSupport()
    @onSync(svc,svc.listLaunchConfigurations, [''], @gid)

  fmtAsRow: (dtb,row) ->
    mon= if row.getTag('InstanceMonitoring') is true then @l10n('%yes') else @l10n('%no')
    id= row.getProviderLaunchConfigurationId()
    [id, [id, id, row.getProviderImageId(), row.getServerSizeId(), row.getTag('KeyName')||'', mon ]]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelCfg() )
    $('#'+ @btnid('add')).click( ()-> me.onAddASG() )

  postAddASG: (rc)->
  onAddASG: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.AddASGDlg(r).show((rc) -> me.postAddASG(rc) )

  postDelCfg: (r, rc)->
    delete @cache[ @gid][ r.getProviderLaunchConfigurationId() ]
    @delOneRow(@gid)
  onDelCfg: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelLCfgDlg(r).show( (rc) -> me.postDelCfg(r, rc))


#}

`

gcc.LaunchCfg=LaunchCfg;

})(window, window.document, jQuery);


`
