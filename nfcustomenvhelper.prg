*-----------------------------------------------------------------------------
* Creates a custom startup environment for desired project folder
* & shortcut in selected folder.
* Marco Plaza, 2024,2025 nfox@nfox.dev
* v.1.4.2 https://github.com/nfoxdev/nfCustomEnvHelper 
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

   lcreateresource    = !File(m.custresource) Or qu('Destination already has a resource file! '+crlf+' overwrite?',3)
   lclone             = File(m.curresource)  And m.lcreateresource And qu('Clone current resource? No = creates a new one',3)


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
   custbackcolor = Evl(Getcolor(_screen.BackColor),_Screen.BackColor)
   custforecolor = getforecolor(m.custbackcolor)


*-- set resource and call startup.prg in config.fpw

   thispath = justpath(sys(16))

   custStartup = 'do "'+forcepath('nfCustomEnvHelperMenu.prg',m.thispath)+'" with "'+m.workdir+'"'
   

   writekey(m.custconfig,'resource',m.custresource)
   writekey(m.custconfig,'default',m.workdir)
   writekey(m.custconfig,'command',m.custStartup)

   writekey(m.custconfig,'screenBackColor',Str(m.custbackcolor))
   writekey(m.custconfig,'screenForeColor',Str(m.custforecolor))


*-- select icon

   selectedicon    = ''

* try use folder custom icon:
   desktopinifile = Forcepath('desktop.ini',m.workdir)

   If File(m.desktopinifile,1)
      selectedicon = Getwordnum(GetKey(m.desktopinifile,'IconResource'),1,',')
   Endif


   favicon = Forcepath("favicon.ico",m.custfilesdir)

   If !File(m.selectedicon)
      selectedicon = m.favicon
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
      cIcons = filetostr(m.selectedicon)
      iconcopy   = Forcepath('favicon'+Sys(2015)+'.ico',m.custfilesdir)
      erase (forcepath('favicon_*.ico',m.custfilesdir))
      strtofile(m.cicons,(m.iconcopy))
      If selectedicon # m.favicon
         strtofile(m.cicons,(m.favicon))
      endif
      release cIcons
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

*-- delete old version files:
   erase (forcepath('startup.*',m.custfilesdir))

Catch To err When err.ErrorNo = 1098
   Messagebox(err.Message,0,wcap)

Catch To err
   Messagebox(Textmerge('oops.. <<CHR(13)>>error number:<<err.errorno>>  at:<<err.lineno>> <<CHR(13)>> <<err.message>>'),48,wcap)

Endtry

*--------------------------------------------
Function qu(cm,diagtype)
*--------------------------------------------

Local ures
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

Local nkv,Key,keyfound
local array aa(1)

If Vartype(m.key) # 'C' Or Vartype(m.value) # 'C'
   Error 'key value not a character expression'
Endif

nkv = m.key+'='+m.value

Key = Upper(Alltrim(m.key))

Alines(aa,Filetostr(m.csrc),1)

Strtofile('',m.csrc)

For Each Line In aa
   if Upper(Alltrim(Getwordnum(m.line,1,'='))) == m.key
      Strtofile(m.nkv+crlf,m.csrc,1)
      keyFound = .t.
   else
      Strtofile(m.line+crlf,m.csrc,1)
   endif   
Endfor

If !m.keyfound
   Strtofile(m.nkv,m.csrc,1)
Endif





