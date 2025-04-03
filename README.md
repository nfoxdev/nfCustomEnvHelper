# nfCustomEnvHelper 
[español](#esp)

Start vfp directly on any  project folder from a shortcut, and get separate command history, config.fpw, resource file and a custom icon in the taskbar! 

Just save this utility on a definitive location, and run it to start the helper.

nfCustomenvHelper does not affect your VFP installation; it clones the current environment files ( or make new ones if you want ).

Copies of Config.fpw and resource.dbf are saved in {{projectfolder}}\\_customenv\\,  with startup.prg*, favicon.ico.

*The shortcut runs vfp and calls startup.prg, wich defines a menu with options to:
  - edit afterStartup.prg ( add here any code you want to run )
  - run startup.prg ( F5 ) ( restarts environment )
  - edit config.fpw
  - open File Explorer ( F8 )
  - open Command Prompt ( Ctrl+F8 )
  - Modify Project ( F9 )
  - List Files ( F11 )
  - Toggle desktop/active window ( F12 )

note:
 Run this utility as many times as you need for a given folder to recreate/fix the shortcut or update to a newer version


If you have a common config routine you want to run on all your projects,
just include it in "afterstartup".


*------------------------------------------------------------------------------*

# nfCustomEnvHelper {#esp}
Inicie VFP directamente en cualquier carpeta de proyecto desde un acceso directo y obtenga un historial de comandos, un archivo config.fpw, un archivo de recursos y un icono personalizado en la barra de tareas.

Simplemente guarde esta utilidad en una ubicación definitiva y ejecútela para iniciar el asistente.

nfCustomenvHelper no afecta a su instalación de VFP; clona los archivos de entorno actuales (o crea nuevos si lo desea).

Las copias de Config.fpw y resource.dbf se guardan en {{projectfolder}}\\_customenv\\, con startup.prg* y favicon.ico.

*El acceso directo ejecuta vfp y llama a startup.prg, que define un menú con opciones para:
- Editar afterStartup.prg (añadir aquí el código que se desee ejecutar)
- Ejecutar startup.prg (F5) (reinicia el entorno)
- Editar config.fpw
- Abrir el Explorador de archivos (F8)
- Abrir el Símbolo del sistema (Ctrl+F8)
- Modificar proyecto (F9)
- Listar archivos (F11)
- Alternar entre escritorio y ventana activa (F12)

Si tiene una rutina de configuración común que desea ejecutar en todos sus proyectos, simplemente inclúyala en "afterstartup".

nota:
 Ejecute esta utilidad tantas veces como necesite para una carpeta para recrear/reparar el acceso directo o actualizar a una nueva versión

-------------------------------------------------- ----------------------------

 
  
   
   
 
 
