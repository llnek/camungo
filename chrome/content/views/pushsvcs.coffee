###
# file: pushsvcs.coffee
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

class PushServices extends gcc.PivotItem #{

  constructor: () ->
    super('%topic.notify')
    @cm0= [ @tct('%id'), @tct('%topic.id') ]
    @gid= 'notify-grid'
    @tids= [ @gid ]

  moniker: 'notify'
  id: 'notify-tpl'

  postDraw: () -> gcc.Grid.create( @gid, @cm0, 10, @stdTblCBObj(@gid) )
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.topic'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.topic'),icon:'minus'}
    g_ute.trim [ @tableHtml( @gid) , @footerMenu(icons)  ].join('')

  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getPlatformServices().getPushNotificationSupport()
    @onSync(svc,svc.listTopics, [ '' ], @gid)

  fmtAsRow: (dtb,row) ->
    id= row.getProviderTopicId()
    [ id, [ id, id ] ]

  onTableRClicked: ( table,tr, data) ->
    row= @cache[ @gid][ data[0] ]
    if is_alive(row) then @popCTMenuXXX(row, {tags:0 })

  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelTopic() )
    $('#'+ @btnid('add')).click( ()-> me.onAddTopic() )

  postAddTopic: (rc) ->
    @addOneRow( @dtbl(@gid), rc, @cache[@gid] )
  onAddTopic: () ->
    me=this
    new gcc.AddTopicDlg().show( (rc) -> me.postAddTopic(rc))

  postDelTopic: (r, rc) ->
    delete @cache[@gid][r.getProviderTopicId()]
    @delOneRow(@gid)
  onDelTopic: () ->
    r= @getCurRow( @dtbl(@gid) )
    me=this
    if is_alive(r)
      r= @cache[ @gid][r[0]]
      new gcc.DelTopicDlg(r).show( (rc) -> me.postDelTopic(r,rc) )

#}

`

gcc.PushServices=PushServices;

})(window, window.document, jQuery);


`
