### Prolog ###

# Views are mainly created to clear data in cubes to avoid duplication

sError = '';
sCube = ' < enter cube name > ' ;
sView = ' < enter view name > ' ;


IF (ViewExists( sCube, sView )= 0);
    sError = 'View doesn't exist';
    ProcessBreak;
ELSE;
    ViewDestroy(sCube, sView);
ENDIF;

### Metadata ###
# leave empty

### Data ###
# leave empty

### Epilog ###

# Error Check
IF( sError @<> '');
	ItemReject( sError);
ENDIF;

# Tip - Prolog and Epilog of this process can be combined together either run all in Prolog or Epilog.