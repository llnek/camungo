###
# file: msgq.coffee
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

class AddMsgQFm extends gcc.HtmlForm #{
  constructor: () -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld3' and isNaN(value) then @flagError(ctx,flags,id)
    if id is 'fld2' and isNaN(value) then @flagError(ctx,flags,id)
  doSave:(ctx,ok,nok) ->
    nm=g_ute.trim($('#fld1',ctx).val())
    rs=g_ute.trim($('#fld2',ctx).val())
    ts=g_ute.trim($('#fld3',ctx).val())
    svc=gcc.HtmlPage.cloud.getPlatformServices().getMessageQueueSupport()
    svc.createQueue(nm,'',rs,ts,gcc.PivotItem.CBS(ok,nok))
#}
class AddMsgQDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.queue') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddMsgQFm()
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%name'),width:'dlg-s8s' }
    args.flds.fld2= { kind:'number',lbl: @l10n('%msg.retention'),width:'dlg-s8s',value: '345600',reqd:1 }
    args.flds.fld3= { kind:'number',lbl: @l10n('%msg.timeout'),width:'dlg-s8s',value:'30', reqd:1 }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelMsgQFm extends gcc.HtmlForm #{
  constructor: (@q) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getPlatformServices().getMessageQueueSupport()
    nm=_.last(@q.split('/'))
    svc.removeQueue(nm,gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelMsgQDlg extends gcc.ModalDlg #{
  constructor: (@q) -> super({ title: gcc.L10N('%del.queue') })
  onOK: (ctx,rc) -> @callerCB?(@q)
  show: (cb) ->
    f=new DelMsgQFm(@q)
    @callerCB=cb
    me=this
    args={ flds: {}}
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',value: @q, off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddMsgQDlg=AddMsgQDlg;
gcc.DelMsgQDlg=DelMsgQDlg;

})(window, window.document, jQuery);


`
