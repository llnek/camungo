###
# file: vpncstyles.coffee
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

var CGateFFmts= {
  'customer-gateway-cisco-ios-isr.xslt': {
    vendor:'Cisco Systems, Inc.',
    platform:'ISR Series Routers',
    software:'IOS 12.4+'
  }
  , 'customer-gateway-juniper-screenos-6.2.xslt': {
    vendor:'Juniper Networks, Inc.',
    platform:'SSG and ISG Series Routers',
    software:'ScreenOS 6.2+'
  }
  , 'customer-gateway-juniper-screenos-6.1.xslt' : {
    vendor:'Juniper Networks, Inc.',
    platform:'SSG and ISG Series Routers',
    software:'ScreenOS 6.1'
  }
  , 'customer-gateway-juniper-junos-j.xslt' : {
    vendor:'Juniper Networks, Inc.',
    platform:'J-Series Routers',
    software:'JunOS 9.5+'
  }
  , 'customer-gateway-generic.xslt' : {
    vendor:'Generic',
    platform:'n/a',
    software:'Vendor Agnostic'
  }
  /*
  , '.xslt' : {
    vendor:'*',
    platform:'',
    software:'Raw XML'
  }
  */

};

`

class VPNConnStylesFm extends gcc.HtmlForm #{
  constructor: (@conn) -> super()
  postShow:(ctx)->
    me=this
    @syncChanges(ctx)
    $('#fld1',ctx).on('change', () -> me.syncChanges(ctx))
    $('form input[type="text"]',ctx).addClass('disabled')
    super(ctx)
  syncChanges:(ctx)->
    v= CGateFFmts[ $('#fld1',ctx).val() ]
    $('#fld2',ctx).val( v.platform)
    $('#fld3',ctx).val( v.software)
  doSave:(ctx,ok,nok) ->
    fn=$('#fld1',ctx).val()
    fp=[ g_xul.getAChrom() , 'assets', fn ].join(DirIO.sep)
    g_xul.debug('Reading xslt file: ' + fp)
    try
      xsl=FileIO.read( FileIO.open(fp))
      xsl = new genv.DOMParser().parseFromString( xsl, "text/xml")
    catch e
      g_xul.error('Failed to read file: ' + fp)
      xsl=null
    xml=@conn.getTag('customerGatewayConfiguration')
    g_xul.debug('vpn-cfg-data: ' + xml)
    if g_ute.vstr(xml)
      xml = new genv.DOMParser().parseFromString( xml, "text/xml")
    else
      g_xul.error('No VPN config data for: ' + @conn.getProviderVpnId())
      xml=null
    res=''
    if is_alive(xsl) and is_alive(xml)
      try
        proc = new genv.XSLTProcessor()
        xsl.normalize()
        proc.importStylesheet(xsl)
        xml = proc.transformToDocument(xml)
        res = g_ute.fcn( g_ute.gt( xml, "transformiix:result")[0] )
      catch e
    ok(res)

#}
class VPNConnStylesDlg extends gcc.ModalDlg #{
  constructor: (@conn) -> super({ title: gcc.L10N('%vpngate.ffmt') })
  onOK: (ctx,rc) ->
    if g_ute.vstr(rc)
      hdr= @l10n('%save.cfg.file')
      id=@conn.getProviderVpnId()
      fc=()->
        g_xul.saveFile( hdr, 'Text Files', '*.txt', '.txt', id, rc )
      genv.setTimeout(fc,500)
    @callerCB?(rc)
  show: (cb) ->
    f=new VPNConnStylesFm(@conn)
    @callerCB=cb
    args={flds:{}}
    a=_.map(CGateFFmts, (v,k)-> { disp: v.vendor, value: k } )
    args.flds.fld1= { lbl: @l10n('%vendor'),kind:'list',choices:a}
    args.flds.fld2= { lbl: @l10n('%platform'),width:'dlg-s8s',off:1 }
    args.flds.fld3= { lbl: @l10n('%software'),width:'dlg-s8s',off:1 }
    args.yesLabel= @l10n('%contbtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.VPNConnStylesDlg=VPNConnStylesDlg;

})(window, window.document, jQuery);


`
