###
# file: lbs.coffee
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

class AddELBFm extends gcc.HtmlForm #{
  constructor: () -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld5' and isNaN(value) then @flagError(ctx,flags,id)
    if id is 'fld3' and value is '-1' then @flagError(ctx,flags,id)
  onVPC:(ctx)->
    id='fld3'
    me=this
    @clrDDList(id,ctx)
    @dispWaitDDList(id,ctx)
    em=$('#'+id,ctx)
    if not $('#fld2',ctx).is(':checked')
      dcs=g_xul.getCachedDcs()
      h=_.map(_.keys(dcs).sort(), (v)-> me.htmOneDDListOpt(v)).join('')
      em.empty().html( g_ute.trim(h))
    else
      svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
      nok=(err)->
        me.clrDDList(id,ctx)
        me.dispErrorDDList(id,ctx)
      ok=(rc)->
        h=_.map(rc, (v) -> me.htmOneDDListOpt(v.getProviderSubnetId()) ).join('')
        em.empty().html( g_ute.trim(h))
      svc.listSubnets('', cbs=gcc.PivotItem.CBS(ok,nok))
  postShow:(ctx)->
    me=this
    #$('#fld2',ctx).on('change',()->me.onVPC(ctx))
    super(ctx)
  doSave:(ctx,ok,nok) ->
    id=g_ute.trim($('#fld1',ctx).val())
    #vpc=$('#fld2',ctx).is(':checked')
    vpc=false
    z=g_ute.trim($('#fld3',ctx).val())
    p=g_ute.trim($('#fld4',ctx).val())
    p=gc.CloudAPI.Network.LbProtocol.valueOf(p)
    n=g_ute.trim($('#fld5',ctx).val())
    c=g_ute.trim($('#fld6',ctx).val())
    svc=gcc.HtmlPage.cloud.getNetworkServices().getLoadBalancerSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    ln=new gc.CloudAPI.Network.LbListener()
    ln.setPrivatePort(n)
    ln.setPublicPort(n)
    ln.setPrivateProtocol(p)
    ln.setPublicProtocol(p)
    ln.setSSLCert(c)
    zs=[]
    ss=[]
    if vpc then ss.push(z) else zs.push(z)
    svc.create(id,'','',zs,ss, [ln],[],cbs)
#}
class AddELBDlg extends gcc.ModalDlg #{
  constructor: (@dcs) -> super({ title: gcc.L10N('%new.lb') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddELBFm()
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',focus:1,reqd:1 }
    #args.flds.fld2= { kind:'cbox',lbl: @l10n('%dom.vpc') }
    a=@arrDcChoices()
    args.flds.fld3= { reqd:1,kind:'list',lbl: @l10n('%dc'),choices: a }
    a= _.map(['HTTP','HTTPS','SSL','TCP'],(v)->{ disp:v,value:v})
    args.flds.fld4= { kind:'list',lbl: @l10n('%protocol'),choices: a }
    args.flds.fld5= { kind:'number',lbl: @l10n('%port'),value: '80',reqd:1 }
    args.flds.fld6= { lbl: @l10n('%ssl.cert'), hint: @l10n('%help.ssl.cert') }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelELBFm extends gcc.HtmlForm #{
  constructor: (@elb) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getLoadBalancerSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.remove(@elb.getProviderLoadBalancerId(),cbs)
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelELBDlg extends gcc.ModalDlg #{
  constructor: (@elb) -> super({ title: gcc.L10N('%del.lb') })
  onOK: (ctx,rc) -> @callerCB?(@elb)
  show: (cb) ->
    f=new DelELBFm(@elb)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',value: @elb.getProviderLoadBalancerId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddELBDlg=AddELBDlg;
gcc.DelELBDlg=DelELBDlg;

})(window, window.document, jQuery);


`
