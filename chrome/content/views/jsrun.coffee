###
# file: jsrun.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_ute=new gcc.Ute();


`

class JSRun extends gcc.PivotItem #{

  constructor: ()-> super('%topic.jsrun')
  moniker: 'jsrun'
  id: 'jsrun-tpl'

  desc: """
  /* You can call directly to do whatever you want with this.
  The sample code here is to list all the keypairs...
  You do pretty much do anything you want by calling the cloudapi-js.
*/
var res='';
var ok=function(rc) {
 res=JSON.stringify(rc)
};
var nok=function(err) {
res=JSON.stringify(err);
};
AmazonAWS.getIdentityServices().getShellKeySupport().list( new ComZotoh.Net.AjaxCBS( ok, nok));
alert('a'); // block and wait a bit
res;
  """

  onRun: () ->
    AmazonAWS= gcc.HtmlPage.cloud
    ComZotoh=genv.ComZotoh
    em=$('#jseditor')
    x= em.val()
    rc=eval(x)
    x=[x, '\n', rc ].join('')
    em.val(x)

  postDraw: () ->
    me=this
    $('#js-reset').on('click', () -> $('#jseditor').val(me.desc) )
    $('#js-cls').on('click', () -> $('#jseditor').val('') )
    $('#jseditor-run').on('click', () -> me.onRun())
    $('#jseditor').val(@desc)

  markup: """
    <div id="jseditor-tb">
      <a id="jseditor-run" class="pull-left btn btn-primary" href="#"><i class="icon-play icon-white"></i> {{btn}}</a>
      <span class="pull-left">&nbsp;&nbsp;</span>
      <a id="js-cls" class="pull-left btn" href="#"><i class="icon-ban-circle icon-white"></i> {{btn2}}</a>
      <span class="pull-left">&nbsp;&nbsp;</span>
      <a id="js-reset" class="pull-left btn" href="#"><i class="icon-retweet icon-white"></i> {{btn3}}</a>
    </div>
    <div id="jsrun">
      <textarea id="jseditor" rows="40"></textarea>
    </div>
  """

  onRefresh:()->
    #$('#jseditor').val(@desc)

  getTpl: () ->
    icons= @basicIcons()
    h= Mustache.render(@markup, { btn: @l10n('%run.js'),btn3:@l10n('%reset'), btn2: @l10n('%clear') })
    g_ute.trim [ h, @footerMenu(icons)  ].join('')

#}


`

gcc.JSRun=JSRun;

})(window, window.document, jQuery);


`
