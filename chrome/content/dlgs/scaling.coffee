###
# file: scaling.coffee
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

class AddASGFm extends gcc.HtmlForm #{
  constructor: (@cfg) -> super()
  postShow:(ctx)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getLoadBalancerSupport()
    me=this
    nok=()-> me.dispErrorDDList('fld4',ctx)
    ok=(rc)->
      h=_.map(rc,(v)-> me.htmOneDDListOpt(v.getProviderLoadBalancerId())).join('')
      $('#fld4',ctx).empty().html(g_ute.trim(h))
    svc.listLoadBalancers(gcc.PivotItem.CBS(ok,nok))
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    nok=()-> me.dispErrorDDList('fld5',ctx)
    ok=(rc)->
      h=_.map(rc,(v)-> me.htmOneDDListOpt(v.getProviderSubnetId())).join('')
      $('#fld5',ctx).empty().html(g_ute.trim(h))
    svc.listSubnets('', gcc.PivotItem.CBS(ok,nok))
    super(ctx)
  doSave:(ctx,ok,nok) ->
    nm= g_ute.trim($('#fld1',ctx).val())
    a=g_ute.trim($('#fld2',ctx).val())
    a=a.match(/([0-9]+)\s*\/\s*([0-9]+)\s*\/\s*([0-9]+)/)
    n1=a[1]
    n2=a[2]
    n3=a[3]
    dcs=@getMultiDDList('fld3')
    lbs=@getMultiDDList('fld4')
    sns=@getMultiDDList('fld5')
    pms={}
    pms.DesiredCapacity=n3
    pms.vpcs=sns
    pms.ldbs=lbs
    svc=gcc.HtmlPage.cloud.getComputeServices().getAutoScalingSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.createAutoScalingGroup(nm,@cfg.getProviderLaunchConfigurationId(),n1,n2,null,dcs,pms,cbs )
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld2'
      a=value.match(/([0-9]+)\s*\/\s*([0-9]+)\s*\/\s*([0-9]+)/)
      if isNaN(a[0]) or isNaN(a[1]) or isNaN(a[2]) then @flagError(ctx,flags,id)
    if id is 'fld5' and value is '-1' then @flagError(ctx,flags,id)
    if id is 'fld4' and value is '-1' then @flagError(ctx,flags,id)
    if id is 'fld3' and value is '-1' then @flagError(ctx,flags,id)
#}
class AddASGDlg extends gcc.ModalDlg #{
  constructor: (@cfg) -> super({ title: gcc.L10N('%new.asg') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddASGFm(@cfg)
    @callerCB=cb
    me=this
    args={ flds: {}}
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',focus:1,reqd:1 }
    args.flds.fld2= { lbl: @l10n('%scale.range.target'),width:'dlg-s8s',value:'1/1/1',reqd:1 }
    a=@arrDcChoices()
    args.flds.fld3= { kind:'list',lbl: @l10n('%dc'),choices:a,multi:1 }
    a=[{disp:@l10n('%load.wait'),value:'-1'}]
    args.flds.fld4= { kind:'list',lbl: @l10n('%lbr'), choices: a,multi:1 }
    args.flds.fld5= { kind:'list',lbl: @l10n('%dom.vpc'),choices:a,multi:1 }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelASGFm extends gcc.HtmlForm #{
  constructor: (@grp) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getComputeServices().getAutoScalingSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.deleteAutoScalingGroup(@grp.getProviderScalingGroupId(),true,cbs)
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelASGDlg extends gcc.ModalDlg #{
  constructor: (@grp) -> super({ title: gcc.L10N('%del.asg') })
  onOK: (ctx,rc) -> @callerCB?(@grp)
  show: (cb) ->
    f=new DelASGFm(@grp)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',value: @grp.getProviderScalingGroupId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddASGDlg=AddASGDlg;
gcc.DelASGDlg=DelASGDlg;

})(window, window.document, jQuery);


`
