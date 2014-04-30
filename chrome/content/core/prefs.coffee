###
# file: prefs.coffee
###
`
(function(genv,document,$,undefined){
"use strict";
function is_alive(a) { return typeof a !== 'undefined' && a !== null; }
if (! is_alive(genv.ComZotoh)) { genv.ComZotoh={}; }
if (! is_alive(genv.ComZotoh.XUL)) { genv.ComZotoh.XUL={}; }
var Cs=Components, Css=Cs.classes, Ci=Cs.interfaces;
function SVC2(z,v) { return Css[z].getService(v); }
function SVC(z) { return Css[z].getService(); }
function CRI(z,n) { return Css[z].createInstance(n); }
var Brch=SVC2('@mozilla.org/preferences-service;1', Components.interfaces.nsIPrefBranch ),
CK_DUMMYPROP='933dfeae-605b-4d0d-84f7-0c205635c7e5',
CK_SSHCMDARGS='ssh.cmdargs',
CK_SSHCMD='ssh.cmd',
CK_SCPCMD='ssh.cpcmd',
CK_SSHUSER='ssh.user',
CK_SSHKEY='ssh.key',
CK_LOGGING='prefs.logging',
CK_DEBUG='prefs.debug',
CK_JSCONS='prefs.jscons',
CK_REQWAIT='prefs.reqwait',
gcc=genv.ComZotoh.Camungo,
gcx=genv.ComZotoh.XUL,
g_xul=new gcx.XULLib(),
g_ute=new gcc.Ute();

`

