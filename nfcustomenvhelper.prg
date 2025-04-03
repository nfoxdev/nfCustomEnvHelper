*-----------------------------------------------------------------------------
* Creates a custom startup environment for desired project folder
* & shortcut in selected folder.
* Marco Plaza, 2024,2025 nfox@nfox.dev
* v.1.3.1 https://github.com/nfoxdev/nfCustomEnvHelper
*-----------------------------------------------------------------------------

Private All

#Define envfolder '_customEnv'
#Define wcap 'nfCustomEnvHelper'
#Define crlf Chr(13)+Chr(10)
#Define Version "1.3"

Set Safety Off
Set Talk Off
Set Notify Off

Try

   workdir = Getdir('','Select target folder:','nfCustomEnvHelper',16+32+64)

   If !Directory(m.workdir)
      Error 'No directory selected!'
   Endif

*-- check & create vfpenv folder in destfolder

   custfilesdir = m.workdir + envfolder

   If !Directory(m.custfilesdir)
      Mkdir (m.custfilesdir)
   Endif

*-- check for _resource.dbf in dest folder:

   curresource      = Sys(2005)
   custresource   = Forcepath('resource.dbf',m.custfilesdir)


*-- SELECT CLONE / NEW ENV:

   lcreateresource    = !File(m.custresource) Or qu('Destination already has a resource file! '+crlf+' overwrite?')
   lclone             = File(m.curresource)  And m.lcreateresource And qu('Clone current resource? No = creates a new one')


*-- create resource:

   Set Resource Off

   If m.lcreateresource
      If m.lclone
         Select * From (m.curresource) Into Cursor tempresource
         Use In (Select(Juststem(m.curresource)))
         Copy To (m.custresource)
         Use
         Messagebox('Current Resource cloned',0,wcap)
      Else
         Create Table (m.custresource) ( Type c(12),Id c(12),Name m(4),ReadOnly l(1),ckval N(6,0),Data m(4),Updated d(8))
         Use
         Messagebox('New Resource created',0,wcap)
      Endif
   Endif

   Set Resource On


*-- config.fpw in dest folder:

   custconfig= Forcepath('config.fpw',m.custfilesdir)
   curconfig = Sys(2019)

   If Atc(m.custconfig,m.curconfig) = 0
      If File(m.curconfig)
         Copy File (m.curconfig) To (m.custconfig)
      Else
         Strtofile('',m.custconfig)
      Endif
   Endif


*-- pick a custom backcolor:
   custbackcolor = 0
   Messagebox('Pick a Custom Screeen BackColor...',0,wcap)
   custbackcolor = Getcolor(_Screen.BackColor)
   custbackcolor = Iif(m.custbackcolor>0,m.custbackcolor,Rgb(255,255,255))


*-- create afterstartup.prg in customconfig folder as sample
   custstartup       = Forcepath('startup.prg',m.custfilesdir)
   custafterstartup  = Forcepath('afterStartup.prg',m.custfilesdir)
   cmdhistory        = Forcepath('_command.prg',m.custfilesdir)
   createstartup(m.workdir,m.custstartup,m.custconfig,m.custbackcolor,m.cmdhistory,m.custafterstartup)

*-- set resource and call startup.prg in config.fpw
   writekey(m.custconfig,'resource',m.custresource)
   writekey(m.custconfig,'default',m.workdir)
   writekey(m.custconfig,'command',Textmerge('do "<<m.custStartup>>"'))


*-- select icon

   selectedicon    = ''

* try use folder custom icon:
   desktopinifile = Forcepath('desktop.ini',m.workdir)

   If File(m.desktopinifile,1)
      selectedicon = Getwordnum(GetKey(m.desktopinifile,'IconResource'),1,',')
   Endif


   favIcon = Forcepath("favicon.ico",m.custfilesdir)

   If !File(m.selectedicon)
      selectedIcon = m.favicon
   Endif

   If  !File(m.selectedicon) Or !qu('Use Icon '+m.selectedicon+'?',4)

      selectedicon = Getfile('Select an ico, exe or dll file to set icon for this shortcut:ico,exe,dll','Icon.:','Select',0,'Select a custom icon for this shortcut')

      If !File(m.selectedicon)
         qu('No icon selected.. using vfp icon',0)
         selectedicon = _vfp.ServerName
      Endif

   Endif


*-- when icon file selected is an ico ,  force windows to upate miniatures using a copy:

   If Lower(Justext(m.selectedicon)) == 'ico'
      iconcopy   = Forcepath('favicon'+Sys(2015)+'.ico',m.custfilesdir)
      Copy File (m.selectedicon) To (m.iconcopy)
      if selectedIcon # m.favicon
         copy file (m.selectedIcon) to (m.favicon)
      endif
      selectedicon = m.iconcopy
   Endif


*-- select shortcut folder/name:

   oshell = Createobject('wscript.shell')

   defaultshortcut = Forcepath(;
      'VFP9 @ '+Proper(Chrtran(m.workdir,'\:',' ')),;
      oshell.specialfolders.Item('desktop');
      )

   Do While .T.
      shname = Putfile('Save shortcut as: ',m.defaultshortcut,'lnk')
      Do Case
      Case !Empty(m.shname)
         Exit
      Case qu(' No valid shortcut selected - Cancel procedure?',4)
         Error 'No shortcut file name selected!'
      Endcase
   Enddo

   shname = Forceext(Rtrim(Evl(m.shname,m.defaultshortcut)),'lnk')

*-- ...create shortcut

   With m.oshell.createshortcut( m.shname )
      .targetpath         = '"'+_vfp.ServerName+'"'
      .workingdirectory   = m.workdir
      .arguments         = [-c"]+m.custconfig+["]
      .Description      = 'created using nfCustomEnvHelper'
      .windowstyle      = 1
      .iconlocation       = m.selectedicon
      .Save()
   Endwith

