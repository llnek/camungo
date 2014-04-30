###
# file: mainnav.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var
g_nfc=function(){},
gc=genv.ComZotoh,
gcx=gc.XUL,
gcc=gc.Camungo,
g_prefs=new gcx.Prefs(),
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class MainNav extends gcc.HtmlPage #{
  constructor: () ->
    super()
    @iniz()
    @id= 'main-nav'
  preDraw: () ->
    nav=$('#'+@id)
    $('div.networking h2',nav).text( @l10n('%nav.netwk'))
    $('div.networking #nw-nw1',nav).text( @l10n('%nav.vlans'))
    $('div.networking #nw-nw2',nav).text( @l10n('%nav.fwalls'))
    $('div.networking #nw-nw3',nav).text( @l10n('%nav.keys'))
    $('div.networking #nw-nw4',nav).text( @l10n('%nav.ips'))
    $('div.machines h2',nav).text( @l10n('%nav.machs'))
    $('div.machines #ma-ma1',nav).text( @l10n('%nav.vms'))
    $('div.machines #ma-ma2',nav).text( @l10n('%nav.images'))
    $('div.machines #ma-ma3',nav).text( @l10n('%nav.scale'))
    $('div.machines #ma-ma4',nav).text( @l10n('%nav.lcfg'))
    $('div.machines #ma-ma5',nav).text( @l10n('%nav.lbs'))
    $('div.storage h2',nav).text( @l10n('%nav.storage'))
    $('div.storage #cf-cf1',nav).text( @l10n('%nav.vols'))
    $('div.storage #cf-cf2',nav).text( @l10n('%nav.snaps'))
    $('div.storage #cf-cf3',nav).text( @l10n('%nav.cfiles'))
    $('div.messaging h2',nav).text( @l10n('%nav.msgs'))
    $('div.messaging #mg-mg1',nav).text( @l10n('%nav.monitoring'))
    $('div.messaging #mg-mg2',nav).text( @l10n('%nav.queues'))
    $('div.messaging #mg-mg3',nav).text( @l10n('%nav.pushsvcs'))
    $('div.databases h2',nav).text( @l10n('%nav.dbases'))
    $('div.databases #db-db1', nav).text( @l10n('%nav.rdbs'))
    $('div.databases #db-db2',nav).text( @l10n('%nav.nosql'))
    $('#app-settings').text(@l10n('%settings'))
    $('#app-about').text(@l10n('%about'))
    @maybePostHints()
  maybePostHints: () ->
    bw=g_xul.getBrowser()
    ps=bw.getUserData('cloud.acct.props')
    c=bw.getUserData('cloud.acct')
    key=bw.getUserData('cloud.user.key')
    msg=''
    em=$('#content div.title').empty()
    if not g_ute.vstr(c.vendor)
      cnt= g_prefs.getAcctsDB().countAccts(key)
      msg= @l10n( if cnt is 0 then '%err.zero.acct' else '%err.no.acct')
      msg=Mustache.render(@titleAlert, {msg:msg})
    if g_ute.vstr(msg)
      em.html( g_ute.trim(msg))
    else
      @showSomeInfo(em,c)
  showSomeInfo: (em,c) ->
    htm=Mustache.render( @titleInfo, {'lbl-vendor': @l10n('%cloud.prvdr'), 'lbl-acct': @l10n('%cloud.acct'),'conning':@l10n('%conn.ing'), 'vendor': @l10n(c.vendor) , 'acctno': gcc.CloudVendor.normalize(c.vendor,c.acctno) })
    em.html(g_ute.trim( htm))
    switch c.vendor
      when gcc.CloudVendor.AWS then @showAWSInfo(em,c)
      else @cancelCloudLoader(em)
  showAWSInfo: (em,c) ->
    rgs=g_xul.getBrowser().getUserData('cloud.'+c.vendor+'.regions')
    gcc.HtmlPage.inizCloud()
    me=this
    if is_alive(rgs)
      @dispAWSInfo2(em,c,rgs)
    else
      ws= g_prefs.getREQWait()
      nok=(err)-> me.dispAWSInfoError(em,c,err)
      ok= (rc)-> me.dispAWSInfo(em,c,rc)
      cbs=new gc.Net.AjaxCBS(ok,nok)
      cbs.waitSecs=ws
      gcc.HtmlPage.cloud.getDataCenterServices().listRegions(cbs)
  onLoadDcs: (rc) ->
    fc=(memo, v)->
      memo[v.getProviderDataCenterId()] = v.isAvailable()
      memo
    dcs= _.reduce(rc, fc, {})
    bw=g_xul.getBrowser()
    c=bw.getUserData('cloud.acct')
    bw.setUserData('cloud.'+c.vendor+'.dcs', dcs, g_nfc)
  bgLoadDcs: (rg) ->
    me=this
    ok=(rc)-> me.onLoadDcs(rc)
    cbs=new gc.Net.AjaxCBS(ok)
    cbs.waitSecs=g_prefs.getREQWait()
    gcc.HtmlPage.cloud.getDataCenterServices().listDataCenters(rg,cbs)
  dispAWSInfoError: (em,c,err) ->
    ci=$('#title-cloud-info',em).empty()
    htm=Mustache.render(@awsLPageError, { msg: err?.getFaultMsg() } )
    ci.html( g_ute.trim(htm))
  dispAWSInfo: (em,c,data) ->
    fc=(memo,r) ->
      memo[ r.getProviderRegionId() ] = r.getTag('regionEndpoint')
      memo
    rgs=_.reduce(data,fc,{})
    g_xul.getBrowser().setUserData('cloud.'+c.vendor+'.regions', rgs, g_nfc)
    @dispAWSInfo2(em,c, rgs)
  dispAWSInfo2: (em,c, rgs) ->
    ps=g_xul.getBrowser().getUserData('cloud.acct.props')
    rr=ps.bagOfProps?.region
    use1=''
    found=false
    me=this
    fc=(r)->
      if r is 'us-east-1' then use1= r
      if r is rr then found=true
      { 'option': r }
    arr= _.map( _.keys(rgs).sort(), fc)
    ci=$('#title-cloud-info',em).empty()
    htm=Mustache.render( @ddListTpl, { options: arr })
    htm=Mustache.render( @awsLPageInfo, { 'lbl-region': @l10n('%region'), 'region-list': htm } )
    ci.html(g_ute.trim(htm))
    if not found
      if arr.length > 0 then rr= arr[0].option
      if g_ute.vstr(use1) then rr=use1
    if arr.length > 0
      em=$('select',em)
      em.val(rr)
      em.on('change', (e) -> me.onAWSRegionChange(em) )
      @bgLoadDcs(rr)
  onAWSRegionChange: (em) -> @resyncRegion( em.val() )
  resyncRegion: (rg)->
    bw=g_xul.getBrowser()
    acct=bw.getUserData('cloud.acct')
    ps=bw.getUserData('cloud.acct.props')
    ps.bagOfProps.region=rg
    g_prefs.getAcctPropsDB().edit(acct.key,ps)
    gcc.HtmlPage.inizCloud(true)
    @bgLoadDcs(rg)

  awsLPageError: """
    <div class="error-red-text">{{{msg}}}</div>
  """

  awsLPageInfo: """
    <form class="form-inline" ><table>
    <tr><td>{{lbl-region}}:</td><td>{{{region-list}}}</td></tr>
    </table>
    </form>
  """

  ddListTpl: """
    <select>
      {{#options}}
      <option value="{{option}}">{{option}}</option>
      {{/options}}
    </select>
  """

  cancelCloudLoader: (em) -> $('#title-cloud-info',em).empty()

  titleAlert: """
    <div class="alert alert-error">{{{msg}}}</div>
  """

  titleInfo: """
    <div id="title-info"><div class="">
      <table id="title-basic-info">
      <tr><td>{{lbl-vendor}}:</td><td>{{vendor}}</td></tr>
      <tr><td>{{lbl-acct}}:</td><td>{{acctno}}</td></tr>
      </table>

      <div id="title-cloud-info">
        <span style="display:block;">{{conning}}...</span>
        <img src="chrome://camungo/skin/images/loader_16x51.gif"/>
      </div>
    </div>
    </div>
  """

  draw: () ->
    InitBubbleNav($)
    me=this
    $('#' + @id + ' li.nav-item').on('click', (e) -> me.onClickItem(e) )
    $('#app-settings').on('click', () -> me.onSettings() )
    $('#app-about').on('click', ()->me.onAbout())

  uriPath: "chrome://camungo/content/views/"
  onAbout:()-> new gcc.AboutDlg().show()
  onSettings: () ->
    g_xul.getBrowser().loadURI( @uriPath+ 'settings-view.html')
  onClickItem: (evt) ->
    c=$(evt.delegateTarget)
    a=$('a',c).attr('id')
    t=c.parent().attr('data-target')
    if 'networks-view' is t and 'nw-nw1' is a
      t='vpcs-view'
      a='vv-vv1'
    t= [ @uriPath,t,'.html'].join('')
    bw=g_xul.getBrowser()
    bw.setUserData('nav.view.hint', a, g_nfc)
    bw.loadURI(t)
  iniz: () ->

#}

`

gcc.MainNav=MainNav;

})(window, window.document, jQuery);


`
