*----------------------------------------------------------------------------
* Create a custom startup environment for desired project folder
* v 1.2.01
* Marco Plaza  @nFoxdev 2023
*-----------------------------------------------------------------------------
Private All

#Define envfolder '_customEnv'
#Define wcap 'nfCustomEnvHelper'
#Define crlf Chr(13)+Chr(10)

Set Safety Off
Set Talk Off
Set Notify Off

Try

	workdir = Getdir('','Select or create a new folder:','nfCustomEnvHelper',16+32+64)

	If !Directory(m.workdir)
		Error 'No directory selected!'
	Endif

*-- check & create vfpenv folder in destfolder

	custfilesdir = m.workdir + envfolder

	If !Directory(m.custfilesdir)
		Mkdir (m.custfilesdir)
	Endif

*-- check for _resource.dbf in dest folder:

	curresource		= Sys(2005)
	custresource	= Forcepath('resource.dbf',m.custfilesdir)


*-- SELECT CLONE / NEW ENV:

	If Atc(m.curresource,m.custresource) > 0
		lreset		= qu('Reset current custom resource?',.T.)
		lproceed 	= m.lreset
		lclone 		= .F.
	Else
		lproceed  	= !File(m.custresource) Or qu('Destination already has a resource file! '+crlf+' overwrite?')
		lclone 	  	= File(m.curresource)  And m.lproceed And qu('Clone current resource? No = creates a new one')
	Endif


*-- create resource:

	Set Resource Off

	If m.lproceed
		If m.lclone
			Select * From (m.curresource) Into Table (m.custresource)
			Use
			Use In (Select('resource'))
			Messagebox('Current Resource cloned',0,wcap)
		Else
			Create Table (m.custresource) ( Type c(12),Id c(12),Name m(4),ReadOnly l(1),ckval N(6,0),Data m(4),Updated d(8))
			Use
			Messagebox('New Resource created',0,wcap)
		Endif
	Endif

	Set Resource On


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

	custbackcolor = 0

	If qu('Pick a Custom Screeen BackColor?')
		custbackcolor = Getcolor(_Screen.BackColor)
	Endif

	custbackcolor = Iif(m.custbackcolor>0,m.custbackcolor,Rgb(255,255,255))


*-- create startup.prg in customconfig folder
	custstartup 		= Forcepath('startup.prg',m.custfilesdir)
	custafterstartup 	= Forcepath('afterStartup.prg',m.custfilesdir)
	createstartup(m.workdir,m.custstartup,m.custconfig,m.custbackcolor,custafterstartup)

*-- set resource in _config.fpw
	writekey(m.custconfig,'resource',m.custresource)
	writekey(m.custconfig,'default',m.workdir)
	writekey(m.custconfig,'command',Textmerge('do "<<m.custStartup>>"'))


*-- select icon
	Try
* is there a folder custom icon?
		custicon = Strextract(Filetostr(Forcepath('desktop.ini',m.workdir)),'IconResource=',',')
		If !File(m.custicon)
			Error 'file not found'
		Endif
	Catch
		custicon = Forcepath('favicon.ico',m.custfilesdir)
	Endtry


	If  !File(m.custicon) Or !qu('Use Icon '+m.custicon+'?')

		selicon = Getfile('ico','Icon.:','Select',0,'Select a custom icon for this shortcut')

		If File(m.selicon)
			Copy File (m.selicon) To (m.custicon)
		Else
			qu('No icon selected - continue?')
			custicon = _vfp.ServerName
		Endif

	Endif


*-- create shortcut

	oshell = Createobject('wscript.shell')

	defaultshortcut = Forcepath(;
		'VFP9 @ '+Proper(Chrtran(m.workdir,'\:',' ')),;
		oshell.specialfolders.Item('desktop');
		)

	shname = Putfile('Save shortcut as: ',m.defaultshortcut,'lnk')
	shname = Forceext(rtrim(Evl(m.shname,m.defaultshortcut)),'lnk')


	With m.oshell.createshortcut( m.shname )

		.targetpath			= '"'+_vfp.ServerName+'"'
		.workingdirectory	= m.custfilesdir
		.arguments			= [-c"]+m.custconfig+["]
		.Description		= 'created using nfCustomenvHelper'
		.windowstyle		= 1

		If File(m.custicon)
			.iconlocation = m.custicon
		Endif

		.Save()

	Endwith

*-- save also in custom config folder:
	Copy File (m.shname) To (Forcepath(m.shname,m.custfilesdir))


*-- open shortcut?:

	If Messagebox('Shortcut saved as '+m.shname+' open? ',4,wcap) = 6

		ir = textmerge([run start "" "<<m.shname>>"])
		&ir

	Endif

Catch To err When err.ErrorNo = 1098
	Messagebox(err.Message,0,wcap)

Catch To err
	Messagebox(Textmerge('Oops.. <<CHR(13)>>error number:<<err.errorno>>  at:<<err.lineno>> <<CHR(13)>> <<err.message>>'),48,wcap)

Endtry

*--------------------------------------------
Function qu(cm,defno)
*--------------------------------------------
Local ures
ures = Messagebox(m.cm,3+Iif(m.defno,256,0),wcap)
If m.ures = 2
	Error 'Helper canceled'
