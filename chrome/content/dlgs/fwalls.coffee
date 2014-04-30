###
# file: fwalls.coffee
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

class AddFwallFm extends gcc.HtmlForm #{
  constructor: () -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld4' and value is '-1' and $('#fld3', ctx).attr('checked') 
      @flagError(ctx,flags,id)
  postShow:(dlg)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    me=this
    nok=(err)->
      me.clrDDList('fld4',dlg)
      me.dispErrorDDList('fld4',dlg)
    ok= (rc)->
      h=_.map(rc, (r) -> me.htmOneDDListOpt(r.getProviderVlanId())).join('')
      $('#fld4',dlg).empty().html(h)
    svc.listVlans( gcc.PivotItem.CBS( ok,nok))
    super(dlg)
  doSave:(ctx,ok,nok) ->
    n=g_ute.trim( $('#fld1', ctx).val())
    d=$('#fld2', ctx).val()
    v= if $('#fld3', ctx).attr('checked') then $('#fld4', ctx).val() else ''
    svc=gcc.HtmlPage.cloud.getNetworkServices().getFirewallSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    if g_ute.vstr(v)
      svc.createInVLAN(n,d,v,cbs)
    else
      svc.create(n,d,cbs)
#}
class AddFwallDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.fwall') })
  onOK: (ctx,rec) -> @callerCB?(rec)
  show: (cb) ->
    f=new AddFwallFm()
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%name'),width:'dlg-s8s' }
    args.flds.fld2= { reqd:1,lbl: @l10n('%desc'),width:'dlg-s8s' }
    f3cb=()->
      em=$('#'+me.getId()+' #fld4')
      if $(this).is(':checked') then em.show() else em.hide()
    args.flds.fld3= { kind:'cbox', lbl: @l10n('%bind.vpc'), bind: {cb: f3cb, evt:'change'} }
    a=[{disp:@l10n('%load.wait'), value:'-1'}]
    args.flds.fld4= { kind:'list', hide:1, choices: a }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelFwallFm extends gcc.HtmlForm #{
  constructor: (@fw) -> super()
  doSave:(ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getFirewallSupport()
    svc.delete(@fw.getName(),gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelFwallDlg extends gcc.ModalDlg #{
  constructor: (@fw) -> super({ title: gcc.L10N('%del.fwall') })
  onOK: (ctx) -> @callerCB?(@fw)
  show: (cb) ->
    f=new DelFwallFm(@fw)
    @callerCB=cb
    me=this
    args={ flds:{}}
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',value: @fw.getName(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelFwallRuleFm extends gcc.HtmlForm #{
  constructor: (@fw,@rule) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getFirewallSupport()
    cidr=@rule.getCidr()
    g=@rule.getGroup()
    args=[]
    if g.length >= 2
      args=[  @fw.getProviderFirewallId(), g[1], g[0] ]
      api=svc.revokeAccess
    else
      args=[ @fw.getName(), @fw.getProviderFirewallId(), cidr]
      api=svc.revoke
    args.push @rule.getProtocol()
    args.push @rule.getStartPort()
    args.push @rule.getEndPort()
    args.push gcc.PivotItem.CBS(ok,nok)
    api.apply(svc, args)
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelFwallRuleDlg extends gcc.ModalDlg #{
  constructor: (@fw,@rule) -> super({ title: gcc.L10N('%revoke.access') })
  onOK:() -> @callerCB?()
  show: (cb) ->
    g= @rule.getGroup().join('|').replace(/\|$/,'')
    pr= @rule.getProtocol()?.toString() || ''
    f=new DelFwallRuleFm(@fw,@rule)
    @callerCB=cb
    me=this
    args={flds:{}}
    s= [@fw.getName(),@fw.getProviderFirewallId() ].join(' | ').trim()
    s= s.replace(/\|$/g,'').trim()
    args.flds.fld1= { lbl: @l10n('%grp.name.id'),width:'dlg-s8s',value: s, off:1 }
    s= [ pr, @rule.getCidr() ].join(' | ').trim()
    s= s.replace(/\|$/g,'').trim()
    args.flds.fld2= { lbl: @l10n('%protocol.cidr'),width:'dlg-s8s',value: s, off:1 }
    s= [ @rule.getStartPort(), @rule.getEndPort() ].join(' / ').trim()
    t= if pr is 'icmp' then '%type.code' else '%port.range'
    args.flds.fld3= { lbl: @l10n(t),width:'dlg-s8s',value: s, off:1 }
    args.flds.fld4= { lbl: @l10n('%user.grp'),width:'dlg-s8s',value: g, off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class AddFwallRuleFm extends gcc.HtmlForm #{
  constructor: (@fw) -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld1'
      r=value.match( /([^\/]+)\/{1}([^\/]+)/ )
      if not is_alive(r) or r.length isnt 3 or isNaN( g_ute.trim(r[1])) or isNaN( g_ute.trim(r[2])) then @flagError(ctx,flags,id)
    if id is 'fld4'
      if value is 'CIDR'
        if g_ute.trim($('#fld5',ctx).val()) is '' then @flagError(ctx,flags,'fld5')
      else
        if g_ute.trim($('#fld6',ctx).val()) is '' and g_ute.trim($('#fld7',ctx).val()) is ''
          @flagError(ctx,flags,'fld6')
          @flagError(ctx,flags,'fld7')
  doSave:(ctx,ok,nok)->
    pc= g_ute.trim($('#fld3',ctx).val())
    pc=gc.CloudAPI.Network.Protocol.valueOf(pc)
    #reg=/(0|[1-9][0-9]*)[\s]*\.{2}[\s]*(0$|[1-9][0-9]*)/
    reg=/([^\/]+)\/{1}([^\/]+)/
    s= g_ute.trim($('#fld1',ctx).val())
    r=s.match(reg)
    [lf,rt]=[ 0, 0]
    if is_alive(r) and r.length is 3
      lf=Number( g_ute.trim(r[1]))
      rt=Number( g_ute.trim(r[2]))
    src= g_ute.trim($('#fld4',ctx).val())
    svc=gcc.HtmlPage.cloud.getNetworkServices().getFirewallSupport()
    args=[ @fw.getName(),@fw.getProviderFirewallId()]
    if 'CIDR' is src
      args.push g_ute.trim($('#fld5',ctx).val())
      api=svc.authorize
    else
      args.push g_ute.trim($('#fld6',ctx).val())
      args.push g_ute.trim($('#fld7',ctx).val())
      api=svc.allowAccess
    args.push pc
    args.push lf
    args.push rt
    args.push gcc.PivotItem.CBS(ok,nok)
    api.apply(svc, args)

  postShow:(dlg)->
    $('#fld0', dlg).addClass('disabled')
    super(dlg)
#}

class AddFwallRuleDlg extends gcc.ModalDlg #{
  constructor: (@fw) -> super({ title: gcc.L10N('%grant.access') })
  onOK:(ctx,rc)-> @callerCB?(rc.ancillary)
  show: (cb) ->
    f=new AddFwallRuleFm(@fw)
    @callerCB=cb
    me=this
    args={ flds:{}}
    s= [ @fw.getName(), @fw.getProviderFirewallId() ].join(' | ').trim()
    s= s.replace(/(^\||\|$)/g,'').trim()
    args.flds.fld0= { off:1,lbl: @l10n('%grp.name.id'),width:'dlg-s8s',value: s }
    args.flds.fld1= { value:'0/0', focus:1,reqd:1,lbl: @l10n('%port.range'),width:'dlg-s8s' }
    # build choices
    a=_.map(gc.CloudAPI.Network.Protocol.values(), (v) -> {disp: v.toString().toUpperCase(), value: v.toString() } )
    fc=(e)-> me.onProtocolChange(e)
    args.flds.fld3= { kind:'list',lbl: @l10n('%protocol'),choices: a, bind:{cb:fc,evt:'change'} }
    # build radios
    a=[]
    a.push {value:'CIDR',chkd:1,disp:  @l10n('%cidr') }
    a.push {value:'UserGroup',disp:  @l10n('%user.grp') }
    fc=(e)-> me.onSourceChange(e)
    args.flds.fld4= { kind:'list',choices: a,bind:{cb: fc, evt:'change' } }
    args.flds.fld5= { width:'dlg-s8s',value:'0.0.0.0/0' }
    args.flds.fld6= { width:'dlg-s8s',hint:  @l10n('%grp.id'), hide:1 }
    args.flds.fld7= { width:'dlg-s8s',hint:  @l10n('%user.id') ,hide:1 }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
  onProtocolChange:(e)->
    v=$('#'+@getId()+' #fld3').val()
    $('#'+@getId()+' #fld1').val('')
    if v is 'icmp'
      s=$('#'+@getId()+' #fld1-cg label').text()
      $('#'+@getId()+' #fld1').attr('placeholder', '0/0')
      if s isnt  @l10n('%type.code')
        $('#'+@getId()+' #fld1-cg label').text( @l10n('%type.code'))
    else
      s=$('#'+@getId()+' #fld1-cg label').text()
      $('#'+@getId()+' #fld1').attr('placeholder', '0/0')
      if s isnt @l10n('%port.range')
        $('#'+@getId()+' #fld1-cg label').text( @l10n('%port.range') )
  onSourceChange:(e)->
    v=$('#'+@getId()+' #fld4').val()
    $('#'+@getId()+' #fld5').val('')
    $('#'+@getId()+' #fld6').val('')
    $('#'+@getId()+' #fld7').val('')
    if v is @l10n('%cidr')
      $('#'+@getId()+' #fld6').hide()
      $('#'+@getId()+' #fld7').hide()
      $('#'+@getId()+' #fld5').show()
    else
      $('#'+@getId()+' #fld6').show()
      $('#'+@getId()+' #fld7').show()
      $('#'+@getId()+' #fld5').hide()
#}


`

gcc.AddFwallRuleDlg=AddFwallRuleDlg;
gcc.DelFwallRuleDlg=DelFwallRuleDlg;
gcc.AddFwallDlg=AddFwallDlg;
gcc.DelFwallDlg=DelFwallDlg;

})(window, window.document, jQuery);


`