class Prefs #{

  constructor: () ->  @iniz()
  iniz: () ->
    if not Brch.prefHasUserValue(CK_REQWAIT) then @saveInt(CK_REQWAIT,30)
  reset: () -> Brch.deleteBranch('cz.camungo')
  cok: (name,type) ->
    Brch.prefHasUserValue(name) and Brch.getPrefType(name) is type
  getStr: (name, dft)  ->
    dft=dft || ''
    if @cok(name, Brch.PREF_STRING) then Brch.getCharPref(name).toString() else dft
  getInt: (name, dft) ->
    dft= dft || 0
    if @cok(name, Brch.PREF_INT) then Brch.getIntPref(name) else dft
  getBool: (name, dft) ->
    dft= dft || false
    if @cok(name, Brch.PREF_BOOL) then Brch.getBoolPref(name) else dft
  saveStr: (name, value) -> Brch.setCharPref(name, value)
  saveInt: (name, value) -> Brch.setIntPref(name, value)
  saveBool: (name, value) -> Brch.setBoolPref(name, value)
  setEnableDebug:(flag) -> @saveBool(CK_DEBUG, flag)
  getEnableDebug:() -> @getBool(CK_DEBUG)
  setEnableLog:(flag) -> @saveBool(CK_LOGGING, flag)
  getEnableLog:() -> @getBool(CK_LOGGING)
  setJSCons:(flag) -> @saveBool(CK_JSCONS, flag)
  getJSCons:() -> @getBool(CK_JSCONS)
  setREQWait:(n) -> @saveInt(CK_REQWAIT, n)
  getREQWait:() -> @getInt(CK_REQWAIT)

  setSSHCmd: (s) -> @saveStr(CK_SSHCMD, s || '')
  getSSHCmd: () ->
    s= @getStr(CK_SSHCMD, '')
    if g_ute.vstr(s) then s else @getDftSSHCmdArgs()[0] 

  setSSHCmdArgs: (s) -> @saveStr(CK_SSHCMDARGS, s || '')
  getSSHCmdArgs: () ->
    s= @getStr(CK_SSHCMDARGS, '')
    if g_ute.vstr(s) then s else @getDftSSHCmdArgs()[1] 

  setSCPCmd: (s) -> @saveStr(CK_SCPCMD, s || '')
  getSCPCmd: () ->
    s= @getStr(CK_SCPCMD, '')
    if g_ute.vstr(s) then s else @getDftSCPCmdArgs()[0]

  setSSHUser: (s) -> @saveStr(CK_SSHUSER, s || '')
  getSSHUser: () ->
    s= @getStr(CK_SSHUSER, '')
    if g_ute.vstr(s) then s else 'ec2-user'

  setSSHKey: (s) -> @saveStr(CK_SSHKEY, s || '')
  getSSHKey: () ->
    s= @getStr(CK_SSHKEY, '')
    if g_ute.vstr(s) then s else @getDftKeyPath()

  resetSSHCfg: () ->
    @setSSHKey( @getDftKeyPath())
    @setSSHUser( 'ec2-user')
    @setSCPCmd( @getDftSCPCmdArgs()[0] )
    @setSSHCmdArgs( @getDftSSHCmdArgs()[1])
    @setSSHCmd( @getDftSSHCmdArgs()[0])

  sshHost: (host, keyname) ->
    env = SVC2('@mozilla.org/process/environment;1', Ci.nsIEnvironment)
    if env.exists('HOME')
      home = env.get('HOME')
    else if env.exists('HOMEDRIVE') and env.exists('HOMEPATH')
      home = env.get('HOMEDRIVE') + env.get('HOMEPATH')
    home= home || ''
    argStr = @getSSHCmdArgs().replace(/\${home}/g, home)
    cmd = @getSSHCmd().replace(/\${home}/g, home)
    cmd = cmd.replace(/\${procdir}/g, g_xul.getCurProcD())

    # ${keyname} and ${key}
    keyTpl = @getSSHKey().replace(/\${keyname}/g, keyname).replace(/\${home}/g, home)
    argStr = argStr.replace(/\${key}/g, keyTpl)
    # ${user}
    argStr = argStr.replace(/\${user}/g, @getSSHUser() || 'root')
    # ${host}
    argStr = argStr.replace(/\${host}/g, host)
    args = g_ute.tokenize(argStr)
    g_xul.debug( [ args, args.length, 'cmd: ', cmd, 'args: ', args.join(',') ].join('\n') )
    g_xul.fork(false,cmd,args)

  osxScript: """
            on run argv
              tell app "System Events" to set termOn to (exists process "Terminal")
              set cmd to "ssh -i " & item 1 of argv & " " & item 2 of argv
              if (termOn) then
                tell app "Terminal" to do script cmd
              else
                tell app "Terminal" to do script cmd in front window
              end if
              tell app "Terminal" to activate
            end run
  """

  getDftSSHCmdArgs : () ->
    sfx= ' "${key}" ${user}@${host}'
    if g_ute.isOSX()
      a=@osxScript.split('\n') || []
      cb=(s) -> 
        s=(s || '').trim()
        if s.length is 0 then '' else "-e '" + s + "'"
      args= _.map(a,cb).join(' ') + sfx
      cmd= '/usr/bin/osascript'
    else if g_ute.isLinux()
      args= '-x /usr/bin/ssh -i ' + sfx
      cmd= '/usr/bin/gnome-terminal'
    else
      args= '-i ' + sfx
      cmd= @puttyExePath()
    [ cmd, args ]

  getDftSCPCmdArgs : () ->
    if g_ute.isOSX()
      cmd='/usr/bin/osascript'
    else if g_ute.isLinux()
      cmd= '/usr/bin/gnome-terminal'
    else
      cmd= @pscpExePath()
    [ cmd, '']

  getDftKeyPath: () ->
    if g_ute.isWIN() then '${home}\\${keyname}.ppk' else '${home}/id_${keyname}'

  puttyExePath : () -> @puttyPath('putty.exe')
  pscpExePath: () -> @puttyPath('pscp.exe')
  puttyPath: (exe) ->
    [ '${procdir}', DirIO.sep , 'putty' , DirIO.sep , exe ].join('')

  getAcctPropsDB: () -> g_xul.getBrowser().getUserData('db.acctprops')
  getAcctsDB: () -> g_xul.getBrowser().getUserData('db.accts')
  getUsersDB: () -> g_xul.getBrowser().getUserData('db.users')

#}


`

gcx.Prefs=Prefs;

})(window, window.document, jQuery);


`



