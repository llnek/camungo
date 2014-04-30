###
# file: images.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gcc=genv.ComZotoh.Camungo,
g_nfc=function(){},
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class Images extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.images')
    @cm0= [ @tct('%id'), @tct('%image.id'), @tct('%name'), @tct('%owner.id'), @tct('%state'), @tct('%arch'), @tct('%hypervisor'), @tct('%type'), @tct('%public'), @tct('%platform') ]
    @gid= 'images-grid'
    @tids= [ @gid ]

  moniker: 'images'
  id: 'images-tpl'

  # we add a bunch of filters to lessen the load on getting all images
  # as the result set is pretty huge
  postDraw: () ->
    gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
    $('#images-filter #ifilter-owner').val('self')
    $('#images-filter #ifilter-arch').val('x86_64')
    $('#images-filter #ifilter-type').val('ebs')
    $('#images-filter #ifilter-plfm').val('linux')
    me=this
    $('#images-filter select').on('change', ()->me.onFilter() )

  onFilter: ()-> @onRefresh()
  getTpl: () ->
    icons= @basicIcons()
    icons.push {title: @l10n('%launch.vm'),icon:'launch',linkid: @btnid('boot') }
    icons.push {title: @l10n('%share.image'),icon:'share', linkid: @btnid('share') }
    icons.push {title: @l10n('%new.lcfg'),icon:'adddoc', linkid: @btnid('lcfg') }
    v={self:@l10n('%owner.self'), others:@l10n('%owner.others'),shared:@l10n('%owner.shared'),amazon:@l10n('%owner.amazon'), b64:@l10n('%arch.64'),b32:@l10n('%arch.32'),istore:@l10n('%type.istore'),ebs:@l10n('%type.ebs'),linux:@l10n('%linux'),msft:@l10n('%windows'),free:@l10n('%public')}
    s=Mustache.render(@filterTpl,v)
    g_ute.trim [ s, @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  filterTpl: """
    <div id="images-filter">
      <form class="form-inline">
        <label class="controls"><select id="ifilter-owner"><option value="self">{{self}}</option><option value="shared">{{shared}}</option><option value="amazon">{{amazon}}</option><option value="others">{{others}}</option></select></label>
        <label class="controls"><select id="ifilter-arch"><option value="x86_64">{{b64}}</option><option value="i386">{{b32}}</option></select></label>
        <label class="controls"><select id="ifilter-type"><option value="instance-store">{{istore}}</option><option value="ebs">{{ebs}}</option></select></label>
        <label class="controls"><select id="ifilter-plfm"><option value="linux">{{linux}}</option><option value="windows">{{msft}}</option></select></label>
        <!--
        <label class="checkbox"><input type="checkbox" id="ifilter-pub"/><span>&nbsp;{{free}}</span></label>
          -->
      </form>
    </div>
  """

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getImageSupport()
    owner=$('#images-filter #ifilter-owner').val()
    arch=$('#images-filter #ifilter-arch').val()
    type=$('#images-filter #ifilter-type').val()
    pf=$('#images-filter #ifilter-plfm').val()
    args={platform: pf, type: type, arch: arch, owner: owner }
    @onSync(svc,svc.listImages, [ args ], @gid)

  fmtAsRow: (dtb,row) ->
    p= if row.getTag('isPublic') is true then @l10n('%yes') else @l10n('%no')
    id= row.getProviderMachineImageId()
    [ id, [ id, id, g_ute.to_s(row.getName()), g_ute.to_s(row.getProviderOwnerId()), row.getCurrentState(), g_ute.to_s(row.getArchitecture()), row.getTag('hypervisor'), row.getTag('rootDeviceType'), p, g_ute.to_s(row.getPlatform()) ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('boot')).click( () -> me.onBootImage() )
    $('#'+ @btnid('share')).click( ()-> me.onShareImage() )
    $('#'+ @btnid('lcfg')).click( ()-> me.onAddLCfg() )

  postAddLCfg: (rc)->
  onAddLCfg: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.AddLCfgDlg(r).show((rc) -> me.postAddLCfg(rc) )

  postBootImage: () ->
  onBootImage: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.BootImageDlg(r).show( (rc)-> me.postBootImage(r,rc) )

  postShareImage: (r0, rc) ->
    if r0.getTag('isPublic') isnt rc
      m=@cache[ @gid]
      r0=m[r0.getProviderMachineImageId()]
      r0.addTag('isPublic',rc)
      @uploadTable(@gid, m)

  onShareImage: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.ShareImageDlg(r).show( (rc)-> me.postShareImage(r,rc) )

#}

`

gcc.Images=Images;

})(window, window.document, jQuery);


`
