###
# file: page.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var g_nlsCache= { bundle: null },
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_prefs=new gcx.Prefs(),
g_ute=new gcc.Ute();

if (! is_alive( $.fn.single_double_click)) {
// from bing'ing internet
  $.fn.single_double_click = function(ccb, dccb, timeout) {
    return this.each(function() {
        var clicks = 0, me= this;
        jQuery(this).click(function(e) {
            if ( ++clicks === 1) {
              setTimeout(function() {
                if (clicks === 1) { ccb.call(me, e); } 
                else { dccb.call(me, e); }
                clicks = 0;
              }, timeout || 300);
            }
        });
    });
  };
}

// each page loads will set up the global:L10N function
gcc.L10N=function(key,params) { 
  if (!is_alive(g_nlsCache.bundle)) { 
    alert("Looking for key:" + key + ", Where's the L10N file ???"); 
  }
  var t= g_nlsCache.bundle[key];
  if (is_alive(t) && is_alive(params)) {
    t=Mustache.render(t,params)
  }
  return t || '';
}
if (is_alive(genv.ComZotoh.LogJS)) {
// override the cloudapi tracer to trace to JS Console
// so we can debug websvc calls
  genv.ComZotoh.LogJS.setTracer( function(t,m) { g_xul.trace(t,m); } );
  if (g_prefs.getEnableDebug()) {
    genv.ComZotoh.LogJS.setDebug();
  } else if (g_prefs.getEnableLog()) {
    genv.ComZotoh.LogJS.setInfo();
  } else {
    genv.ComZotoh.LogJS.setOFF();
  }

}



`

class HtmlPage #{
  constructor: (locale) ->
    g_nlsCache.bundle= $.localize('camungo.l10n.bundle', locale || 'en')
  l10n: (k,p) -> gcc.L10N(k,p)
  render: () ->
    @preDraw()
    @draw()
  draw: () ->
    # this is for pinning down which pivot-item to show when the page
    # loads, the choice is passed down from main-nav selection which
    # we hide it as part of browser user-data.
    pos= @maybeUseHint(g_xul.getBrowser().getUserData('nav.view.hint') )
    ms='div.metro-pivot'
    m=$(ms)
    vs=@getPivots()
    _.each(vs, (v)-> $('#' + v.id + ' h3').text(v.pivot.getTitle()))
    _.each(vs, (v)-> v.pivot.render())
    m.tooltip({selector:'a'})
    cb=(i)-> _.each(vs, (v) -> v.pivot.onPivotChanged(m, i))
    pc=(i)-> _.each(vs, (v) -> v.pivot.onPivotChange(m, i))
    m.metroPivot({preItemChange: pc, selectedItemChanged: cb })
    if pos is 0
      vs[pos].pivot.onPivotChanged(m,pos)
    else
      m.goToItemByIndex(pos)
  maybeUseHint: (hint) ->  0
  preDraw: () -> HtmlPage.inizCloud()

#}

HtmlPage.inizCloud=(always) ->
  if always is true or not is_alive(HtmlPage.cloud)
    bw=g_xul.getBrowser()
    ps=bw.getUserData('cloud.acct.props')
    c=bw.getUserData('cloud.acct')
    if c.vendor is gcc.CloudVendor.AWS
      c.accountNumber= c.acctno || ''
      c.accessKey=c.id || ''
      c.secretKey= g_xul.unobfuscate(c.pwd || '')
      HtmlPage.cloud= new ComZotoh.CloudAPI.AmazonAWS(c)
      HtmlPage.cloud.getContext().setRegionId(ps.bagOfProps.region)


`

gcc.HtmlPage=HtmlPage;

})(window, window.document, jQuery);


`
