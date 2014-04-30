###
# file: vms.coffee
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

class VmConsFm extends gcc.HtmlForm #{
  constructor: (@vm) -> super()
  doSave:(ctx,ok,nok) ->
    ok({})
  postShow: (dlg)->
    svc= gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    nok=(err)-> $('#fld2',dlg).val( gcc.L10N('%load.bad'))
    ok=(rc)-> $('#fld2',dlg).val(rc.result)
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.getConsoleOutput( @vm.getProviderVirtualMachineId(), cbs)
#}
class GetVmConsDlg extends gcc.ModalDlg #{
  constructor: (@vm) -> super({ title: gcc.L10N('%vm.console') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new VmConsFm(@vm)
    @callerCB=cb
    me=this
    args={ flds:{}, btns: { yes:1,no:0}}
    args.flds.fld1= { lbl: @l10n('%vm.id'),width:'dlg-s8s',value: @vm.getProviderVirtualMachineId(),off:1 }
    args.flds.fld2= { kind:'tbox', rows: 12 }
    args.yesLabel= @l10n('%okbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class BootVmFm extends gcc.HtmlForm #{
  constructor: (@vm) ->  super()
  postShow:(dlg)-> 
    $('input[type="text"]', dlg).addClass('disabled')
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    nok=(err)-> $('#fld2',dlg).val( gcc.L10N('%load.bad'))
    ok=(rc)-> $('#fld2',dlg).val(rc.getCurrentState())
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.getVirtualMachine(@vm.getProviderVirtualMachineId(),cbs)
    super(dlg)
  doSave: (ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    vid=@vm.getProviderVirtualMachineId()
    cbs=gcc.PivotItem.CBS(ok,nok)
    s=$('#fld2',ctx).val()
    if 'running' is s or 'stopped' is s
      @vm.setCurrentState(s)
      if 'running' is s then svc.reboot(vid,cbs)
      if 'stopped' is s then svc.boot(vid,cbs)
#}

class BootVmDlg extends gcc.ModalDlg #{
  constructor: (@vm) -> super({ title: gcc.L10N('%vm.start') })
  onOK: (ctx,rc) -> @callerCB?(@vm)
  show: (cb) ->
    f=new BootVmFm(@vm)
    @callerCB=cb
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%vm.id'),width:'dlg-s8s',value: @vm.getProviderVirtualMachineId(),off:1 }
    args.flds.fld2= { lbl: @l10n('%state'),width:'dlg-s8s', value: @l10n('%check.wait'), off:1 }
    args.yesLabel= @l10n('%contbtn')
    f.iniz(args)
    @inizAsForm(f)
#}


class HaltVmFm extends gcc.HtmlForm #{
  constructor: (@vm) ->  super()
  postShow:(dlg)-> 
    $('input[type="text"]', dlg).addClass('disabled')
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    nok=(err)-> $('#fld2',dlg).val( gcc.L10N('%load.bad'))
    ok=(rc)-> $('#fld2',dlg).val(rc.getCurrentState())
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.getVirtualMachine(@vm.getProviderVirtualMachineId(),cbs)
    super(dlg)
  doSave: (ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    vid=@vm.getProviderVirtualMachineId()
    cbs=gcc.PivotItem.CBS(ok,nok)
    s=$('#fld2',ctx).val()
    if not ('terminated' is s or 'shutting-down' is s) then svc.terminate(vid,cbs)
#}
class HaltVmDlg extends gcc.ModalDlg #{
  constructor: (@vm) -> super({ title: gcc.L10N('%vm.halt') })
  onOK: (ctx,rc) -> @callerCB?(@vm)
  show: (cb) ->
    f=new HaltVmFm(@vm)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%vm.id'),width:'dlg-s8s',value: @vm.getProviderVirtualMachineId(),off:1 }
    args.flds.fld2= { lbl: @l10n('%state'),width:'dlg-s8s', value: @l10n('%check.wait'), off:1 }
    args.yesLabel= @l10n('%contbtn')
    f.iniz(args)
    @inizAsForm(f)
#}



class PauseVmFm extends gcc.HtmlForm #{
  constructor: (@vm) ->  super()
  postShow:(dlg)-> 
    $('input[type="text"]', dlg).addClass('disabled')
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    nok=(err)-> $('#fld2',dlg).val( gcc.L10N('%load.bad'))
    ok=(rc)-> $('#fld2',dlg).val(rc.getCurrentState())
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.getVirtualMachine(@vm.getProviderVirtualMachineId(),cbs)
    super(dlg)
  doSave: (ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    vid=@vm.getProviderVirtualMachineId()
    cbs=gcc.PivotItem.CBS(ok,nok)
    s=$('#fld2',ctx).val()
    if 'running' is s then svc.pause(vid,cbs)
#}
class PauseVmDlg extends gcc.ModalDlg #{
  constructor: (@vm) -> super({ title: gcc.L10N('%vm.pause') })
  onOK: (ctx,rc) -> @callerCB?(@vm)
  show: (cb) ->
    f=new PauseVmFm(@vm)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%vm.id'),width:'dlg-s8s',value: @vm.getProviderVirtualMachineId(),off:1 }
    args.flds.fld2= { lbl: @l10n('%state'),width:'dlg-s8s', value: @l10n('%check.wait'), off:1 }
    args.yesLabel= @l10n('%contbtn')
    f.iniz(args)
    @inizAsForm(f)
#}


class SSHVmFm extends gcc.HtmlForm #{
  constructor: (@vm) ->  super()
  postShow:(dlg)-> 
    $('input[type="text"]', dlg).addClass('disabled')
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    me=this
    nok=(err)-> $('#fld2',dlg).val( gcc.L10N('%load.bad'))
    ok=(rc)-> 
      $('#fld2',dlg).val(rc.getCurrentState())
      me.vm=rc
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.getVirtualMachine(@vm.getProviderVirtualMachineId(),cbs)
    super(dlg)
  doSave: (ctx,ok,nok) ->
    vid=@vm.getProviderVirtualMachineId()
    s=$('#fld2',ctx).val()
    if 'running' is s then ok(@vm) else nok()
#}
class SSHVmDlg extends gcc.ModalDlg #{
  constructor: (@vm) -> super({ title: gcc.L10N('%vm.ssh') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new SSHVmFm(@vm)
    @callerCB=cb
    me=this
    args={ flds:{}}
    args.flds.fld1= { lbl: @l10n('%vm.id'),width:'dlg-s8s',value: @vm.getProviderVirtualMachineId(),off:1 }
    args.flds.fld2= { lbl: @l10n('%state'),width:'dlg-s8s', value: @l10n('%check.wait'), off:1 }
    args.yesLabel= @l10n('%contbtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`


gcc.GetVmConsDlg=GetVmConsDlg;
gcc.BootVmDlg=BootVmDlg;
gcc.HaltVmDlg=HaltVmDlg;
gcc.PauseVmDlg=PauseVmDlg;
gcc.SSHVmDlg=SSHVmDlg;




})(window, window.document, jQuery);


`
