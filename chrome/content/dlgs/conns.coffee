###
# file: conns.coffee
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

class AddVpnFm extends gcc.HtmlForm #{
  constructor: (@gate) -> super()
  doSave:(ctx,ok,nok) ->
    gid=@gate.getProviderVpnGatewayId()
    pc=$('#fld2',ctx).val()
    tid=$('#fld3',ctx).val()
    pms={}
    if @gate.getCategory() is 'vlan'
      pms.privateGatewayId=tid
      pms.awsGatewayId=gid
    else
      pms.privateGatewayId=gid
      pms.awsGatewayId=tid
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    svc.createVPN('', pc, pms,gcc.PivotItem.CBS(ok,nok))
#}
class AddVpnDlg extends gcc.ModalDlg #{
  constructor: (@gate, @others) -> super({ title: gcc.L10N('%new.conn') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddVpnFm(@gate)
    @callerCB=cb
    t=@gate.getCategory()
    cgl='%prv.gate.id'
    vgl='%vpc.gate.id'
    if t is 'vlan'
      tt='private'
      gl=vgl
    else
      tt='vlan'
      gl=cgl
    f3l=[]
    fc=(v)-> if v.getCategory() is tt then f3l.push (v.getProviderVpnGatewayId())
    _.each(@others, fc)
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n(gl),width:'dlg-s8s',value: @gate.getProviderVpnGatewayId(),off:1 }
    a=[{disp:'ipsec.1',value:'ipsec.1'}]
    args.flds.fld2= { kind:'list',lbl: @l10n('%protocol'), choices: a }
    gl= if t is 'vlan' then cgl else vgl
    a=_.map(f3l, (v)-> {disp:v,value:v})
    args.flds.fld3= { reqd:1,kind:'list',lbl: @l10n(gl), choices: a }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelVpnFm extends gcc.HtmlForm #{
  constructor: (@vpn) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    svc.deleteVPN(@vpn.getProviderVpnId(), pms,gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelVpnDlg extends gcc.ModalDlg #{
  constructor: (@vpn) -> super({ title: gcc.L10N('%del.conn') })
  onOK: (ctx,rc) -> @callerCB?(@vpn)
  show: (cb) ->
    f=new DelVpnFm(@vpn)
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { lbl: @l10n('%conn.id'),width:'dlg-s8s',value: @vpn.getProviderVpnId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddVpnDlg=AddVpnDlg;
gcc.DelVpnDlg=DelVpnDlg;

})(window, window.document, jQuery);


`
