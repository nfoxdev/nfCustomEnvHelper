# nfCustomEnvHelper

A helper procedure to create custom vfp startup \
environments with ease on any selected folder.

Just run and select one of your project folders;\
nfCustEnvHelper will ask if you want to clone your actual environment or \
create fresh versions for a new environment.

Youll find the following files under the folder "_customenv": 

- config.fwp ( option clone in use / make new )
- resource.dbf ( option clone in use / make new )
- startup.prg *
- favicon.ico ( select at runtime )
- desktop shortcut ( created at desktop and _customenv folder )

 During the clone / create process you'll be asked for a custom icon\
 to be used for the windows shortcut; selecting none / escape defaults\
 to vfp icon.
 
 You'll be asked for to pick a color for your new _screen.backcolor.


 *nfCustEnvHelper creates a startup.prg with some basic helpers\
 (  useful function keys you'll see listed at startup and a custom \
menu to easily edit your config and startup routine )\
If your actual config.fp calls a program using "command = " it will\
be automatically called from startup.prg to keep it running before the\
custom startup with a special flag to identify it as a common startup.
  
nfCustEnvHelper does not change your actual vfp config; it's safe to delete\
_customenv folder and desktop shortcut, just remember that\
.\\_customenv\\_command.prg holds the command history for that environment.




 
 
  
   
   
 
 
