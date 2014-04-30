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
C_RGS=[ 'EU', 'eu-west-1', 'us-west-1', 'us-west-2', 'ap-southeast-1', 'ap-northeast-1', 'sa-east-1' ].sort(),
gcc=gc.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class UploadCFileFm extends gcc.HtmlForm #{
  constructor: (@dir) -> super()
  doSave: (ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getStorageServices().getBlobStoreSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    fn=g_ute.trim($('#fld2',ctx).val())
    fp=g_ute.trim($('#fld3',ctx).val())
    fp=FileIO.openPath(fp)
    blob={ size: fp.fileSize, data: () -> g_xul.openFileStream(fp) }
    svc.upload(@dir.getName(), fn, 'binary/octet-stream; charset=UTF-8', blob, {}, false, '', cbs)
  postShow:(ctx)->
    $('#fld1',ctx).addClass('disabled')
    super(ctx)
#}
class UploadCFileDlg extends gcc.ModalDlg #{
  constructor: (@dir) -> super({ title: gcc.L10N('%upload.file') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new UploadCFileFm(@dir)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { off:1,lbl: @l10n('%cfiles.dir'),width:'dlg-s8s',value:@dir.getName() }
    args.flds.fld2= { reqd:1,lbl: @l10n('%cfiles.file'),width:'dlg-s8s',focus:1 }
    args.flds.fld3= { reqd:1,kind:'file',lbl: @l10n('%local.file'),width:'dlg-s8s' }
    args.yesLabel= @l10n('%uploadbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelCFileFm extends gcc.HtmlForm #{
  constructor: (@dir,@file) -> super()
  doSave:(ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getStorageServices().getBlobStoreSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.removeFile(@dir.getName(), @file.getName(),{}, cbs)
  postShow:(ctx)->
    $('form input[type="text"]',ctx).addClass('disabled')
    super(ctx)
#}

class DelCFileDlg extends gcc.ModalDlg #{
  constructor: (@dir,@file) -> super({ title: gcc.L10N('%del.file') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new DelCFileFm(@dir,@file)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { off:1,lbl: @l10n('%cfiles.dir'),width:'dlg-s8s',value:@dir.getName() }
    args.flds.fld2= { off:1,lbl: @l10n('%cfiles.file'),width:'dlg-s8s',value:@file.getName()}
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


class DelCDirFm extends gcc.HtmlForm #{
  constructor: (@dir) -> super()
  doSave:(ctx,ok,nok) ->
    svc=gcc.HtmlPage.cloud.getStorageServices().getBlobStoreSupport()
    svc.removeDirectory(@dir.getName(),gcc.PivotItem.CBS(ok,nok))
  postShow:(ctx)->
    $('form input[type="text"]',ctx).addClass('disabled')
    super(ctx)
#}
class DelCDirDlg extends gcc.ModalDlg #{
  constructor: (@dir) -> super({ title: gcc.L10N('%del.cfile.dir') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new DelCDirFm(@dir)
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%cfiles.dir'),width:'dlg-s8s', value: @dir.getName(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class AddCDirFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok) ->
    nm=g_ute.trim($('#fld1',ctx).val())
    r=$('#fld2',ctx).val()
    if r is '-1' then r=''
    svc=gcc.HtmlPage.cloud.getStorageServices().getBlobStoreSupport()
    cbs=gcc.PivotItem.CBS(ok,nok)
    svc.createDirectory(nm,r,{'x-amz-acl':'bucket-owner-full-control'},cbs)
#}
class AddCDirDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.cfile.dir') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddCDirFm()
    @callerCB=cb
    me=this
    args={ flds: {} }
    args.flds.fld1= { lbl: @l10n('%cfiles.dir'),width:'dlg-s8s',redq:1,focus:1 }
    a=[{disp:@l10n('%region.us.std'),value:'-1'}]
    a=a.concat( _.map(C_RGS,(v)->{disp:v,value:v}))
    args.flds.fld2= { lbl: @l10n('%region'),kind:'list',choices:a }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

`

gcc.UploadCFileDlg=UploadCFileDlg;
gcc.DelCFileDlg=DelCFileDlg;
gcc.AddCDirDlg=AddCDirDlg;
gcc.DelCDirDlg=DelCDirDlg;

})(window, window.document, jQuery);


`
