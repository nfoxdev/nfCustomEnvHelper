*-------------------------------------------------------
* adds some sample functions to nfcustomenvhelper menu
* when called from afterstartup
*-------------------------------------------------------

local thisprg,thisfolder

thisprg = sys(16)
thisfolder = fullpath('')

define bar  7 of _devpop prompt '\-'
define bar  8 of _devpop prompt 'Open File Explorer '           key f8, 'F8'
define bar  9 of _devpop prompt 'Open CMD in current folder'    key ctrl+f8, 'ctrl+F8'
define bar 10 of _devpop prompt 'Modify project'                key f9,'F9'
define bar 11 of _devpop prompt 'Show files'                    key f11,'F11'
define bar 12 of _devpop prompt 'Toggle desktop/active window'  key f12,'F12'

on selection bar  8 of _devpop do explorewd  in "&thisprg"
on selection bar  9 of _devpop run cmd
on selection bar 10 of _devpop do openproject in "&thisprg"
on selection bar 11 of _devpop do showdir in "&thisprg"
on selection bar 12 of _devpop do activatescreen   in "&thisprg"

*- window state

_screen.addproperty('oCustEnv',createobject('empty'))
addproperty(_screen.ocustenv,'toggle',.t.)
addproperty(_screen.ocustenv,'lastWontop','')


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
? 'dir *.*:'
dir *.*

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

