###
# file: formcontainer.coffee
###
`
(function(genv, document, $, undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (!is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (!is_alive(genv.ComZotoh.Camungo)) { genv.ComZotoh.Camungo={}; }
var gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();


`

class FormContainer #{
  constructor: () ->
  renderForm: (ctx,form) ->
    @renderFormHeader(ctx,form)
    @renderFormBody(ctx,form)
    @renderFormFooter(ctx,form)
    @renderFormEnd(ctx,form)
  renderFormHeader: (ctx,form) ->
  renderFormEnd: (ctx,form) ->
  renderFormBody: (ctx,form) ->
    $('.modal-body', ctx).empty().html( form.render() ).css('background-color','#fff')
  renderFormFooter: (ctx,form) ->
    em=$('.modal-footer', ctx).empty()
    me=this
    bf=form.getBtnFlags()
    fs=[]
    if bf.no is 1 then fs.push( Mustache.render(@noBtn, { nobtn: form.getNoLabel() }) )
    if bf.yes is 1 then fs.push( Mustache.render(@yesBtn, { yesbtn: form.getYesLabel() }))
    s=Mustache.render( @formfooter, { footerbtns: fs.join('') } )
    em.html( g_ute.trim(s))
    if bf.yes is 1 then $('#okbtn', ctx).click( () -> me.onSave(ctx,form) )
    if bf.no is 1 then $('#nobtn', ctx).click( () -> me.onNOK(ctx) )
  hideSaveWait:(ctx,form) -> @renderFormFooter(ctx,form)
  showSaveWait:(ctx) ->
    htm=Mustache.render(@infodiv, { msg: gcc.L10N('%saving.wait')})
    $('.modal-footer', ctx).empty().html(g_ute.trim(htm))
  onSave: (ctx,form) ->
    form.unflagErrors(ctx)
    me=this
    if form.validate(ctx)
      @showSaveWait(ctx)
      nocb=(e)-> me.onSaveError(ctx,form,e)
      okcb=(robj)-> me.onSaveOK(ctx, robj)
      form.doSave(ctx,okcb,nocb)
  l10n: (k,p) -> gcc.L10N(k,p)
  onOK: (ctx, robj) ->
  onNOK: (ctx) ->
  onSaveOK: (ctx,robj) ->
    me=this
    fc= ()-> me.onOK(ctx,robj)
    genv.setTimeout( fc,0)
  onSaveErrorRetry: (ctx,form) -> @hideSaveWait(ctx,form)
  onSaveError: (ctx, form,err) ->
    htm=Mustache.render(@errordiv, { trytxt: gcc.L10N('%try.again'), msg: err.getFaultMsg() })
    $('.modal-footer', ctx).empty().html( g_ute.trim(htm) )
    me=this
    f=()-> me.onSaveErrorRetry(ctx,form)
    $('#tryagain', ctx).click(f)
  arrDcChoices: () ->
    bw=g_xul.getBrowser()
    c=bw.getUserData('cloud.acct')
    dcs=bw.getUserData('cloud.'+c.vendor+'.dcs') || {}
    me=this
    _.map(_.keys(dcs).sort(), (v)-> { disp: v, value: v } )
  arrChoice:(k,v)-> { disp: k, value: v || k }
  errortxt: """
    <div class="alert-text">
      <p>
      <span class="badge badge-error">!</span><span>&nbsp;&nbsp;{{ohsnap}}&nbsp;&nbsp;</span>{{{msg}}}
      </p>
    </div>
  """

  errordiv: """
    <div class="alert alert-error">
      <p class="pull-left">
      {{{msg}}}
      </p>
      <p>
      <a class="pull-right" id="tryagain" href="#" style="text-decoration:underline;">{{trytxt}}?</a>
      </p>
      <span class="clrFloats">&nbsp;</span>
    </div>
  """

  infodiv: """
    <div class="alert alert-info">{{{msg}}}</div>
  """

  formfooter: """
        <div id="fmfooter">
          {{{footerbtns}}}
        </div>
  """

  yesBtn: """
    <a href="#" id="okbtn" data-loading-text="Saving..." class="btn btn-primary">{{{yesbtn}}}</a>
  """

  noBtn: """
    <a href="#" id="nobtn" class="btn">{{{nobtn}}}</a>
  """

  okfooter: """
        <a href="#" id="okbtn" class="btn">{{{okbtn}}}</a>
  """

  mboxfooter: """
        <a href="#" id="okbtn" class="btn btn-primary">{{{okbtn}}}</a>
  """

  ynboxfooter: """
        <a href="#" id="nobtn" class="btn btn-primary">{{{nobtn}}}</a>
        <a href="#" id="okbtn" class="btn">{{{yesbtn}}}</a>
  """

#}


`

gcc.FormContainer=FormContainer;

})(window, window.document, jQuery);


`
