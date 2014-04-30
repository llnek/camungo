###
# file: gates.coffee
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

class UnlinkVPCFm extends gcc.HtmlForm #{
  constructor: (@gate) -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld2' and value is '' then @flagError(ctx,flags,id)
  doSave:(ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    vpc= g_ute.trim($('#fld2',ctx).val())
    gid=@gate.getProviderVpnGatewayId()
    svc.disconnectGateway( @gate.getCategory(),gid,vpc,cbs)
  postShow:(ctx)->
    $('input[type="text"]', ctx).addClass('disabled')
    super(ctx)
#}

class UnlinkVPCDlg extends gcc.ModalDlg #{
  constructor: (@gate) -> super({ title: gcc.L10N('%unlink.vpc') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new UnlinkVPCFm(@gate)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%gate.id'), value: @gate.getProviderVpnGatewayId(), off:1 }
    a=@gate.getTag('attachments') || []
    vpc= if a.length > 0 then a[0].vpcId else ''
    args.flds.fld2= { lbl: @l10n('%vlan.id'), value: vpc || '', off:1 }
    args.yesLabel= @l10n('%unlinkbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class LinkVPCFm extends gcc.HtmlForm #{
  constructor: (@gate) -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld2' and value is '-1' then @flagError(ctx,flags,id)
  doSave:(ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    gid=@gate.getProviderVpnGatewayId()
    vpc= g_ute.trim( $('#fld2',ctx).val())
    svc.connectGateway( @gate.getCategory(),gid,vpc,cbs)
  postShow:(ctx)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    $('#fld1', ctx).addClass('disabled')
    ddl='fld2'
    me=this
    nok=(err)->
      me.clrDDList(ddl,ctx)
      me.dispErrorDDList(ddl,ctx)
    ok=(rc)->
      h=_.map(rc,(v)-> me.htmOneDDListOpt(v.getProviderVlanId()) ).join('')
      $('#fld2',ctx).empty().html(g_ute.trim(h))
    svc.listVlans(gcc.PivotItem.CBS(ok,nok))
    super(ctx)
#}

class LinkVPCDlg extends gcc.ModalDlg #{
  constructor: (@gate) -> super({ title: gcc.L10N('%link.vpc') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new LinkVPCFm(@gate)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%gate.id'), value: @gate.getProviderVpnGatewayId(), off:1 }
    a=[{disp:@l10n('%load.wait'), value:'-1'}]
    args.flds.fld2= { reqd:1,lbl: @l10n('%vlan.id'),choices: a, kind:'list' }
    args.yesLabel= @l10n('%linkbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class AddGateWFm extends gcc.HtmlForm #{
  constructor: () -> super()
  onTypeChange:(dlg,t)->
    switch t
      when 'internet'
        $('#fld2-cg',dlg).css({display:'none'})
        $('#fld3-cg',dlg).css({display:'none'})
        $('#fld4-cg',dlg).css({display:'none'})
        $('#fld5-cg',dlg).css({display:'none'})
      when 'private'
        $('#fld2-cg',dlg).css({display:'block'})
        $('#fld3-cg',dlg).css({display:'block'})
        $('#fld4-cg',dlg).css({display:'block'})
        $('#fld5-cg',dlg).css({display:'none'})
      when 'vlan'
        $('#fld2-cg',dlg).css({display:'block'})
        $('#fld3-cg',dlg).css({display:'none'})
        $('#fld4-cg',dlg).css({display:'none'})
        $('#fld5-cg',dlg).css({display:'block'})
  postShow:(dlg)->
    @onTypeChange(dlg,'vlan')
    em=$('#fld1',dlg)
    me=this
    em.on('change',()->me.onTypeChange(dlg, em.val() ))
    super(dlg)
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld1' and value is 'private'
      if g_ute.trim($('#fld3',ctx).val()) is '' or g_ute.trim($('#fld4',ctx).val()) is '' then @flagError(ctx,flags,id)
  doSave:(ctx,ok,nok) ->
    ct=g_ute.trim($('#fld2',ctx).val())
    ip=g_ute.trim($('#fld3',ctx).val())
    bgp=g_ute.trim($('#fld4',ctx).val())
    t= $('#fld1',ctx).val()
    z=g_ute.trim($('#fld5',ctx).val())
    if z is '-1' then z=null
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.createVPNGateway(t,ct,ip,z,bgp,{},cbs)
#}

class AddGateWDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.gate') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddGateWFm()
    @callerCB=cb
    me=this
    args={ flds: {} }
    a=[{ disp:@l10n('%gate.web'),value:'internet'},{disp:@l10n('%gate.prv'),value:'private'},{disp:@l10n('%gate.vpn'),value:'vlan'}]
    args.flds.fld1= { lbl: @l10n('%type'), choices: a, kind: 'list' }
    a=[{disp:'ipsec.1',value:'ipsec.1'}]
    args.flds.fld2= { lbl: @l10n('%protocol'), choices: a, kind:'list'}
    args.flds.fld3= { lbl: @l10n('%ip.addr'),width:'dlg-s8s' }
    args.flds.fld4= { lbl: @l10n('%bgpasn'),width:'dlg-s8s' }
    a=[{disp:@l10n('%load.none'),value:'-1'}].concat( @arrDcChoices() )
    args.flds.fld5= { lbl: @l10n('%dc'),choices: a, kind:'list' }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelGateWFm extends gcc.HtmlForm #{
  constructor: (@gate) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVpnSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.deleteVPNGateway(@gate.getCategory(), @gate.getProviderVpnGatewayId(),cbs)
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelGateWDlg extends gcc.ModalDlg #{
  constructor: (@gate) -> super({ title: gcc.L10N('%del.gate') })
  onOK: (ctx,rc) -> @callerCB?(@gate)
  show: (cb) ->
    f=new DelGateWFm(@gate)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%gate.id'),width:'dlg-s8s',value: @gate.getProviderVpnGatewayId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}



`

gcc.AddGateWDlg=AddGateWDlg;
gcc.DelGateWDlg=DelGateWDlg;

gcc.UnlinkVPCDlg=UnlinkVPCDlg;
gcc.LinkVPCDlg=LinkVPCDlg;

})(window, window.document, jQuery);


`
