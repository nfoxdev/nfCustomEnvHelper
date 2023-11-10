*----------------------------------------------------------------------------
* Creates a custom startup environment for desired project folder
* a shortcut in selected folder.
* Marco Plaza, 2023
* v.1.2.4  https://github.com/nfoxdev/nfCustomEnvHelper
*-----------------------------------------------------------------------------
private all

#define envfolder '_customEnv'
#define wcap 'nfCustomEnvHelper'
#define crlf chr(13)+chr(10)

set safety off
set talk off
set notify off

try

	workdir = getdir('','Select or create a new folder:','nfCustomEnvHelper',16+32+64)

	if !directory(m.workdir)
		error 'No directory selected!'
	endif

*-- check & create vfpenv folder in destfolder

	custfilesdir = m.workdir + envfolder

	if !directory(m.custfilesdir)
		mkdir (m.custfilesdir)
	endif

*-- check for _resource.dbf in dest folder:

	curresource		= sys(2005)
	custresource	= forcepath('resource.dbf',m.custfilesdir)


*-- SELECT CLONE / NEW ENV:

	if atc(m.curresource,m.custresource) > 0
		lreset		= qu('Reset current custom resource?')
		lproceed 	= m.lreset
		lclone 		= .f.
	else
		lproceed  	= !file(m.custresource) or qu('Destination already has a resource file! '+crlf+' overwrite?')
		lclone 	  	= file(m.curresource)  and m.lproceed and qu('Clone current resource? No = creates a new one')
	endif


*-- create resource:

	set resource off

	if m.lproceed
		if m.lclone
			select * from (m.curresource) into table (m.custresource)
			use
			use in (select(juststem(m.curresource)))
			messagebox('Current Resource cloned',0,wcap)
		else
			create table (m.custresource) ( type c(12),id c(12),name m(4),readonly l(1),ckval n(6,0),data m(4),updated d(8))
			use
			messagebox('New Resource created',0,wcap)
		endif
	endif

	set resource on


*-- config.fpw in dest folder:

	custconfig= forcepath('config.fpw',m.custfilesdir)
	curconfig = sys(2019)

	if atc(m.custconfig,m.curconfig) = 0
		if file(m.curconfig)
			copy file (m.curconfig) to (m.custconfig)
		else
			strtofile('',m.custconfig)
		endif
	endif


*-- pick a custom backcolor:

	custbackcolor = 0
	messagebox('Pick a Custom Screeen BackColor...',0,wcap)
	custbackcolor = getcolor(_screen.backcolor)
	custbackcolor = iif(m.custbackcolor>0,m.custbackcolor,rgb(255,255,255))


*-- select icon

	iconcopy	= forcepath('favicon'+sys(2015)+'.ico',m.custfilesdir)
	custicon 	= ''

	try

* check for folder custom icon

		custicon = strextract(filetostr(forcepath('desktop.ini',m.workdir)),'IconResource=',',')

		if !file(m.custicon)
			error 'no icon'
		endif

	catch
		qu('Folder has no custom icon.. Select one for this shortcut',0)

	endtry


	if  !file(m.custicon) or !qu('Use Icon '+m.custicon+'?')

		custicon = getfile('Select an ico, exe or dll file to set icon for this shortcut:ico,exe,dll','Icon.:','Select',0,'Select a custom icon for this shortcut')

		if !file(m.custicon)

			qu('No icon selected.. using vfp icon',0)
			custicon = _vfp.servername

		endif

	endif


*-- create shortcut?

	oshell = createobject('wscript.shell')

	defaultshortcut = forcepath(;
		'VFP9 @ '+proper(chrtran(m.workdir,'\:',' ')),;
		oshell.specialfolders.item('desktop');
		)

	shname = putfile('Save shortcut as: ',m.defaultshortcut,'lnk')

	if empty(m.shname) and qu('Cancel?',4)
		error 'Cancelled'
	endif


	shname = forceext(rtrim(evl(m.shname,m.defaultshortcut)),'lnk')


*-- use a icon copy when icon file selected:

	if m.custicon # m.iconcopy and lower(justext(m.custicon)) == 'ico'
		copy file (m.custicon) to (m.iconcopy)
		custicon = m.iconcopy
		erase (addbs(m.custfilesdir)+'favicon*.ico')
	endif


*-- ...create shortcut

	with m.oshell.createshortcut( m.shname )
		.targetpath			= '"'+_vfp.servername+'"'
		.workingdirectory	= m.workdir
		.arguments			= [-c"]+m.custconfig+["]
		.description		= 'created using nfCustomenvHelper'
		.windowstyle		= 1
		.iconlocation 		= m.custicon
		.save()
	endwith

*-- save also in custom config folder:
	copy file (m.shname) to (forcepath(m.shname,m.custfilesdir))

*-- create afterstartup.prg in customconfig folder as sample
	custstartup 		= forcepath('startup.prg',m.custfilesdir)
	custafterstartup 	= forcepath('afterStartup.prg',m.custfilesdir)
	createstartup(m.workdir,m.custstartup,m.custconfig,m.custbackcolor,custafterstartup)

