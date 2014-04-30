###
# file: vols.coffee
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

class AddVolFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok) ->
    sz=g_ute.trim($('#fld1',ctx).val())
    dc=$('#fld2',ctx).val()
    svc= gcc.HtmlPage.cloud.getComputeServices().getVolumeSupport()
    svc.create('', sz,dc, gcc.PivotItem.CBS(ok,nok))
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld1' and isNaN(value) then @flagError(ctx,flags,id)
    if id is 'fld2' and value is '-1' then @flagError(ctx,flags,id)
#}
class AddVolDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.vol') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddVolFm()
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { kind:'number',lbl: @l10n('%vol.size'),width:'dlg-s8s',value:1,reqd:1 }
    args.flds.fld2= { reqd:1,kind:'list',lbl: @l10n('%dc'),choices: @arrDcChoices() }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelVolFm extends gcc.HtmlForm #{
  constructor: (@vol) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getComputeServices().getVolumeSupport()
    svc.remove(@vol.getProviderVolumeId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelVolDlg extends gcc.ModalDlg #{
  constructor: (@vol) -> super({ title: gcc.L10N('%del.vol') })
  onOK: (ctx,rc) -> @callerCB?(@vol)
  show: (cb) ->
    f=new DelVolFm(@vol)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%vol.id'),width:'dlg-s8s',value: @vol.getProviderVolumeId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


class SnapVolFm extends gcc.HtmlForm #{
  constructor: (@vol) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getComputeServices().getSnapshotSupport()
    d=$('#fld2',ctx).val()
    svc.create(@vol.getProviderVolumeId(), d, gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('#fld1',dlg).addClass('disabled')
    super(dlg)
#}
class SnapVolDlg extends gcc.ModalDlg #{
  constructor: (@vol) -> super({ title: gcc.L10N('%snap.vol') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new SnapVolFm(@vol)
    @callerCB=cb
    me=this
    args={ flds: {}}
    args.flds.fld1= { lbl: @l10n('%vol.id'),width:'dlg-s8s',value: @vol.getProviderVolumeId(), off:1 }
    args.flds.fld2= { lbl: @l10n('%desc'), width:'dlg-s8s', reqd:1, hint: @l10n('%type.desc') }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class UnmntVolFm extends gcc.HtmlForm #{
  constructor: (@vol) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getComputeServices().getVolumeSupport()
    svc.detach(@vol.getProviderVolumeId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class UnmntVolDlg extends gcc.ModalDlg #{
  constructor: (@vol) -> super({ title: gcc.L10N('%unmount.vol') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new UnmntVolFm(@vol)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%vol.id'),width:'dlg-s8s',value: @vol.getProviderVolumeId(), off:1 }
    args.flds.fld2= { reqd:1, lbl: @l10n('%vm.id'), width:'dlg-s8s', value: @vol.getProviderVirtualMachineId(), off:1}
    args.yesLabel= @l10n('%unlinkbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class MntVolFm extends gcc.HtmlForm #{
  constructor: (@vol) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getComputeServices().getVolumeSupport()
    vm=$('#fld3',ctx).val()
    dv=$('#fld2',ctx).val()
    svc.attach(@vol.getProviderVolumeId(), vm, dv, gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('#fld1', dlg).addClass('disabled')
    @loadVms(dlg)
    super(dlg)
  postLoadVms: (flag, dlg,rc) ->
    em= @clrDDList('fld3',dlg)
    p1=null
    me=this
    if not flag
      @dispErrorDDList('fld3',dlg)
    else
      fc=(out, v)->
        vid=v.getProviderVirtualMachineId()
        if p1 is null then p1=vid
        out.push me.htmOneDDListOpt(vid)
        out
      em.html(_.reduce(rc, fc, [] ).join(''))
      if p1 is null
        @dispNoneDDList('fld3',dlg)
  loadVms: (dlg) ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getVirtualMachineSupport()
    me=this
    nok=(err)-> me.postLoadVms(false, dlg, err)
    ok=(rc)-> me.postLoadVms(true, dlg, rc)
    svc.listVirtualMachines({dc: @vol.getProviderDataCenterId() }, gcc.PivotItem.CBS(ok,nok))

#}
class MntVolDlg extends gcc.ModalDlg #{
  constructor: (@vol) -> super({ title: gcc.L10N('%mount.vol') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new MntVolFm(@vol)
    @callerCB=cb
    me=this
    args={ flds: {}}
    args.flds.fld1= { lbl: @l10n('%vol.id'),width:'dlg-s8s',value: @vol.getProviderVolumeId(), off:1 }
    args.flds.fld2= { lbl: @l10n('%device'),reqd:1, width:'dlg-s8s',hint: '/dev/sdh or xvdh' }
    a=[ { disp: @l10n('%load.wait'), value: '-1' } ]
    flds.fld3= { reqd:1, kind:'list', focus:1, lbl: @l10n('%avail.vms'), choices: a }
    args.yesLabel= @l10n('%linkbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

`

gcc.AddVolDlg=AddVolDlg;
gcc.DelVolDlg=DelVolDlg;
gcc.MntVolDlg=MntVolDlg;
gcc.UnmntVolDlg=UnmntVolDlg;
gcc.SnapVolDlg=SnapVolDlg;

})(window, window.document, jQuery);


`
