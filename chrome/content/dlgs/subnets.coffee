###
# file: subnets.coffee
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

class AddSNetFm extends gcc.HtmlForm #{
  constructor: (@vpc) -> super()
  doSave:(ctx,ok,nok)->
    cidr=g_ute.trim($('#fld2',ctx).val())
    z=$('#fld3',ctx).val()
    if z is '-1' then z=null
    svc= gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    svc.createSubnet(@vpc.getProviderVlanId(), cidr, z, {}, gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('#fld1', dlg).addClass('disabled')
    super(dlg)
#}
class AddSNetDlg extends gcc.ModalDlg #{
  constructor: (@vpc) -> super({ title: gcc.L10N('%new.subnet') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddSNetFm(@vpc)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%vlan.id'),value: @vpc.getProviderVlanId(), off:1 }
    args.flds.fld2= { reqd:1, lbl: @l10n('%cidr'), value: '0.0.0.0/0' }
    a=[ {disp:@l10n('%load.none'),value:'-1'}].concat( @arrDcChoices() )
    args.flds.fld3= { kind:'list',lbl: @l10n('%dc'),choices:a }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelSNetFm extends gcc.HtmlForm #{
  constructor: (@net) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    svc.removeSubnet(@net.getProviderSubnetId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelSNetDlg extends gcc.ModalDlg #{
  constructor: (@net) -> super({ title: gcc.L10N('%del.subnet') })
  onOK: (ctx,rc) -> @callerCB?(@net)
  show: (cb) ->
    f=new DelSNetFm(@net)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%subnet.id'),width:'dlg-s8s',value: @net.getProviderSubnetId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddSNetDlg=AddSNetDlg;
gcc.DelSNetDlg=DelSNetDlg;

})(window, window.document, jQuery);


`
