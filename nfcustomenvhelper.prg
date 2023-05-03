*----------------------------------------------------------------------------
* Create a custom startup environment for desired project folder
* v 1.1.0
* Marco Plaza  @nFoxdev 2023
*-----------------------------------------------------------------------------
Private all 

#Define envfolder '_customEnv'
#Define wcap 'nfCustomEnvHelper'
#Define crlf Chr(13)+Chr(10)

Set Safety Off
Set Talk Off
Set Notify Off

Try

	workdir = Getdir('','Create custom config & resource files for VFP project folder','Folder')

	If !Directory(m.workdir)
		Error 'No directory selected!'
	Endif

*-- check & create vfpenv folder in destfolder

	custfilesdir = m.workdir + envfolder

	If !Directory(m.custfilesdir)
		Mkdir (m.custfilesdir)
	Endif


*-- check for _resource.dbf in dest folder:

	curresource = Sys(2005)
	custresource = Forcepath('resource.dbf',m.custfilesdir)


*-- SELECT CLONE / NEW ENV:

	If Atc(m.curresource,m.custresource) > 0
		lreset 	= qu('Reset current custom resource?',.t.)
		lproceed = m.lreset
		lclone = .f.
	Else
		lclone 	  = File(m.curresource)  And qu('Clone current resource? No = creates a new one')
		lproceed  = !File(m.custresource) Or qu('Destination already has a resource file! '+crlf+' overwrite?')
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
	custbackcolor = Getcolor(_Screen.BackColor)

*-- create startup.prg in customconfig folder

	custstartup = Forcepath('startup.prg',m.custfilesdir)
	custafterstartup = Forcepath('afterStartup.prg',m.custfilesdir)
	createstartup(m.workdir,m.custstartup,m.custconfig,m.custbackcolor,custafterstartup)

*-- set resource in _config.fpw
	writekey(m.custconfig,'resource',m.custresource)
	writekey(m.custconfig,'default',m.workdir)
	writekey(m.custconfig,'command',Textmerge('do "<<m.custStartup>>"'))


*-- select icon

	custicon = Forcepath('favicon.ico',m.custfilesdir)

	If  !File(m.custicon) Or !qu('Use '+m.custicon+'?')

		selicon = Getfile('ico','Icon.:','Select',0,'Select a custom icon for this shortcut')

		If File(m.selicon)
			Copy File (m.selicon) To (m.custicon)
		Else
			custicon = _vfp.ServerName
			qu('No icon selected - continue?')
		Endif

	Endif


*-- create shortcut in desktop

	oshell = Createobject('wscript.shell')

	shname = Forcepath(;
		'VFP9 @ ';
		+Proper(Chrtran(m.workdir,'\:',' '));
		+'.lnk',;
		oshell.specialfolders.Item('desktop') ;
		)

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

		Strtofile('start "" "'+m.shname+'"','runhelper.bat')

		Run runhelper.bat /N

		Erase runhelper.bat

	Endif

Catch To err When err.ErrorNo = 1098
	Messagebox(err.Message,0,wcap)

Catch To err
	Messagebox(Textmerge('Oops.. <<CHR(13)>>error number:<<err.errorno>>  at:<<err.lineno>> <<CHR(13)>> <<err.message>>'),48,wcap)

Endtry

*--------------------------------------------------------------
Function qu(cm,defno)
*--------------------------------------------
Local ures
ures = Messagebox(m.cm,3+iif(m.defno,256,0),wcap)
If m.ures = 2
	Error 'Assistant canceled'
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
Define Bar 4 Of _devpop Prompt 'do "<<JUSTFNAME(m.custStartup)>>"'
Define Bar 5 Of _devpop Prompt 'Open file explorer'
Define Bar 6 Of _devpop Prompt 'create a custom Startup'

On Pad _devpad Of _Msysmenu Activate Popup _devpop
On Selection Bar 1 Of _devpop Editsource("<<m.custConfig>>")
On Selection Bar 2 Of _devpop Editsource("<<m.custStartup>>")
On Selection Bar 3 Of _devpop Editsource("<<m.custAfterStartup>>")
On Selection Bar 4 Of _devpop Do "<<m.custStartup>>"
On Selection Bar 5 Of _devpop Do explorewd In "<<m.custStartup>>"
On Selection Bar 6 Of _devpop Do "<<forceext(getwordnum(sys(16),3),'prg')>>"

Set Status Bar On
Set Memowidth To 100

On Key Label f11 Do showdir In "<<m.custStartup>>"
On Key Label f12 Do activatescreen In "<<m.custStartup>>"

With _Screen

	*- appstate
	.addproperty('oCustEnv',Createobject('empty'))
	addproperty(.oCustenv,'toggle',.T.)
	addproperty(.oCustEnv,'lastWontop','')


	Clear

	.Caption 	= 'VFP9: @' + Fullpath('')
	.ForeColor	= Rgb(255,255,255)
	.BackColor 	= <<m.custbackcolor>>

	.FontName	= 'Consolas'
	.FontSize	= 16
	.Visible	= .T.
	.FontBold	=.F.

	? '.',_Screen.Caption
	? '.',Datetime()
	? '. F11: show prgs in current directory'
	? '. F12: Toggle Show desktop + command window '
	? ''
	? ''

	.FontSize = 12

	? 'Path:',Set("path")

	Dir *.prg

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
Procedure showdir
*----------------------------
activatescreen(.T.)
Clear
Dir *.prg
? 'Path:' +Set('path')

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
