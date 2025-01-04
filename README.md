# nfCustomEnvHelper 
[español](#esp)

Start vfp directly on your project folder from a shortcut. 
You'll get a separate command history, recent files history, 
startup environment ( config.fpw and resource ), debug sessions 
and a custom icon in the taskbar. 

 Instructions:
 save this utility on a definitive location, and run it to start the helper:


nfCustomenvHelper clones the current environment files or make new ones in any 
folder you choose and creates a shortcut on your desktop, adding a menu pad with
options to easily edit your config.fp and project startup routine.

Config.fpw and resource.dbf are saved in {{projectfolder}}\\_customenv\\, along with startup.prg*, favicon.ico and a copy of the shortcut.

*startup.prg:
- defines a menu with options to:
  - run this utility ( make sure to save it to a definitive location )
  - edit config.fpw
  - edit startup.prg
  - edit afterStartup.prg
  - run startup.prg

- sets 1 function key:
  - F5: runs startup.prg 

If you have a common config routine you want to run on all your projects,
just run it from  "afterstartup".


*------------------------------------------------------------------------------*

# nfCustomEnvHelper {#esp}
Inicie vfp directamente en la carpeta de su proyecto desde un acceso directo.
Obtendrá un historial de comandos separado, un historial de archivos recientes,
entorno de inicio (config.fpw y recurso), sesiones de depuración
y un icono personalizado en la barra de tareas.

Instrucciones:
guarde esta utilidad en una ubicación definitiva y ejecútela para iniciar el asistente.

nfCustomenvHelper clona los archivos del entorno actual o crea nuevos en \
cualquier carpeta que elijas y crea un acceso directo en su escritorio,\
agregando un panel de menú con opciones para editar fácilmente su config.fp \
y la rutina de inicio del proyecto.

Config.fpw y Resource.dbf se guardan en {{projectfolder}}_customenv, \
junto con startup.prg*, favicon.ico y una copia del acceso directo.

*inicio.prg:
- define un menú con opciones para:
- ejecute esta utilidad (asegúrese de guardarla en una ubicación definitiva)
- editar config.fpw
- editar inicio.prg
- editar después de Startup.prg
- ejecutar startup.prg

- establece 1 tecla de función:
- F5: ejecuta startup.prg

Si tiene una rutina de configuración común que desea ejecutar en todos sus proyectos,
simplemente ejecútela desde  "afterStartup".


-------------------------------------------------- ----------------------------

 
  
   
   
 
 