*-- save also in custom config folder:
   Copy File (m.shname) To (Forcepath(m.shname,m.custfilesdir))

*-- open?:

   If qu('Shortcut saved as '+m.shname+'! open? ',4)
      !Start "" "&shname"
   Endif

Catch To err When err.ErrorNo = 1098
   Messagebox(err.Message,0,wcap)

Catch To err
   Messagebox(Textmerge('oops.. <<CHR(13)>>error number:<<err.errorno>>  at:<<err.lineno>> <<CHR(13)>> <<err.message>>'),48,wcap)

Endtry

*--------------------------------------------
Function qu(cm,diagtype)
*--------------------------------------------

Local ures
diagtype = Evl(m.diagtype,3)
ures = Messagebox(m.cm,m.diagtype+Iif(m.diagtype=4,0,256),wcap)

If m.ures = 2
   Error 'Helper canceled'
Else
   Return ures = 6
Endif

*---------------------------------
Function getforecolor(tncolor)
*---------------------------------

Local r,g,b,luma
r = Bitand(m.tncolor, 0xff)
g = Bitand(Bitrshift(m.tncolor, 8), 0xff)
b = Bitand(Bitrshift(m.tncolor, 16), 0xff)


luma = ((0.299 * m.r) + (0.587 * m.g) + (0.114 * m.b)) / 255

Return Iif(m.luma > 0.7, Rgb(0,0,0), Rgb(255,255,255))

*---------------------------------
Function GetKey(m.csrc,Key)
*---------------------------------
Local Value
Local nel
Local Array aa(1)

Value = ''
Try

   Alines(aa,Filetostr(m.csrc))
   nel=Ascan(aa,m.key)
   If Upper( Getwordnum(aa(m.nel),1,'=')) == Upper(m.key)
      Value = Getwordnum(aa(m.nel),2,'=')
   Endif

Catch
Endtry

Return m.value


*-------------------------------------
Function writekey(m.csrc,Key,Value)
*-------------------------------------

Local nkv,addk,Line,aa(1)

If Vartype(m.key) # 'C' Or Vartype(m.value) # 'C'
   Error 'key value not a character expression'
Endif

nkv = m.key+'='+m.value+crlf

Alines(aa,Filetostr(m.csrc))

addk = .T.

Strtofile('',m.csrc)

For Each Line In aa

   If Atc(m.key,Getwordnum(m.line,1,'='))>0
      Strtofile(m.nkv,m.csrc,1)
      addk = .F.
   Else
      Strtofile(m.line+crlf,m.csrc,1)
   Endif

Endfor

If m.addk
   Strtofile(m.nkv,m.csrc,1)
Endif


*---------------------------------------------------------------------------------------------
Procedure createstartup(workdir,custstartup,custconfig,custbackcolor,cmdhistory,afterstartup)
*---------------------------------------------------------------------------------------------

*-- creates startup.prg for this project folder

thisprg = Forceext(Getwordnum(Sys(16),3),'prg')
nfutils = Forcepath("nfCustomEnvHelperUtils.prg",Justpath(m.thisprg))

TEXT to temp noshow textmerge
*-------------------------------------------------------
* Custom startup generated by nfCustomEnvHelper.prg
* DO NOT EDIT THIS FILE! TO ADD EXTRA STEPS AT STARTUP, USE "EDIT AFTERSTARTUP.PRG" IN OPTIONS MENU
* https://github.com/nfoxdev/nfCustomEnvHelper
*-------------------------------------------------------


define pad _devpad of _msysmenu prompt 'Custom Env.'
define popup _devpop 
define bar 1 of _devpop prompt ' New Folder shortcut with custom environment' 
define bar 2 of _devpop prompt ' do <<JUSTFNAME(m.custStartup)>>' key F5,'F5'
define bar 3 of _devpop prompt '* View/Edit' style 'B' invert
define bar 4 of _devpop prompt ' edit <<JUSTFNAME(m.custConfig)>>'
define bar 5 of _devpop prompt ' edit common startup '
define bar 6 of _devpop prompt ' edit project startup'
define bar 7 of _devpop prompt ' edit command history'

on pad _devpad of _msysmenu activate popup _devpop
on selection bar 1 of _devpop do "<<m.thisprg>>"
on selection bar 2 of _devpop do "<<m.custStartup>>"

on selection bar 4 of _devpop editsource("<<m.custConfig>>")
on selection bar 5 of _devpop editsource("<<m.nfUtils>>")
on selection bar 6 of _devpop editsource("<<m.afterStartup>>")
on selection bar 7 of _devpop editsource("<<m.cmdHistory>>")

set status bar on
set memowidth to 100

cd "<<m.workdir>>"

with _screen

  .caption     = fullpath('')
  .forecolor   = <<getforecolor(m.custbackcolor)>>
  .backcolor   = <<m.custbackcolor>>

endwith

do <<forcepath("nfcustomenvhelperutils.prg",justpath(m.thisprg))>>

if file("<<m.afterStartup>>")
  do "<<m.afterStartup>>"
endif

set sysmenu save

ENDTEXT

*-- save startup.prg:

Strtofile(m.temp,m.custstartup)


*-- create afterStartup.prg if not present:

If !File(m.afterstartup)

   TEXT to temp noshow textmerge
*-------------------------------------------------------
* Generated by nfCustEnvHelper.prg
* https://github.com/nfoxdev/customEnvHelper
*-------------------------------------------------------
* place here code to run after startup for this project
*
*
   ENDTEXT

   Strtofile(m.temp,m.afterstartup)

Endif

