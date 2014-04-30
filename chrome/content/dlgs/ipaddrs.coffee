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
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class AddAddrFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok)->
    type= gc.CloudAPI.Network.AddressType.PUBLIC
    domain= $('fld1',ctx).val()
    if 'vpc' is domain then type= gc.CloudAPI.Network.AddressType.PRIVATE
    svc= gcc.HtmlPage.cloud.getNetworkServices().getIpAddressSupport()
    svc.request(type, gcc.PivotItem.CBS(ok,nok))
#}

class AddAddrDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.ip') })
  onOK: (ctx,rc)-> @callerCB?(rc)
  show: (cb) ->
    f=new AddAddrFm()
    @callerCB=cb
    me=this
    args={ flds: {} }
    a=[{disp:@l10n('%dom.std'),value:'standard'},{disp:@l10n('%dom.vpc'),value:'vpc'}]
    args.flds.fld1= { kind:'list',focus:1,lbl: @l10n('%domain'),width:'dlg-s8s', choices: a }
    args.yesLabel= @l10n('%reqbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelAddrFm extends gcc.HtmlForm #{
  constructor: (@addr) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getNetworkServices().getIpAddressSupport()
    svc.releaseFromPool( @addr.getProviderIpAddressId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelAddrDlg extends gcc.ModalDlg #{
  constructor: (@addr) -> super({ title: gcc.L10N('%del.ip') })
  onOK:(ctx,r)-> @callerCB?(@addr)
  show: (cb) ->
    f=new DelAddrFm(@addr)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%ipaddr'),width:'dlg-s8s',value: @addr.getProviderIpAddressId(), off:1 }
    args.yesLabel= @l10n('%releasebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


class UnbindAddrFm extends gcc.HtmlForm #{
  constructor: (@addr) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getNetworkServices().getIpAddressSupport()
    cbs= gcc.PivotItem.CBS(ok,nok)
    svc.releaseFromServer(@addr.getProviderIpAddressId(), cbs)
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class UnbindAddrDlg extends gcc.ModalDlg #{
  constructor: (@addr) -> super({ title: gcc.L10N('%unbind.ip') })
  onOK:(ctx,r)-> @callerCB?(@addr)
  show: (cb) ->
    f=new UnbindAddrFm(@addr)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%ip.addr'),width:'dlg-s8s', value: @addr.getProviderIpAddressId(), off:1 }
    args.flds.fld2= { lbl: @l10n('%vm.id'),width:'dlg-s8s', value: @addr.getServerId(), off:1 }
    args.yesLabel= @l10n('%unbindbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class BindAddrFm extends gcc.HtmlForm #{
  constructor: (@addr) -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld2' and value is '-1' then @flagError(ctx,flags,id)
  doSave:(ctx,ok, nok)->
    vm= g_ute.trim( $('#fld2',ctx).val())
    svc= gcc.HtmlPage.cloud.getNetworkServices().getIpAddressSupport()
    cbs= gcc.PivotItem.CBS(ok,nok)
    x= @addr.getTag('allocationId')
    pms={}
    if g_ute.vstr(x) then pms.allocationId=x
    svc.assign(@addr.getProviderIpAddressId(), vm, pms, cbs)
  postShow:(dlg)->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    me=this
    nok=(err)->
      me.clrDDList('fld2',dlg)
      me.dispErrorDDList('fld2',dlg)
    ok=(rc)->
      fc=(r)->
        s= r.getProviderVlanId()
        r.getProviderVirtualMachineId() + (if g_ute.vstr(s) then ' | '+s else '')
      h=_.map(rc,(v)->me.htmOneDDListOpt(v.getProviderVirtualMachineId() , fc(v) )).join('')
      $('#fld2',dlg).empty().html(h)
    svc.listVirtualMachines('', gcc.PivotItem.CBS(ok,nok))
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class BindAddrDlg extends gcc.ModalDlg #{
  constructor: (@addr) -> super({ title: gcc.L10N('%bind.ip') })
  onOK:(ctx,rc)-> @callerCB?(rc.ancillary)
  show: (cb) ->
    vpc= gc.CloudAPI.Network.AddressType.PRIVATE is @addr.getAddressType()
    f=new BindAddrFm(@addr)
    @callerCB=cb
    me=this
    args={ flds: {}}
    args.flds.fld1= { lbl: @l10n('%ip.addr'),width:'dlg-s8s', off: 1, value: @addr.getProviderIpAddressId() }
    a=[{disp:@l10n('%load.wait'),value:'-1'}]
    args.flds.fld2= { reqd:1,focus:1,kind:'list',lbl: @l10n('%avail.vms'), choices: a }
    args.yesLabel= @l10n('%linkbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

`

gcc.AddAddrDlg=AddAddrDlg;
gcc.DelAddrDlg=DelAddrDlg;

gcc.UnbindAddrDlg=UnbindAddrDlg;
gcc.BindAddrDlg=BindAddrDlg;

})(window, window.document, jQuery);


`
