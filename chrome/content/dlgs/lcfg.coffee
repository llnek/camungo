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

class AddLCfgFm extends gcc.HtmlForm #{
  constructor: (@img) -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld5' and value is '-1' then @flagError(ctx,flags,id)
    if id is 'fld4' and value is '-1' then @flagError(ctx,flags,id)
  doSave:(ctx,ok,nok) ->
    nm=g_ute.trim($('#fld1',ctx).val())
    pd=g_ute.trim($('#fld2',ctx).val())
    pd=gc.CloudAPI.Compute.VirtualMachineProduct.entrySet()[pd]
    mon=$('#fld3',ctx).is(':checked')
    sg=@getMultiDDList('fld4')
    kp=g_ute.trim($('#fld5',ctx).val())
    ud=g_ute.trim($('#fld6',ctx).val())
    pms={}
    if g_ute.vstr(ud) then pms.UserData=ud
    if g_ute.vstr(kp) then pms.KeyName=kp
    svc=gcc.HtmlPage.cloud.getComputeServices().getAutoScalingSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.createLaunchConfiguration(nm, @img.getProviderMachineImageId(), pd, sg, mon, pms, cbs)
  postShow:(ctx)->
    svc=gcc.HtmlPage.cloud.getIdentityServices().getShellKeySupport()
    me=this
    nok=(err)->
      me.clrDDList('fld5',ctx)
      me.dispErrorDDList('fld5',ctx)
    ok=(rc)->
      h=_.map(rc,(v)-> me.htmOneDDListOpt(v.keyName)).join('')
      $('#fld5',ctx).empty().html(g_ute.trim(h))
    svc.list(gcc.PivotItem.CBS(ok,nok))
    svc=gcc.HtmlPage.cloud.getNetworkServices().getFirewallSupport()
    nok=(err)->
      me.clrDDList('fld4',ctx)
      me.dispErrorDDList('fld4',ctx)
    ok=(rc)->
      h=_.map(rc,(v)-> me.htmOneDDListOpt(v.getProviderFirewallId())).join('')
      $('#fld4',ctx).empty().html(g_ute.trim(h))
    svc.list(gcc.PivotItem.CBS(ok,nok))
    super(ctx)
#}
class AddLCfgDlg extends gcc.ModalDlg #{
  constructor: (@img) -> super({ title: gcc.L10N('%new.lcfg') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddLCfgFm(@img)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',reqd:1,focus:1 }
    a=@img.getArchitecture()
    a=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport().listProducts(a)
    a=_.map(a, (v) -> { disp:v.getProductId(), value: v.getProductId() } )
    args.flds.fld2= { kind:'list',choices: a,reqd:1 }
    args.flds.fld3= { kind:'cbox', lbl: @l10n('%vm.watch') }
    a=[{disp:@l10n('%load.wait'),value:'-1'}]
    args.flds.fld4= { kind:'list', lbl: @l10n('%fwall'), choices: a, multi:1 }
    a=[{disp:@l10n('%load.wait'),value:'-1'}]
    args.flds.fld5= { kind:'list', lbl: @l10n('%key'), choices: a }
    args.flds.fld6= { kind:'tbox', lbl: @l10n('%bi.wiz.pick.data'), rows: 1 }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelLCfgFm extends gcc.HtmlForm #{
  constructor: (@cfg) -> super()
  doSave:(ctx,ok,nok)->
    n=@cfg.getProviderLaunchConfigurationId()
    svc=gcc.HtmlPage.cloud.getComputeServices().getAutoScalingSupport()
    svc.deleteLaunchConfiguration(n, gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelLCfgDlg extends gcc.ModalDlg #{
  constructor: (@cfg) -> super({ title: gcc.L10N('%del.lcfg') })
  onOK: (ctx,rc) -> @callerCB?(@cfg)
  show: (cb) ->
    f=new DelLCfgFm(@cfg)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',value: @cfg.getProviderLaunchConfigurationId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddLCfgDlg=AddLCfgDlg;
gcc.DelLCfgDlg=DelLCfgDlg;

})(window, window.document, jQuery);


`
