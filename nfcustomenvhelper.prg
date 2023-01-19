*----------------------------------------------------------------------------
* Marco Plaza  @nFoxdev 2023
* Create a custom startup environment for desired project folder
* v 1.0
*-----------------------------------------------------------------------------
Local err
Local usrdir
Local custfilesdir
Local curresource
Local custresource
Local lcreate
Local lsame
Local lreset
Local Clone
Local loverwrite
Local custconfig
Local curconfig
Local custbackcolor
Local custstartup
Local custicon
Local selicon
Local oshell
Local shname

#Define envfolder '_customEnv'
#Define crlf Chr(13)+Chr(10)

Set Safety Off
Set Talk Off
Set Notify Off

Try

	usrdir = Getdir('','Create custom config & resource files for VFP project folder','Folder')

	If !Directory(m.usrdir) Or Lastkey() = 27
		Exit
	Endif



*-- check & create vfpenv folder in destfolder

	custfilesdir = m.usrdir + envfolder

	If !Directory(m.custfilesdir)
		Mkdir (m.custfilesdir)
	Endif


*-- check for _resource.dbf in dest folder:

	curresource = Sys(2005)
	custresource = Forcepath('resource.dbf',m.custfilesdir)


*-- SELECT CLONE / NEW ENV:


	lcreate		= !File(m.custresource)
	lsame		= Atc(m.curresource,m.custresource) > 0
	lreset 		= m.lsame And Messagebox('Clear your current custom resource? No=leave as is',4,'nfCustomEnvHelper') = 6
	Clone 		= !m.lsame And File(m.curresource) And Messagebox('Clone current resource? select No to create an empty one',4,'nfCustomEnvHelper') = 6
	loverwrite	= !m.lsame And !m.lcreate And  File(m.custresource) And Messagebox('Destination already has a resource file! '+crlf+' overwrite?',4,'nfCustomEnvHelper') = 6


	Do Case
	Case !m.lcreate And !m.loverwrite And !m.lreset
* nada
	Case m.clone And ( m.lcreate Or m.loverwrite )
		Select * From (m.curresource) Into Table (m.custresource)
		Messagebox('Resource cloned',0)
	Case !m.clone Or m.lreset
		Set Resource Off
		Create Table (m.custresource) ( Type c(12),Id c(12),Name m(4),ReadOnly l(1),ckval N(6,0),Data m(4),Updated d(8))
		Set Resource On
		Messagebox('New Resource created',0)
	Endcase

	Use


*-- _config.fpw in dest folder:

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
	custbackcolor = Getcolor(_Screen.BackColor)

*-- create startup.prg in customconfig folder if no startup in use

	custstartup = Forcepath('startup.prg',m.custfilesdir)

*-- if curstartup # custstartup it will be called from custom startup

	createstartup(m.custstartup,m.custconfig,m.custbackcolor)

*-- set resource in _config.fpw
	writekey(m.custconfig,'resource',m.custresource)
	writekey(m.custconfig,'default',m.usrdir)
	writekey(m.custconfig,'command',Textmerge('do "<<m.custStartup>>"'))


*-- select icon

	custicon = Forcepath('favicon.ico',m.custfilesdir)

	If  !File(m.custicon) Or Messagebox('Use '+m.custicon+'?',4,'nfCustomEnvHelper') # 6

		Try
			selicon = Getfile('ico','Icon.:','Select',0,'Select a custom icon for this shortcut')
			Copy File (m.selicon) To (m.custicon)
		Catch
			custicon = _vfp.ServerName
			Messagebox('No icon selected',0,'nfCustomEnvHelper')
		Endtry

	Endif


*-- create shortcut in desktop

	oshell = Createobject('wscript.shell')

	shname = Forcepath(;
		'VFP9 @ ';
		+Proper(Chrtran(m.usrdir,'\:',' '));
		+'.lnk',;
		oshell.specialfolders.Item('desktop') ;
		)

	With m.oshell.createshortcut( m.shname )

		.targetpath			= '"'+_vfp.ServerName+'"'
		.workingdirectory	= m.custfilesdir
		.arguments			= [-c]+m.custconfig
		.Description		= 'Environment using _resource.dbf + _config.fpw'
		.windowstyle		= 1

		If File(m.custicon)
			.iconlocation = m.custicon
		Endif

		.Save()

	Endwith

*-- copy shortcut to custom config folder:
	Copy File (m.shname) To (Forcepath(m.shname,m.custfilesdir))


