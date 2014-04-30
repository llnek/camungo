###
# file: cfiles.coffee
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

class CloudFiles extends gcc.PivotItemPC #{

  constructor: () ->
    super('%topic.cfiles','cdirs-grid','cfiles-grid')
    @cm0= [ @tct('%id'), @tct('%cfiles.dir'),@tct('%creation') ]
    @cm1= [ @tct('%id'), @tct('%cfiles.file'),@tct('%size.bytes'), @tct('%lastmod') ]
  moniker: 'cfiles'
  id: 'cfiles-tpl'
  cid: 'cftbar'
  getTpl: () ->
    icons= @basicIcons()
    icons.push {linkid: @btnid('add') , title: @l10n('%new.cfile.dir'),icon:'add'}
    icons.push {linkid: @btnid('del'), title: @l10n('%del.cfile.dir'),icon:'minus'}
    bObj=[]
    bObj.push { btn: @l10n('%upload'), bid:'btn-upload'}
    bObj.push { btn: @l10n('%dnload'), bid: 'btn-dnload'}
    bObj.push { btn: @l10n('%delete'), bid:'btn-purge'}
    s=Mustache.render(@midsect,{tbar: @l10n('%files'), cid: @cid, btns: bObj})
    s= [ @tableHtml( @par_gid) , s , @tableHtml(@c_gid), @footerMenu(icons) ].join('')
    g_ute.trim(s)
  onRefresh: () ->
    svc=gcc.HtmlPage.cloud.getStorageServices().getBlobStoreSupport()
    @onSync(svc,svc.listDirectories, [], @par_gid)
  fmtAsRow: (dtb,row) ->
    id=row.getName()
    if dtb.attr('id') is @par_gid
      [id,[id,id,row.getCreationTimestamp() ]]
    else
      [id,[id,id,row.getSizeInBytes(),row.getLastModified() ]]
  onParClicked: (table,data) ->
    svc=gcc.HtmlPage.cloud.getStorageServices().getBlobStoreSupport()
    row=@cache[@par_gid][ data[0] ]
    dir=row.getName()
    me=this
    nok=()->
      me.showChildBusy(false,me.cid)
    ok=(rc)-> 
      me.showChildBusy(false,me.cid)
      me.uploadTable( me.c_gid, rc)
    @showChildBusy(true,@cid)
    svc.listFiles('',dir,{},gcc.PivotItem.CBS(ok,nok))
  setEvents: () ->
    super()
    me=this
    $('#'+ @btnid('del')).click( () -> me.onDelDir() )
    $('#'+ @btnid('add')).click( ()-> me.onAddDir() )
    $('#btn-upload').click( ()-> me.onUploadFile() )
    $('#btn-dnload').click( ()-> me.onDnloadFile() )
    $('#btn-purge').click( ()-> me.onDelFile() )
  postUploadFile:(r,rc)->
  onUploadFile: ()->
    r= @getCurRow( @dtbl(@par_gid) )
    me=this
    if is_alive(r)
      r= @cache[ @par_gid][r[0]]
      new gcc.UploadCFileDlg(r).show( (rc) -> me.postUploadFile(r,rc))
  onDnloadFile: ()->
    svc=gcc.HtmlPage.cloud.getStorageServices().getBlobStoreSupport()
    p= @getCurRow( @dtbl(@par_gid) )
    r= @getCurRow( @dtbl(@c_gid) )
    me=this
    if is_alive(p) and is_alive(r)
      p= @cache[ @par_gid][p[0]]
      r= @cache[ @c_gid][r[0]]
      nok=()->
      ok=(url,hdrs) -> g_xul.downloadFile(url,hdrs)
      cbs=gcc.PivotItem.CBS(ok,nok)
      svc.getDownloadUrl(p.getName(),r.getName(),cbs)
  postDelFile:(r,rc)->
    delete @cache[ @c_gid][r.getName()]
    @delOneRow(@c_gid)
  onDelFile: ()->
    p= @getCurRow( @dtbl(@par_gid) )
    r= @getCurRow( @dtbl(@c_gid) )
    me=this
    if is_alive(p) and is_alive(r)
      p= @cache[ @par_gid][p[0]]
      r= @cache[ @c_gid][r[0]]
      new gcc.DelCFileDlg(p,r).show( (rc) -> me.postDelFile(r,rc))
  postAddDir: (rc)->
    @addOneRow( @dtbl(@par_gid),rc, @cache[@par_gid] )
  onAddDir: () ->
    me=this
    new gcc.AddCDirDlg().show( (rc) -> me.postAddDir(rc) )
  postDelDir: (r, rc)->
    delete @cache[@par_gid][r.getName()]
    @delOneRow(@par_gid)
  onDelDir: () ->
    r= @getCurRow( @dtbl(@par_gid) )
    me=this
    if is_alive(r)
      r= @cache[ @par_gid][r[0]]
      new gcc.DelCDirDlg(r).show( (rc) -> me.postDelDir(r,rc) )

#}

`

gcc.CloudFiles=CloudFiles;

})(window, window.document, jQuery);


`
