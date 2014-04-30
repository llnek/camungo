###
# file: about.coffee
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

class AboutFm extends gcc.HtmlForm #{
  constructor: () -> super()
  postShow: (ctx) ->
    me=this
    $('#about-popup .modal-body').on('click', (e)->me.onClicked(e))
  onClicked:(evt)->
    href=$(evt.target).attr('data-content')
    g_xul.openBrowser(href)
#}
class AboutDlg extends gcc.ModalDlg #{
  constructor: () -> super({ id: 'about-popup', title: '', esc:true })
  hdr: """
    <img class="pull-left" src="chrome://camungo/skin/bubblenav/images/logo32.png"/><div class="pull-left"><h3>{{title}}</h3><span>{{ver}}</span></div>
  """

  markup: """
    <p>
    Camungo is a free, open source, cross-platform cloud adminstration GUI client.</br>
    <span style="font-size:smaller;"><b>Build:</b>&nbsp;&nbsp;{{build}}</span></br>
    Copyright &copy; 2012 Cherimoia, LLC. All rights reserved.
    </p>
    <h4>Third Party Dependencies</h4>
    <ul>
    <li><a target="_blank" href="#" data-content="http://jquery.com">jQuery</a></li>
    <li><a target="_blank" href="#" data-content="http://code.google.com/p/crypto-js/">crypto-js</a></li>
    <li><a target="_blank" href="#" data-content="http://jslib.mozdev.org/">JSLib</a></li>
    <li><a target="_blank" href="#" data-content="http://mustache.github.com/">mustache-js</a></li>
    <li><a target="_blank" href="#" data-content="http://documentcloud.github.com/underscore/">underscore-js</a></li>
    <li><a target="_blank" href="#" data-content="http://twitter.github.com/bootstrap/index.html">bootstrap</a></li>
    <li><a target="_blank" href="#" data-content="http://datatables.net/">datatables</a></li>
    <li><a target="_blank" href="#" data-content="http://naghsheh.info/Pivot/Pivot.htm">jqMetro</a></li>
    <li><a target="_blank" data-content="http://www.techlaboratory.net">smart-wizard</a></li>
    <li><a target="_blank" href="#" data-content="http://www.htmldrive.net">stickyfooter</a></li>
    <li><a target="_blank" href="#" data-content="http://www.htmldrive.net">bubblenav</a></li>
    <li><a target="_blank" href="#" data-content="http://www.zotoh.com">cloudapi-js</a></li>
    </ul>
    <h4>Icons &amp; Images</h4>
    <ul>
    <li><a target="_blank" href="#" data-content="http://www.billybarker.net/">www.billybarker.net</a></li>
    <li><a target="_blank" href="#" data-content="http://chrfb.deviantart.com/">chrfb.deviantart.com</a></li>
    </ul>
    <h4>License</h4>
    <ul>
    <li>
    <a target="_blank" href="#" data-content="http://www.apache.org/licenses/LICENSE-2.0">Apache License, Version 2.0</a>
    </li>
    </ul>
    <h4>Email</h4>
    <ul><li>
    <a href="mailto:contactzotoh@gmail.com">contactzotoh@gmail.com</a>
    </li></ul>
  """

  getVersionAndBuild: () ->
    p=[g_xul.getCurProcD(), DirIO.sep, 'application.ini'].join('')
    p=FileIO.openPath(p)
    s=if p.exists() then FileIO.read(p,'utf-8') else ''
    lns=s.split('\n')
    vn='?'
    bn='?'
    fc=(ln)->
      ln=g_ute.trim(ln)
      r=ln.match(/^Version\s*=\s*([0-9\.a-zA-Z\-_]+)/)
      if is_alive(r) and r.length is 2 then vn=r[1]
      r=ln.match(/^BuildID\s*=\s*([0-9\.a-zA-Z\-_]+)/)
      if is_alive(r) and r.length is 2 then bn=r[1]
    _.each(lns, fc)
    return [vn,bn]

  renderFormHeader: (ctx,form) ->
    h=Mustache.render(@hdr,{title: @l10n('%about.title'), ver: @verno })
    $('#about-title',ctx).empty().html(g_ute.trim(h))
  renderFormFooter: (ctx,form) ->
    em=$('.modal-footer', ctx).empty()
    h=Mustache.render(@okfooter, { okbtn: @l10n('%ok') })
    s=Mustache.render( @formfooter, { footerbtns: h } )
    em.html( g_ute.trim(s))
    me=this
    $('#okbtn', ctx).click( () -> me.onSaveOK(ctx) )
  show: () ->
    [vn, bn]=@getVersionAndBuild()
    @buildno=bn
    @verno=vn
    f=new AboutFm()
    args={flds:{}}
    h=Mustache.render(@markup,{ build: @buildno })
    args.flds.fld1= { kind:'html', html: g_ute.trim(h) }
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AboutDlg=AboutDlg;

})(window, window.document, jQuery);


`
