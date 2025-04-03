*-------------------------------------------------------
* adds some useful functions to nfcustomenvhelper menu
* this script is common for all projects / edit as you like
*-------------------------------------------------------

with _screen

  .fontname  = 'Consolas'
  .fontsize  = 12

  clear
  @ 2,5 say fullpath('') font 'foxfont',26
  ? ' '
  ? 'Search Path: '
  ? '-'+strtran(set('path'),';','   -')
  ? 'dir *.*:'
  dir *.*

endwith


local thisprg,thisfolder

thisprg = forceext(sys(16),'prg')
thisfolder = fullpath('')

define bar  8  of _devpop prompt ' * Project: ' style 'B' invert 
define bar  9  of _devpop prompt ' Open in File Explorer '       key f8, 'F8'
define bar 10 of _devpop prompt ' Open in CMD'    key ctrl+f8, 'ctrl+F8'
define bar 11 of _devpop prompt ' Modify project'                key f9,'F9'
define bar 12 of _devpop prompt ' List files'                    key f11,'F11'
define bar 13 of _devpop prompt ' Toggle desktop/active window'  key f12,'F12'

on selection bar  9 of _devpop do explorewd  in "&thisprg"
on selection bar 10 of _devpop do runcmd in "&thisprg"
on selection bar 11 of _devpop do openproject in "&thisprg"
on selection bar 12 of _devpop do showdir in "&thisprg"
on selection bar 13 of _devpop do activatescreen   in "&thisprg"

*- window state

_screen.addproperty('oCustEnv',createobject('empty'))
addproperty(_screen.ocustenv,'toggle',.t.)
addproperty(_screen.ocustenv,'lastWontop','')

*----------------------------
procedure runcmd
*----------------------------
local oexp
oexp = createobject('shell.application')
oexp.ShellExecute('cmd')



*----------------------------
procedure openproject
*----------------------------
try
  local defproj
  defproj = sys(2000,'*.pjx')
  if !empty(m.defproj)
    modify project (m.defproj) nowait
  else
    messagebox( 'No project found in current folder',0)
  endif
catch
  messagebox( 'Project '+justfname(m.defproj)+' is in use by another ',0)
endtry

*-------------------------
procedure explorewd
*-------------------------
local oexp
oexp = createobject('shell.application')
oexp.explore(fullpath(''))


*----------------------------
procedure showdir(noclear)
*----------------------------

activatescreen(.t.)

if !m.noclear
  clear
endif

? 'Current Directory: ',fullpath('')
? ''
? 'Search Path: '
? '-'+strtran(set('path'),';','   -')
? ''
? 'dir *.pjx:'
dir *.pjx

? 'dir *.prg:'
dir *.prg

*------------------------------
function activatescreen(showd)
*------------------------------
with _screen.ocustenv

  if .toggle or m.showd
    .lastwontop = wontop()
    activate screen
    hide window all
    sys(1500,'_MWI_CMD','_MWINDOW')
    .toggle = .f.
  else
    sys(1500,'_MWI_HIDE','_MWINDOW')
    show window all
    .toggle = .t.
    if !empty(.lastwontop) and wexist(.lastwontop)
      activate window (.lastwontop)
    endif
    .lastwontop = ''
  endif

endwith

