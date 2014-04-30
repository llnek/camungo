###
# file: pubsub.coffee
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

class AddTopicFm extends gcc.HtmlForm #{
  constructor: () -> super()
  doSave:(ctx,ok,nok) ->
    n=g_ute.trim($('#fld1',ctx).val())
    svc= gcc.HtmlPage.cloud.getPlatformServices().getPushNotificationSupport()
    svc.createTopic(n, gcc.PivotItem.CBS(ok,nok))
#}
class AddTopicDlg extends gcc.ModalDlg #{
  constructor: () -> super({ title: gcc.L10N('%new.topic') })
  onOK: (ctx,rc) -> @callerCB?(rc)
  show: (cb) ->
    f=new AddTopicFm()
    @callerCB=cb
    me=this
    args={ flds: {}}
    args.flds.fld1= { reqd:1,focus:1,lbl: @l10n('%name'),width:'dlg-s8s' }
    args.yesLabel= @l10n('%createbtn')
    f.iniz(args)
    @inizAsForm(f)
#}

class DelTopicFm extends gcc.HtmlForm #{
  constructor: (@topic) -> super()
  doSave:(ctx,ok,nok)->
    svc= gcc.HtmlPage.cloud.getPlatformServices().getPushNotificationSupport()
    svc.removeTopic(@topic.getProviderTopicId(), gcc.PivotItem.CBS(ok,nok))
  postShow:(dlg)->
    $('input[type="text"]', dlg).addClass('disabled')
    super(dlg)
#}
class DelTopicDlg extends gcc.ModalDlg #{
  constructor: (@topic) -> super({ title: gcc.L10N('%del.topic') })
  onOK: (ctx,rc) -> @callerCB?(@topic)
  show: (cb) ->
    f=new DelTopicFm(@topic)
    @callerCB=cb
    me=this
    args={ flds: {}}
    args.flds.fld1= { lbl: @l10n('%topic.id'),width:'dlg-s8s',value: @topic.getProviderTopicId(), off:1 }
    args.yesLabel= @l10n('%deletebtn')
    f.iniz(args)
    @inizAsForm(f)
#}


`

gcc.AddTopicDlg=AddTopicDlg;
gcc.DelTopicDlg=DelTopicDlg;

})(window, window.document, jQuery);


`
