# nfCustomEnvHelper

Having a custom config.fpw and resource files for each project\
is a great convenience to separate  command history, startup \
environment and debug sessions. It also helps to identify each \
open project with their own icon in the taskbar.

nfCustomEnvHelper simply clones your current environment ( or \
make fresh ones ) on any folder you choose and creates the shortcut \
on your desktop.

Config.fpw and resource.dbf are saved in {{projectfolder}}\\_customenv\\,\
along with startup.prg*, favicon.ico and a copy of the shortcut.

*startup.prg:
- defines a menu with options to:
  - run this utility
  - edit config.fpw / startup.prg / afterStartup.prg
  - run startup.prg / afterStartup.prg

- sets 1 function key:
  - F5: runs startup.prg 

Note: 
 version  1.2.6 no longer includes any utility functions that were \
 just for testing purposes. nfCustomenvHelperUtils.prg has those utils \
 revised, and runs from afterstartup.prg.\
  If you create a shortcut over a folder  with existing customconfig,  \
  startup.prg  won't include the call to nfCustomEnvHelperUtils.prg; \
  You can enable it going to Customenv menu ->edit afterstartup.prg,\
  then add:  "do x:\fullpath\nfcustomenvhelperutils.prg" 
 

*------------------------------------------------------------------------------*

nfCustomEnvHelper

Tener un config.fpw personalizado y archivos de recursos para cada \
proyecto es una gran conveniencia para separar el historial de comandos,\
entorno de inicio y sesiones de depuración. También ayuda a identificar\
cada proyecto abierto con su propio icono en la barra de tareas. 

nfCustomEnvHelper simplemente clona su entorno actual (o crea uno nuevo)\
en cualquier carpeta que elija y crea el acceso directo en su escritorio.

Config.fpw y resource.dbf se guardan en {{projectfolder}}\\_customenv\\, \
junto con startup.prg*, favicon.ico y una copia del acceso directo.

*startup.prg:

- define un menú con opciones para:
  - ejecutar esta utilidad
  - editar config.fpw / startup.prg / afterStartup.prg
  - ejecutar startup.prg / afterStartup.prg
  
- establece 1 tecla de función:
  - F5: ejecutar startup.prg

La versión 1.2.6 ya no incluye ninguna función de utilidad que usé \
sólo con fines de prueba. nfCustomenvHelperUtils.prg tiene esas utilidades \
revisadas y amplía las opciones del menú Customenv. \
Si crea un acceso directo sobre una carpeta con una configuración personalizada\
existente, startup.prg no incluirá la llamada a nfCustomEnvHelperUtils.prg; \
Puedes habilitarlo yendo al menú Customenv - edite afterstartup.prg y agregue:\
'do x:fullpath\fcustomenvhelperutils.prg'

-------------------------------------------------- ----------------------------

 
  
   
   
 
 