*-- open shortcut:

	Messagebox('Shortcut saved as '+m.shname+' ok to open ',0,'nfCustomEnvHelper')

	Strtofile('start "" "'+m.shname+'"','runhelper.bat')

	Run runhelper.bat /N

	Erase runhelper.bat


Catch To err

	Messagebox('OOps!'+Chr(13)+Textmerge('<<err.message>>  at <<err.lineno>>'),48,'nfCustomEnvHelper')


Endtry

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

Local nkv
Local addk
Local Line
Local Array aa(1)

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


*------------------------------------------------------------------------
Procedure createstartup(custstartup,custconfig,custbackcolor)
*------------------------------------------------------------------------
Local curcommand
Local curPrgCall
Local commonStartup
Local DoCmd

*-- check current config.sys command:
#Define cflag ' '+Replicate('&',2) + '#COMMONSTARTUPFLAG'

curcommand = GetKey(Sys(2019),'command')
curPrgCall = Alltrim(Strextr(m.curcommand,'do ','with',1,1+2),1,'"',' ')

If File(m.curPrgCall)

	commonStartup = Strextract(Filetostr(m.curPrgCall),'DO ',cflag,1,1+4)
	DoCmd = Evl(m.commonStartup,m.curcommand)

Else

	DoCmd = m.curcommand

Endif


*-- Create custom startup: *-------------------------


TEXT TO temp TEXTMERGE noshow

*----------------------------------------------------
* Custom startup generated by nfCustomEnvHelper.prg
* Marco Plaza, @nfoxDev, 2023
*----------------------------------------------------

<<m.doCMD>>

Define Pad _devpad Of _Msysmenu Prompt 'Custom Env.'

Define Popup _devpop
Define Bar 1 Of _devpop Prompt "edit <<JUSTFNAME(m.custStartup)>>"
Define Bar 2 Of _devpop Prompt "edit <<JUSTFNAME(m.custConfig)>>"
Define Bar 3 Of _devpop Prompt "do <<JUSTFNAME(m.custStartup)>>"

On Pad _devpad Of _Msysmenu Activate Popup _devpop
On Selection Bar 1 Of _devpop Editsource("<<m.custStartup>>")
On Selection Bar 2 Of _devpop EDITSOURCE("<<m.custConfig>>")
On Selection Bar 3 Of _devpop Do "<<m.custStartup>>"

set status bar on

_SCREEN.AddProperty('TOGGLE',.t.)
_SCREEN.AddProperty('lastWontop','')

activatescreen(.t.)

With _Screen

	CLEAR

	.Caption 	= 'VFP9: @' + FULLPATH('')
	.ForeColor	= Rgb(255,255,255)
	.BackColor 	= <<m.custBackcolor>>


	.FontName	= 'Consolas'
	.FontSize	= 20
	.Visible	= .T.
	.fontbold	=.f.

	? '>.',_screen.caption
	? '>.',DATETIME()
	? '>. search path = ',SET('path')
	? '>. F10: adds a new path'
	? '>. F11: show prgs in current directory'
	? '>. F12: Toggle Show desktop + command window '
	? '>'
	? ''

	.fontSize=12
	.fontbold = .f.
	DIR *.prg

Endwith


ON KEY LABEL F10 set path to (GETDIR('','CurrentPath: '+SET('path'),'Add Path',1+2+8+64)) additive
ON KEY LABEL f11 do showdir in <<m.custStartup>>
ON KEY LABEL F12 do activatescreen in <<m.custStartup>>

*----------------------------
PROCEDURE showdir
*----------------------------
activatescreen(.t.)
CLEAR
DIR *.prg
? 'Path:' +SET('path')

*------------------------------
FUNCTION activatescreen(showd)
*------------------------------

If _Screen.toggle Or m.showd
	_Screen.lastwontop = Wontop()
	Activate Screen
	Hide Window All
	Sys(1500,'_MWI_CMD','_MWINDOW')
	_Screen.toggle = .F.
Else
	Sys(1500,'_MWI_HIDE','_MWINDOW')
	Show Window All
	_Screen.toggle = .T.
	If !EMPTY(_screen.lastWOntop) AND Wexist(_Screen.lastwontop)
		Activate Window (_Screen.lastWontop)
	Endif
	_Screen.lastwontop = ''
Endif

ENDTEXT

*-- save custom startup.prg:
Strtofile(m.temp,m.custstartup)

*--------------------------------------------------------------
