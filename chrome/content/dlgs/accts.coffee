###
# file: accts.coffee
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
g_prefs=new gcx.Prefs(),
g_ute=new gcc.Ute();


`

class XXXAcctFm extends gcc.HtmlForm #{
  constructor: (@acct) -> super()
  postShow:(dlg)->
    if is_alive(@acct) then $('#fld1', dlg).addClass('disabled')
    super(dlg)
  iniz:(args)->
    if is_alive(@acct)
      args.flds.fld1.value=@acct.acctno
      args.flds.fld1.off=1
      args.flds.fld2.value=@acct.id
      args.flds.fld3.value= g_xul.unobfuscate( @acct.pwd)
      args.flds.fld4.value=@acct.email
    super(args)
  doSave: (ctx,ok,nok) ->
    key=g_xul.getBrowser().getUserData('cloud.user.key')
    db=g_prefs.getAcctsDB()
    acctno=g_ute.trim( $('#fld1',ctx).val() )
    id=g_ute.trim( $('#fld2',ctx).val() )
    pwd=g_ute.trim( $('#fld3',ctx).val())
    email=g_ute.trim( $('#fld4',ctx).val())
    if is_alive(@acct)
      db.edit(key,@acct.key,{ id: id, pwd: pwd, email:email})
      c=@acct
    else
      vendor= g_ute.trim( $('#fld5',ctx).val())
      [c,error] =db.add(key,vendor,acctno,email,id,pwd)
    if is_alive(c) then ok(c) else nok(error)
#}

class XXXAcctDlg extends gcc.ModalDlg #{
  constructor: (title,@acct) -> super({ title: gcc.L10N(title) })
  show: (cb) ->
    f=new XXXAcctFm(@acct)
    @callerCB=cb
    args={ flds: {} }
    args.flds.fld1= { reqd:1,lbl: @l10n('%acct.num'),width:'dlg-s8s' }
    args.flds.fld2= { reqd:1,lbl: @l10n('%acct.id'),width:'dlg-s8s' }
    args.flds.fld3= { reqd:1,lbl: @l10n('%acct.pwd'),width:'dlg-s8s' }
    args.flds.fld4= { kind:'email',lbl: @l10n('%acct.email'),width:'dlg-s8s' }
    if not is_alive(@acct)
      a=[]
      a.push {disp: @l10n(gcc.CloudVendor.AWS),value: gcc.CloudVendor.AWS }
      args.flds.fld5= { kind:'list',lbl: @l10n('%acct.vendor'),choices:a }
      args.yesLabel= @l10n('%createbtn')
      args.flds.fld1.focus=1
    else
      args.yesLabel= @l10n('%savebtn')
      args.flds.fld2.focus=1
    f.iniz(args)
    @inizAsForm(f)
  onOK: (ctx,c) -> @callerCB?(c)
#}

class EditAcctDlg extends XXXAcctDlg #{
  constructor: (@acct) -> super('%edt.acct',@acct)
#}

class AddAcctDlg extends XXXAcctDlg #{
  constructor: () -> super('%new.acct',null)
#}

class DelAcctFm extends gcc.HtmlForm #{
  constructor: (@acct) -> super()
  postShow:(dlg)-> 
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
  doSave: (ctx,ok,nok) ->
    key= g_xul.getBrowser().getUserData('cloud.user.key')
    g_prefs.getAcctsDB().del(key, @acct.key)
    ok()
#}
class DelAcctDlg extends gcc.ModalDlg #{
  constructor: (@acct) -> super({ title: gcc.L10N('%del.acct') })
  show: (cb) ->
    f=new DelAcctFm(@acct)
    @callerCB=cb
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%acct.num'),width:'dlg-s8s',value: @acct.acctno, off:1 }
    args.flds.fld2= { lbl: @l10n('@acct.vendor'),width:'dlg-s8s',value: @l10n(@acct.vendor), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
  onOK: (ctx) -> @callerCB?( @acct)
#}


`

gcc.AddAcctDlg=AddAcctDlg;
gcc.DelAcctDlg=DelAcctDlg;
gcc.EditAcctDlg=EditAcctDlg;

})(window, window.document, jQuery);


`
