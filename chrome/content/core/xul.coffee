###
# file: xul.coffee
###
`

(function(genv,document,$,undefined) {
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (! is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (! is_alive(genv.ComZotoh.XUL)) { genv.ComZotoh.XUL={}; }
var Cs=Components, Css=Cs.classes, Ci=Cs.interfaces;
function SVC2(z,v) { return Css[z].getService(v); }
function SVC(z) { return Css[z].getService(); }
function CRI(z,n) { return Css[z].createInstance(n); }
var CookiesMgr = SVC2('@mozilla.org/cookiemanager;1',Ci.nsICookieManager),
C_WYSIWYG='__com_zotoh_camungo_editor__',
C_JSCON='global:console',
Cons= SVC2('@mozilla.org/consoleservice;1',Ci.nsIConsoleService),
C_FMASK=parseInt('0600',8),
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_ute= new gcc.Ute();

// get the main xul window
function gmw() {
  return genv.QueryInterface(Ci.nsIInterfaceRequestor)
    .getInterface(Ci.nsIWebNavigation)
    .QueryInterface(Ci.nsIDocShellTreeItem)
    .rootTreeItem
    .QueryInterface(Ci.nsIInterfaceRequestor)
    .getInterface(Ci.nsIDOMWindow);
}

`

class XULLib #{

  constructor: () -> @HKEY= @getBrowser()?.getAttribute('cid')
  getChromeElement: (id) -> gmw().document.getElementById(id)
  getBrowser: () -> @getChromeElement('browser-id')
  getMainWnd: () -> @getChromeElement('browser-wnd')

  getCurProcD: () -> @getIOXXX( DirIO.get('CurProcD'))
  getAChrom: () -> @getIOXXX(DirIO.get('AChrom'))
  getIOXXX: (p) -> if is_alive(p) then p.path else null

  openFileStream: (fileObj) -> FileIO.newInputStream(fileObj, "")
  downloadFile:(url,headers)->
    pk = Components.interfaces.nsIFilePicker
    fp = CRI('@mozilla.org/filepicker;1', pk)
    fp.init(genv, 'Download File', pk.modeSave)
    fp.appendFilters(pk.filterAll)
    res = fp.show()
    file=if res is pk.returnOK or res is pk.returnReplace then fp.file else null
    if is_alive(file)
      #if not file.exists() then file.create(0x00,0644)
      if not file.exists() then file.create(0x00,420)
      @getWebFile(url,headers,file)

  getWebFile: (url,headers,file) ->
    hdrs=[]
    hdrs.push("Host: " + headers['Host'] + "\r\n")
    hdrs.push("Cache-Control: no-cache\r\n")
    hdrs.push("If-Modified-Since: Tue, 15 Nov 1994 08:12:31 GMT\r\n")
    hdrs.push("Date: " + headers['Date'] + "\r\n")
    hdrs.push("Authorization: " + headers['Authorization'] + "\r\n")
    hdrs.push("content-type: " + "binary/octet-stream; charset=UTF8" + "\r\n")
    hdrs.push("\r\n")
    hdrs=hdrs.join('')
    @debug('hdrs='+hdrs)
    @debug('URL='+url)
    uri = CRI("@mozilla.org/network/standard-url;1", Ci.nsIURI)
    uri.spec = url
    bp=Ci.nsIWebBrowserPersist
    load = CRI("@mozilla.org/embedding/browser/nsWebBrowserPersist;1", bp)
    load.persistFlags = bp.PERSIST_FLAGS_REPLACE_EXISTING_FILES
    load.persistFlags=(load.persistFlags | bp.PERSIST_FLAGS_BYPASS_CACHE)
    load.persistFlags=(load.persistFlags | bp.PERSIST_FLAGS_AUTODETECT_APPLY_CONVERSION)
    load.saveURI(uri, null, null, null, hdrs, file)

  getCachedDcs: () ->
    c=@getBrowser().getUserData('cloud.acct')
    @getBrowser().getUserData('cloud.'+c.vendor+'.dcs') || {}

  getTextBoxSelection: (id)->
    dom=$('#'+id).get()
    len = dom.value.length
    start = dom.selectionStart
    end = dom.selectionEnd
    dom.value.substring(start, end)

  putTextBoxSelection: (id,str) ->
    dom=$('#'+id).get()
    first = dom.value.slice(0, dom.selectionStart)
    second = dom.value.slice(dom.selectionStart)
    dom.value = first + str + second

  debug: (msg,pms) -> @trace('DEBUG', msg,pms)
  error: (msg,pms) -> @trace('ERROR', msg,pms)
  log: (msg,pms) -> @trace('INFO', msg,pms)
  info: (msg,pms) -> @log(msg,pms)

  trace: (level, msg,paramObj) ->
    pms=@getBrowser().getUserData('log.flags') || {}
    if 'DEBUG' is level and pms.debug isnt true then return
    if pms.log isnt true then return
    if is_alive(paramObj)
      msg= Mustache.render(msg,paramObj)
    try
      s= [ '[', new Date(), '](', level, ') ', msg ].join('')
      Cons.logStringMessage(s)
    catch e

  getDirSep: () ->
    if navigator?.platform?.toLowerCase().indexOf('win') > -1 then '\\' else '/'

  safeStr: (s) -> if is_alive(s) then s.toString() else ''
  l10n : () ->
  clsCookies: () ->
    SVC2('@mozilla.org/cookiemanager;1',Ci.nsICookieManager).removeAll()

  lstCookies: () ->
    it = CookiesMgr.enumerator
    while it.hasMoreElements()
      c = it.getNext()
      # if c instanceof Ci.nsICookie then c=c

  finzJSConsole: () -> @finzWnd(C_JSCON)
  openJSConsole: () ->
    @openWnd(C_JSCON, null, 'chrome://global/content/console.xul')

  finzWnd: (inType) ->
    i = SVC('@mozilla.org/appshell/window-mediator;1').QueryInterface(Ci.nsIWindowMediator)
    en= i.getEnumerator(inType)
    top=if en? and en.hasMoreElements() then en.getNext() else null
    if top? then top.close();

  openWnd: (inType, name, uri, features) ->
    i = SVC('@mozilla.org/appshell/window-mediator;1').QueryInterface(Ci.nsIWindowMediator)
    en= if is_alive(inType) then i.getEnumerator(inType) else null
    name = name || '_blank'
    top=if is_alive(en) and en.hasMoreElements() then en.getNext() else null
    if is_alive(top)
      if C_JSCON isnt inType then top.focus()
    else
      s='chrome,extrachrome,menubar,resizable,scrollbars,status,toolbar'
      genv.open(uri, name, features || s)

  openBrowser: (uri) ->
    ps = SVC2('@mozilla.org/uriloader/external-protocol-service;1', Ci.nsIExternalProtocolService)
    uri = SVC2('@mozilla.org/network/io-service;1', Ci.nsIIOService).newURI(uri, null, null)
    #ps.loadURI(uri, null)
    ps.loadUrl(uri)

  saveFile: (title, filterName, filter, suffix, fn, blob) ->
    pick = Ci.nsIFilePicker
    fp = CRI('@mozilla.org/filepicker;1', pick)
    fp.init(genv, title, pick.modeSave)
    fp.appendFilter(filterName, filter)
    fp.appendFilters(pick.filterAll)
    fp.defaultString = fn+suffix
    res = fp.show()
    if res is pick.returnOK or res is pick.returnReplace
      aFile = fp.file
      if not aFile.exists()
        aFile.create( Ci.nsIFile.NORMAL_FILE_TYPE, C_FMASK)
      os = CRI('@mozilla.org/network/file-output-stream;1', Ci.nsIFileOutputStream)
      # open the file for read+write (04), create (08), or truncate (20)
      os.init( aFile, 0x04 | 0x08 | 0x20, C_FMASK, 0 )
      os.write( blob, blob.length )
      os.close()

  fork: (sync, cmd, args, ret) ->
    @debug('Forking: cmd= ' + cmd)
    file = CRI('@mozilla.org/file/local;1', Ci.nsILocalFile)
    argStr= ''
    file.initWithPath(cmd)
    proc= CRI('@mozilla.org/process/util;1', Ci.nsIProcess)
    try
      proc.init(file)
    catch e
      return @alarm(['Fork Error: ',cmd,'\n\n',e.message].join('') )
    try
      if is_alive(args) and args.length > 0 then argStr= args.join(' ')
      @debug('Forking: args= ' + argStr )
      proc.run(sync, args, args.length)
    catch e
      return @alarm(['Fork Error: ',cmd,'\nArgs: ',argStr,'\n\n',e.message].join(''))
    return true

  sendToClipBD: (text) ->
    str = CRI('@mozilla.org/supports-string;1', Ci.nsISupportsString)
    str.data = text || ''
    trans = CRI('@mozilla.org/widget/transferable;1', Ci.nsITransferable)
    trans.addDataFlavor('text/unicode')
    trans.setTransferData('text/unicode', str, text.length * 2)
    clipid = Ci.nsIClipboard
    clip = SVC2('@mozilla.org/widget/clipboard;1',clipid)
    clip.setData(trans,null,clipid.kGlobalClipboard)

  getFromClipBD: () ->
    clip = SVC2('@mozilla.org/widget/clipboard;1', Ci.nsIClipboard)
    trans = CRI('@mozilla.org/widget/transferable;1', Ci.nsITransferable)
    trans.addDataFlavor('text/unicode')
    clip.getData(trans, clip.kGlobalClipboard)
    strLength = new Object()
    str = new Object()
    trans.getTransferData('text/unicode', str, strLength)
    str = str.value.QueryInterface(Ci.nsISupportsString)
    str.data.substring(0, strLength.value / 2)

  alarm : (msg) -> alert(msg)

  unobfuscate: (s) ->
    if is_alive(s)
      if s.match(/^OBF:/) isnt null
        s= Crypto.AES.decrypt(s.slice(4), @HKEY)
    s

  obfuscate: (s) ->
    if is_alive(s) and g_ute.vstr(s)
      s= 'OBF:' + Crypto.AES.encrypt(s, @HKEY)
    s

XULLib.AjaxTweaks=(cbs,timeout) ->
  cbs.preAjax=(args)->
    x= args.xhr_obj.channel?.QueryInterface?( Ci.nsIHttpChannel )
    x?.redirectionLimit= 0
  cbs.waitSecs=Number(timeout)
  cbs

#}

`

gcx.XULLib=XULLib;

})(window,window.document,jQuery);


`
