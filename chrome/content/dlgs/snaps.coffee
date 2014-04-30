###
# file: snaps.coffee
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

class NewVolFm extends gcc.HtmlForm #{
  constructor: (@snap) -> super()
  doSave:(ctx,ok,nok) ->
    dc=$('#fld3',ctx).val()
    svc= gcc.HtmlPage.cloud.getComputeServices().getVolumeSupport()
    svc.create(@snap.getProviderSnapshotId(), null, dc, gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('#fld1', dlg).addClass('disabled')
    super(dlg)
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld3' and value is '-1' then @flagError(ctx,flags,id)
#}
class NewVolDlg extends gcc.ModalDlg #{
  constructor: (@snap) -> super({ title: gcc.L10N('%new.vol') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new NewVolFm(@snap)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%snap.id'),width:'dlg-s8s',value: @snap.getProviderSnapshotId(), off:1 }
    a= @arrDcChoices()
    flds.fld3= { kind: 'list',lbl: @l10n('%dcs'), choices: a, reqd:1}
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelSnapFm extends gcc.HtmlForm #{
  constructor: (@snap) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getComputeServices().getSnapshotSupport()
    svc.remove(@snap.getProviderSnapshotId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelSnapDlg extends gcc.ModalDlg #{
  constructor: (@snap) -> super({ title: gcc.L10N('%del.snap') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new DelSnapFm(@snap)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%snap.id'),width:'dlg-s8s',value: @snap.getProviderSnapshotId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.DelSnapDlg=DelSnapDlg;
gcc.NewVolDlg=NewVolDlg;

})(window, window.document, jQuery);


`
