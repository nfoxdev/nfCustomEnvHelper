*------------------------------------------------------------
* nfCustomEnvHelper 1.4.2 main menu
*------------------------------------------------------------
Parameters projectfolder

Private All

thisprg    = Sys(16)
thisfolder = Justpath(m.thisprg)

commonstart  = Forcepath('commonStart.prg'   ,m.thisfolder)

custconfig   = Sys(2019)
custfolder   = Justpath(m.custconfig)
afterstartup = Forcepath('afterstartup.prg'  ,m.custfolder)
cmdhistory   = Forcepath('_command.prg'      ,m.custfolder)
nfcustomenvhelper = Forcepath('nfCustomenvHelper.prg',m.thisfolder)

Define Pad _devpad Of _Msysmenu Prompt 'Custom Env.'
Define Popup _devpop Relative
Define Bar 50 Of _devpop Prompt '* v.1.4.2 *' Style 'B' invert
Define Bar  1 Of _devpop Prompt ' New Folder shortcut with custom environment'
Define Bar  2 Of _devpop Prompt ' do startup' Key f5,'F5'
Define Bar  3 Of _devpop Prompt '* View/Edit' Style 'B' invert
Define Bar  4 Of _devpop Prompt ' edit config.fpw'
Define Bar  5 Of _devpop Prompt ' edit common startup '
Define Bar  6 Of _devpop Prompt ' edit project startup'
Define Bar  7 Of _devpop Prompt ' view command history'
Define Bar  8 Of _devpop Prompt ' * Project: ' Style 'B' invert
Define Bar  9 Of _devpop Prompt ' Open in File Explorer '       Key f8, 'F8'
Define Bar 10 Of _devpop Prompt ' Open in CMD'    Key ctrl+f8, 'ctrl+F8'
Define Bar 11 Of _devpop Prompt ' Modify project'                Key f9,'F9'
Define Bar 12 Of _devpop Prompt ' List files'                    Key f11,'F11'
Define Bar 13 Of _devpop Prompt ' Toggle desktop/active window'  Key f12,'F12'

On Pad _devpad Of _Msysmenu Activate Popup _devpop
On Selection Bar  1 Of _devpop Do "&nfCustomEnvHelper"
On Selection Bar  2 Of _devpop Do "&thisprg" With "&projectfolder"
On Selection Bar  4 Of _devpop Modify File "&custConfig"
On Selection Bar  5 Of _devpop Editsource("&commonStart")
On Selection Bar  6 Of _devpop Editsource("&afterStartup")
On Selection Bar  7 Of _devpop Modi Command "&cmdHistory" Noedit
On Selection Bar  9 Of _devpop Do explorewd     In "&thisprg"
On Selection Bar 10 Of _devpop Do runcmd        In "&thisprg>>"
On Selection Bar 11 Of _devpop Do openproject   In "&thisprg>>"
On Selection Bar 12 Of _devpop Do showdir       In "&thisprg"
On Selection Bar 13 Of _devpop Do activatescreen   In "&thisprg"

Set Sysmenu Save

*- window state
_Screen.AddProperty('oCustEnv',Createobject('empty'))
AddProperty(_Screen.ocustenv,'lastWontop','')

*- make sure we are in desired folder before & after
Cd (m.projectfolder)

*- screen color
Do setscreencolor

checkstartprgs(m.commonstart,m.afterstartup)
Do "&commonstart"
Do "&afterStartup"

*- make sure we are in desired folder
Cd (m.projectfolder)

Do showdir


*------------------------------------------------
Procedure setscreencolor
*------------------------------------------------
With _Screen

* set project screen color
   Try
      cconfig  = Filetostr(Sys(2019))
      fc = Strextract(m.cconfig,"screenForeColor=","",1,1)
      bc = Strextract(m.cconfig,"screenBackColor=","",1,1)
      .ForeColor   = Evl(Val(m.fc),.ForeColor)
      .BackColor   = Evl(Val(m.bc),.BackColor)
   Catch
   Endtry

   .Caption   = Fullpath('')
   Clear

Endwith


*------------------------------------------------
Procedure checkstartprgs(commonstart,afterstartup)
*------------------------------------------------
Local temp

If !File(m.commonstart)

   TEXT to temp noshow textmerge
*-------------------------------------------------------
* Generated by nfCustEnvHelper.prg
* https://github.com/nfoxdev/customEnvHelper
*-------------------------------------------------------
* place here code to run for all projects
*
*

   do showdir in "&thisprg"
   Strtofile(m.temp,m.commonstart)

   ENDTEXT

Endif


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


*----------------------------
Procedure runcmd
*----------------------------
Local oexp
oexp = Createobject('shell.application')
oexp.shellexecute('cmd')



*----------------------------
Procedure openproject
*----------------------------
Try
   Local defproj
   defproj = Sys(2000,'*.pjx')
   If !Empty(m.defproj)
      Modify Project (m.defproj) Nowait
   Else
      Messagebox( 'No project found in current folder',0)
   Endif
Catch
   Messagebox( 'Project '+Justfname(m.defproj)+' is in use by another ',0)
Endtry

*-------------------------
Procedure explorewd
*-------------------------
Local oexp
oexp = Createobject('shell.application')
oexp.explore(Fullpath(''))


*----------------------------
Procedure showdir()
*----------------------------

activatescreen(.T.)

Clear
@ 2,5 Say Fullpath('') Font 'Ebrima',26
? ' '
? ' '
? 'Search Path: '
? '-'+Strtran(Set('path'),';','   -')
? 'dir *.*:'
Dir *.*


*------------------------------
Function activatescreen(ShowD)
*------------------------------
With _Screen.ocustenv

   If !Empty(Wontop()) Or m.showd
      .lastwontop = Wontop()
      Hide Window All
      Activate Screen
      Sys(1500,'_MWI_CMD','_MWINDOW')
   Else
      Sys(1500,'_MWI_HIDE','_MWINDOW')
      Show Window All
      If !Empty(.lastwontop) And Wexist(.lastwontop)
         Activate Window (.lastwontop)
      Endif
      .lastwontop = ''
   Endif

Endwith