*-- set resource and call startup.prg in config.fpw
	writekey(m.custconfig,'resource',m.custresource)
	writekey(m.custconfig,'default',m.workdir)
	writekey(m.custconfig,'command',textmerge('do "<<m.custStartup>>"'))


*-- open?:

	if qu('Shortcut saved as '+m.shname+'! open? ',4)
		ir = textmerge([run start "" "<<m.shname>>"])
		&ir
	endif

catch to err when err.errorno = 1098
	messagebox(err.message,0,wcap)

catch to err
	messagebox(textmerge('Oops.. <<CHR(13)>>error number:<<err.errorno>>  at:<<err.lineno>> <<CHR(13)>> <<err.message>>'),48,wcap)

endtry

*--------------------------------------------
function qu(cm,diagtype)
*--------------------------------------------

local ures
diagtype = iif(pcount()=2,m.diagtype,3)
ures = messagebox(m.cm,m.diagtype+iif(m.diagtype=4,0,256),wcap)

if m.ures = 2
	error 'Helper canceled'
else
	return ures = 6
endif

*---------------------------------
function getforecolor(tncolor)
*---------------------------------

local r,g,b,luma
r = bitand(m.tncolor, 0xff)
g = bitand(bitrshift(m.tncolor, 8), 0xff)
b = bitand(bitrshift(m.tncolor, 16), 0xff)


luma = ((0.299 * m.r) + (0.587 * m.g) + (0.114 * m.b)) / 255

return iif(m.luma > 0.7, rgb(0,0,0), rgb(255,255,255))

*---------------------------------
function getkey(m.csrc,key)
*---------------------------------
local value
local nel
local array aa(1)

value = ''
try

	alines(aa,filetostr(m.csrc))
	nel=ascan(aa,m.key)
	if upper( getwordnum(aa(m.nel),1,'=')) == upper(m.key)
		value = getwordnum(aa(m.nel),2,'=')
	endif

catch
endtry

return m.value


*-------------------------------------
function writekey(m.csrc,key,value)
*-------------------------------------

local nkv,addk,line,aa(1)

if vartype(m.key) # 'C' or vartype(m.value) # 'C'
	error 'key value not a character expression'
endif

nkv = m.key+'='+m.value+crlf

alines(aa,filetostr(m.csrc))

addk = .t.

strtofile('',m.csrc)

for each line in aa

	if atc(m.key,getwordnum(m.line,1,'='))>0
		strtofile(m.nkv,m.csrc,1)
		addk = .f.
	else
		strtofile(m.line+crlf,m.csrc,1)
	endif

endfor

if m.addk
	strtofile(m.nkv,m.csrc,1)
endif


*---------------------------------------------------------------------------------------
procedure createstartup(workdir,custstartup,custconfig,custbackcolor,afterstartup)
*---------------------------------------------------------------------------------------

*-- create startup.prg
local temp

text to temp noshow textmerge
*-------------------------------------------------------
* Custom startup generated by nfCustEnvHelper.prg
* https://github.com/nfoxdev/customEnvHelper
*-------------------------------------------------------

define pad _devpad of _msysmenu prompt 'Custom Env.'
define popup _devpop
define bar 1 of _devpop prompt 'edit "<<JUSTFNAME(m.custConfig)>>"'
define bar 2 of _devpop prompt 'edit "<<JUSTFNAME(m.custStartup)>>"'
define bar 3 of _devpop prompt 'edit "<<JUSTFNAME(m.custAfterStartup)>>"'
define bar 4 of _devpop prompt 'F5 do "<<JUSTFNAME(m.custStartup)>>"'
define bar 5 of _devpop prompt 'Create a custom Startup'

on pad _devpad of _msysmenu activate popup _devpop
on selection bar 1 of _devpop editsource("<<m.custConfig>>")
on selection bar 2 of _devpop editsource("<<m.custStartup>>")
on selection bar 3 of _devpop editsource("<<m.custAfterStartup>>")
on selection bar 4 of _devpop do "<<m.custStartup>>"
on selection bar 5 of _devpop do "<<forceext(getwordnum(sys(16),3),'prg')>>"

set status bar on
set memowidth to 100

on key label f5  do "<<m.custStartup>>"

with _screen


  .visible  	= .t.
  .caption   	= fullpath('')
  .forecolor  	= <<getforecolor(m.custbackcolor)>>
  .backcolor   	= <<m.custbackcolor>>

  .fontname  = 'Consolas'
  .fontsize  = 14

  clear
  @ 2,5 say fullpath('') font 'foxfont',26
  ? ' '
  dir *.prg

  projfile = sys(2000,'*.pjx')

  if !empty(m.projfile)
    modify project (m.projfile) nowait
  endif


endwith

set sysmenu save

if file("<<m.afterStartup>>")
  do "<<m.afterStartup>>"
endif

ENDTEXT

*-- save startup.prg:

strtofile(m.temp,m.custstartup)



*-- create afterStartup.prg if not present:

if !file(m.afterstartup)

	text to temp noshow textmerge
*-------------------------------------------------------
* Custom startup generated by nfCustEnvHelper.prg
* https://github.com/nfoxdev/customEnvHelper
*-------------------------------------------------------
* place here code to run after startup for this project
* ie: "do myCommonInitProcedure"
*

	endtext

	strtofile(m.temp,m.afterstartup)

endif
