###
# file: form.coffee
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

class HtmlForm #{

  constructor:(style)->
    @args={ btns: {yes:1,no:1}, yesLabel: @l10n('%savebtn'), noLabel: @l10n('%nokbtn'), flds: {}  }
    @fidAutoFocus=''
    @style=style || 'form-vertical'

  getAutoFocusFld: () -> @fidAutoFocus
  l10n: (k,p) -> gcc.L10N(k,p)
  getYesLabel: () -> @args.yesLabel
  getNoLabel: () -> @args.noLabel
  getBtnFlags: () -> @args.btns
  validate: (ctx) ->
    flags=[]
    me=this
    _.each( @args.flds, (v,k) -> me.testOneField(ctx, flags, k,v))
    if flags.length is 0 then true else false
  chkField: (ctx, flags, id, fld,value) ->
  testOneField: (ctx, flags, id, fld) ->
    v= g_ute.trim( $('#'+id, ctx).val())
    if fld.reqd is 1 and not g_ute.vstr(v) then @flagError(ctx, flags, id) else @chkField(ctx,flags,id,fld,v)
  flagError: (ctx, flags, id) ->
    cgid= ['#', id , '-cg'].join('')
    $(cgid,ctx).addClass('error')
    $(cgid+' .help-inline',ctx).show()
    flags.push(id)
  unflagErrors: (ctx) ->
    $('.control-group', ctx).removeClass('error')
    $('.control-group .help-inline', ctx).hide()
  iniz: (args) ->
    _.extend( @args, args || {} )
    if not is_alive( @args.flds) then @args.flds={}
  render: () ->
    flds=[]
    me=this
    _.each( @args.flds, (v,k)-> me.addOneField(flds, k,v) )
    g_ute.trim( @fmtForm(flds))
  postShow: (ctx) ->
    if g_ute.vstr( @fidAutoFocus) then $('#'+@fidAutoFocus, ctx).focus()
  preShow: (ctx) ->
    $('.control-group .help-inline', ctx).hide()
    me=this
    _.each(@args.flds, (v,k)->me.bindEvents(ctx,k,v))
  doSave: (ctx,okcb,nocb) ->
    f=()-> nocb('some error happened')
    genv.setTimeout(f, 2000)
  bindEvents: (ctx, k,v) ->
    switch v.kind
      when 'rbns'
        t=$('#'+k+'-cg input[type="radio"]', ctx)
      else
        t=$('#'+k, ctx)
    if v.hide is 1 then t.hide()
    if is_alive(v.bind) then t.bind( v.bind.evt, v.bind.cb )
  addOneField: (flds, k,v) ->
    if not g_ute.vstr(@fidAutoFocus) then @fidAutoFocus=k
    s=''
    if not is_alive(v.kind) then v.kind='text'
    switch v.kind
      when 'file','text','number','email','password' then s=@addTextField(k,v)
      when 'html' then s= g_ute.trim(v.html)
      when 'tbox' then s=@addTextBox(k,v)
      when 'cbox' then s=@addCheckBox(k,v)
      when 'list' then s=@addDDList(k,v)
      when 'rbns' then s=@addRadios(k,v)
      when 'link' then s=@addAnchor(k,v)
      when 'pklist' then s=@addPickList(k,v)
      when 'accordion' then s=@addAccordion(k,v)
    if g_ute.vstr(s) then flds.push(s)
  addAnchor: (k,v) ->
    if not is_alive(v.href) then v.href='#'
    @addXXXField(gcc.Widget.AnchorTpl(),k,v)
  addPickList: (k,v) -> @addXXXField( gcc.Widget.PickListTpl(),k,v)
  addTextField: (k,v) -> @addXXXField( gcc.Widget.EditBoxTpl(),k,v)
  addCheckBox: (k,v) -> @addXXXField( gcc.Widget.CBoxTpl(),k,v)
  addTextBox: (k,v) ->
    if _.has(v,'cols') then v.cols='cols="'+v.cols+'"'
    @addXXXField( gcc.Widget.TBoxTpl(),k,v)
  addDDList: (k,v) ->
    v.multi= if v.multi is 1 then 'multiple="multiple"' else ''
    @addXXXField( gcc.Widget.DDListTpl(),k,v)
  addAccordion: (k,v) ->
    @addXXXField( gcc.Widget.AccordionTpl(),k,v)
  addRadios: (k,v) ->
    fc=(em,i)->
      if em.chkd is 1 then em.checked='checked'
      if v.line is 1 then em.inline='inline'
      em.fid=[v.fid,'-',i].join('')
      em.fname=v.fname
    _.each(v.rbtns,fc)
    @addXXXField( gcc.Widget.RadiosTpl(), k,v)
  addXXXField:(tpl,k,v) ->
    if g_ute.vstr(v.lbl) then v.flabel={ lbl: v.lbl, fid:k}
    v.czs=[]
    if v.reqd is 1 then v.required='required'
    if v.chkd is 1 then v.checked='checked'
    if v.off is 1 
      v.disabled='disabled'
      v.czs.push('disabled')
    if v.focus is 1
      v.autofocus='autofocus'
      @fidAutoFocus= k
    _.extend(v, {help:'!'})
    v.czs=v.czs.join('')
    v.fid=k
    v.html=Mustache.render( tpl, v )
    tpl = if v.kind is 'cbox' and v.inline isnt false then gcc.Widget.InlineCBoxTpl() else gcc.Widget.FormCtlTpl()
    g_ute.trim( if v.isown is true then v.html else Mustache.render( tpl, v) )
  fmtForm: (flds) ->
    switch @style
      when 'form-horizontal' then s= gcc.Widget.FormHorzTpl()
      else s= gcc.Widget.FormTpl()
    Mustache.render( s, { fflds: flds.join('') } )
  getMultiDDList: (id) ->
    rc=[]
    $('#'+id+' option').filter(':selected').each( () -> rc.push($(this).attr('value')) )
    rc
  htmOneDDListOpt: (k,v) -> 
    ['<option value="', k, '">', v || k , '</option>'].join('')
  dispWaitDDList: (id,ctx)->
    id='#'+id
    em=if is_alive(ctx) then $(id,ctx) else $(id)
    em.empty().html('<option value="-1">'+ gcc.L10N('%load.wait') + '</option>')
    em
  dispNoneDDList: (id,ctx)->
    id='#'+id
    em=if is_alive(ctx) then $(id,ctx) else $(id)
    em.empty().html('<option value="-1">'+ gcc.L10N('%load.none') + '</option>')
    em
  dispErrorDDList: (id,ctx)->
    id='#'+id
    em=if is_alive(ctx) then $(id,ctx) else $(id)
    em.empty().html('<option value="-1">'+ gcc.L10N('%load.bad') + '</option>')
    id=id + '-cg'
    em=if is_alive(ctx) then $(id,ctx) else $(id)
    em.addClass('error')
    em
  clrDDList: (id,ctx)->
    id='#'+id
    em=if is_alive(ctx) then $(id,ctx) else $(id)
    em.empty()
    em

#}


`

gcc.HtmlForm=HtmlForm;

})(window, window.document, jQuery);


`
