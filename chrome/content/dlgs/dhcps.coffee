###
# file: dhcps.coffee
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


class LinkDhcpSetFm extends gcc.HtmlForm #{
  constructor: (@dhcp) -> super()
  chkField: (ctx, flags, id, fld,value) ->
    if id is 'fld2' and value is '-1' then @flagError(ctx,flags,id)
  doSave:(ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    did=@dhcp.getProviderDhcpId()
    vpc=$('#fld2',ctx).val()
    svc.bindDHCPSet(did,vpc,gcc.PivotItem.CBS(ok,nok) )
  postShow:(ctx)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    $('#fld1', ctx).addClass('disabled')
    ddl='fld2'
    me=this
    nok=(err)->
      me.clrDDList(ddl,ctx)
      me.dispErrorDDList(ddl,ctx)
    ok=(rc)->
      h=_.map(rc,(v)-> me.htmOneDDListOpt(v.getProviderVlanId(),v.getProviderVlanId()) ).join('')
      $('#fld2',ctx).empty().html(g_ute.trim(h))
    svc.listVlans(gcc.PivotItem.CBS(ok,nok))
    super(ctx)
#}

class LinkDhcpSetDlg extends gcc.ModalDlg #{
  constructor: (@dhcp) -> super({ title: gcc.L10N('%link.vpc') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new LinkDhcpSetFm(@dhcp)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { width:'dlg-s8s',lbl: @l10n('%dhcp.id'), value: @dhcp.getProviderDhcpId(), off:1 }
    a=[{disp:@l10n('%load.wait'),value:'-1'}]
    args.flds.fld2= { reqd:1,lbl: @l10n('%vlan.id'),choices: a, kind:'list' }
    args.yesLabel= @l10n('%linkbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class AddDhcpSetFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok) ->
    dn=g_ute.trim($('#fld1',ctx).val())
    nbios=_.map([1,2,3,4],(v)->  g_ute.trim($('#nbios'+v,ctx).val()))
    ntps=_.map([1,2,3,4],(v)->  g_ute.trim($('#ntps'+v,ctx).val()))
    dns=_.map([1,2,3,4],(v)->  g_ute.trim($('#dns'+v,ctx).val()))
    nbios=_.reject(nbios, (v)-> v is '')
    ntps=_.reject(ntps, (v)-> v is '')
    dns=_.reject(dns, (v)-> v is '')
    nbs=null
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    if nbios.length > 0 then nbs={ type: 2, addrs: nbios }
    svc.createDHCPSet(dn,dns,ntps,nbs,gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('#fld2',dlg).css({margin:0,padding:0})
    super(dlg)
#}
class AddDhcpSetDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.dhcp') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  fmtHtml: (id) ->
    fc=(n)->
      v={ fid:id+n,kind:'text',width:'dlg-s8s' }
      Mustache.render(gcc.Widget.EditBoxTpl(), v)
    v={ flabel: {lbl: @l10n('%ip.addr')}, fid: id+1, html: _.map([1,2,3,4],fc).join('') }
    g_ute.trim(Mustache.render(gcc.Widget.FormCtlTpl(), v))
  show: (cb) ->
    f=new AddDhcpSetFm()
    @callerCB=cb
    me=this
    args={flds:{}}
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%domain.name'),width:'dlg-s8' }
    a=[]
    a.push { pid: 'dns', ptitle:@l10n('%dnss'), phtml: @fmtHtml('dns') }
    a.push { pid: 'ntps', ptitle:@l10n('%ntps'), phtml: @fmtHtml('ntps') }
    a.push { pid: 'nbios', ptitle:@l10n('%nbios'), phtml: @fmtHtml('nbios') }
    args.flds.fld2= { kind:'accordion', groups: a, isown: true }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelDhcpSetFm extends gcc.HtmlForm #{
  constructor: (@dhcp) -> super()
  doSave:(ctx,ok,nok)->
    svc=gcc.HtmlPage.cloud.getNetworkServices().getVlanSupport()
    svc.removeDHCPSet(@dhcp.getProviderDhcpId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelDhcpSetDlg extends gcc.ModalDlg #{
  constructor: (@dhcp) -> super({ title: gcc.L10N('%del.dhcp') })
  onOK: (ctx,rc) -> @callerCB?(@dhcp)
  show: (cb) ->
    f=new DelDhcpSetFm(@dhcp)
    @callerCB=cb
    me=this
    args={ flds:{}}
    args.flds.fld1= { width:'dlg-s8s',lbl: @l10n('%dhcp.id'),value: @dhcp.getProviderDhcpId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.LinkDhcpSetDlg=LinkDhcpSetDlg;
gcc.AddDhcpSetDlg=AddDhcpSetDlg;
gcc.DelDhcpSetDlg=DelDhcpSetDlg;

})(window, window.document, jQuery);


`
