###
# file: vlans.coffee
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

class AddVLanFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok)->
    cidr=g_ute.trim( $('#fld1',ctx).val())
    t=g_ute.trim( $('#fld2',ctx).val())
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    svc.createVlan(cidr,{ type: t }, gcc.PivotItem.CBS(ok,nok))
#}
class AddVLanDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.vlan') })
  onOK:(ctx,rc)-> @callerCB?(rc)
  show: (cb) ->
    f=new AddVLanFm()
    @callerCB=cb
    args={  flds: {} }
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%cidr'),width:'dlg-s8s' }
    a=[{disp: @l10n('%default'),value:'default'},{disp: @l10n('%dedicated'),value:'dedicated'}]
    args.flds.fld2= { kind:'list',lbl: @l10n('%tenancy'), choices: a }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelVLanFm extends gcc.HtmlForm #{
  constructor: (@vlan) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    svc.removeVlan( @vlan.getProviderVlanId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelVLanDlg extends gcc.ModalDlg #{
  constructor: (@vlan) -> super({ title: gcc.L10N('%del.vlan') })
  show: () ->
    f=new DelVLanFm(@vlan)
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%vpc.id'),width:'dlg-s8s',value: @vlan.getProviderVlanId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddVLanDlg=AddVLanDlg;
gcc.DelVLanDlg=DelVLanDlg;

})(window, window.document, jQuery);


`
