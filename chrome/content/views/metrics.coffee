###
# file: metrics.coffee
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

class Metrics extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.metrics')
    @cm0= [ @tct('%id'), @tct('%name'), @tct('%metric.group') ]
    @gid= 'metrics-grid'
    @tids= [ @gid ]

  moniker: 'metrics'
  id: 'metrics-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    #icons.push {linkid: @btnid('add') , title: @l10n('%new.key'),icon:'add'}
    #icons.push {linkid: @btnid('del'), title: @l10n('%del.key'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getComputeServices().getMetricsSupport()
    @onSync(svc,svc.listMetrics, [''], @gid)

  fmtAsRow: (dtb,row) ->
    id=row.getName()
    [ id, [id, id, row.getProviderGroupId()  ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    #$('#'+ @btnid('del')).click( () -> me.onDelKey() )
    #$('#'+ @btnid('add')).click( ()-> me.onAddKey() )

  onAddKey: () ->
  onDelKey: () ->
    r= @getCurRow( @dtbl(@gid) )
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      #new gcc.DelKeyDlg(r).show()


#}

`

gcc.Metrics=Metrics;

})(window, window.document, jQuery);


`
