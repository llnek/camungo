###
# file: keys.coffee
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

class AddKeyFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok) ->
    n=g_ute.trim($('#fld1',ctx).val())
    d=$('#fld2',ctx).val()
    svc= gcc.HtmlPage.cloud.getIdentityServices().getShellKeySupport()
    svc.createKeypair(n, gcc.PivotItem.CBS(ok,nok))
#}
class AddKeyDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.key') })
  onOK: (ctx,rc) ->
    g_xul.saveFile( @l10n('%save.key.file'), 'PEM Files', '*.pem', '.pem',
      rc.keyName, rc.keyMaterial )
    @callerCB?(rc)
  show: (cb) ->
    f=new AddKeyFm()
    @callerCB=cb
    args={flds:{}}
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%name'),width:'dlg-s8s' }
    args.flds.fld2= { lbl: @l10n('%desc'),width:'dlg-s8s' }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelKeyFm extends gcc.HtmlForm #{
  constructor: (@key) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getIdentityServices().getShellKeySupport()
    svc.deleteKeypair(@key.keyName, gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelKeyDlg extends gcc.ModalDlg #{
  constructor: (@key) -> super({ title: gcc.L10N('%del.key') })
  onOK: (ctx,rc) -> @callerCB?(@key)
  show: (cb) ->
    f=new DelKeyFm(@key)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%name'),width:'dlg-s8s',value: @key.keyName, off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddKeyDlg=AddKeyDlg;
gcc.DelKeyDlg=DelKeyDlg;

})(window, window.document, jQuery);


`