Else
	Return ures = 6
Endif

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


*---------------------------------------------------------------------------------------
Procedure createstartup(workdir,custstartup,custconfig,custbackcolor,custafterstartup)
*---------------------------------------------------------------------------------------

Local temp

TEXT TO temp TEXTMERGE noshow


*-------------------------------------------------------
* Custom startup generated by nfCustEnvHelper.prg
* https://github.com/nfoxdev/customEnvHelper
*-------------------------------------------------------

Define Pad _devpad Of _Msysmenu Prompt 'Custom Env.'

Define Popup _devpop
Define Bar 1 Of _devpop Prompt 'edit "<<JUSTFNAME(m.custConfig)>>"'
Define Bar 2 Of _devpop Prompt 'edit "<<JUSTFNAME(m.custStartup)>>"'
Define Bar 3 Of _devpop Prompt 'edit "<<JUSTFNAME(m.custAfterStartup)>>"'
Define Bar 4 Of _devpop Prompt 'F5 do "<<JUSTFNAME(m.custStartup)>>"'
Define Bar 5 Of _devpop Prompt 'F9  Modify project'
Define Bar 6 Of _devpop Prompt 'F10 Open <<m.workdir>> in file explorer'
Define Bar 7 Of _devpop Prompt 'Create a custom Startup'

On Pad _devpad Of _Msysmenu Activate Popup _devpop
On Selection Bar 1 Of _devpop Editsource("<<m.custConfig>>")
On Selection Bar 2 Of _devpop Editsource("<<m.custStartup>>")
On Selection Bar 3 Of _devpop Editsource("<<m.custAfterStartup>>")
On Selection Bar 4 Of _devpop Do "<<m.custStartup>>"
On Selection Bar 5 Of _devpop keyboard "{F9}" clear
On Selection Bar 6 Of _devpop keyboard "{F10}" clear
On Selection Bar 7 Of _devpop Do "<<forceext(getwordnum(sys(16),3),'prg')>>"

Set Status Bar On
Set Memowidth To 100

on key label F5  do "<<m.custStartup>>"
on key label F9  modify project (sys(2000,'*.pjx')) nowait
on key label F10 do explorewd 		In "<<m.custStartup>>"
On Key Label F11 Do showdir 		In "<<m.custStartup>>"
On Key Label F12 Do activatescreen 	In "<<m.custStartup>>"

With _Screen

	*- appstate
	.addproperty('oCustEnv',Createobject('empty'))
	addproperty(.oCustenv,'toggle',.T.)
	addproperty(.oCustEnv,'lastWontop','')

	clear

	.Visible	= .T.
	.Caption 	= Fullpath('')
	.ForeColor	= <<getforecolor(m.custBackColor)>>
	.BackColor 	= <<m.custbackcolor>>

	.FontName	= 'Consolas'
	.FontSize	= 16

	? 'Hotkeys:'
	? '  F5: run startup.prg '
	? '  F9: modify project '
	? ' F10: explore <<m.workdir>>'
	? ' F11: show files in current directory'
	? ' F12: Toggle Show desktop + command window '
	? '*'

	.FontName	= 'Consolas'
	.FontSize	= 14
	.FontBold	=.F.

	showdir(.t.)

	projFile = sys(2000,'*.pjx')

	if !empty(m.projFile)
		modify project (m.projFile) nowait
	endif


Endwith

If File("<<m.custAfterStartup>>")
	Do "<<m.custAfterStartup>>"
Endif


*-------------------------
Procedure explorewd
*-------------------------
With Createobject('shell.application')
	.explore("<<m.workdir>>")
Endwith


*----------------------------
Procedure showdir(noclear)
*----------------------------

activatescreen(.T.)

if !m.noclear
	clear
endif

_screen.FontSize = 16
? 'Current Directory: ',fullpath('')
_screen.FontSize = 14
? ''
? 'Search Path: '
? Set('path')
? ''
? 'dir *.*:'
Dir *.*

*------------------------------
Function activatescreen(ShowD)
*------------------------------


With _Screen.oCustEnv

	If .toggle Or m.showd
		.lastwontop = Wontop()
		Activate Screen
		Hide Window All
		Sys(1500,'_MWI_CMD','_MWINDOW')
		.toggle = .F.
	Else
		Sys(1500,'_MWI_HIDE','_MWINDOW')
		Show Window All
		.toggle = .T.
		If !Empty(.lastwontop) And Wexist(.lastwontop)
			Activate Window (.lastwontop)
		Endif
		.lastwontop = ''
	Endif

Endwith


ENDTEXT

*-- save custom startup.prg:
Strtofile(m.temp,m.custstartup)
compile (m.custstartup)

*-- create afterStartup.prg if not present:

If !File(m.custafterstartup)

	TEXT TO temp noshow

*-------------------------------------------------------
* Custom startup generated by nfCustEnvHelper.prg
* https://github.com/nfoxdev/customEnvHelper
*-------------------------------------------------------
* place here code to run after startup for this project
*

	ENDTEXT

	Strtofile(m.temp,m.custafterstartup)

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



