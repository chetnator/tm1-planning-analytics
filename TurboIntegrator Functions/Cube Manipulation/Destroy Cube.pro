### Prolog ###

sError = '';
sCube = ' < enter cube name > ' ;

# Check if Cube Exists
IF (CubeExists(sCube)= 1);
    CubeDestroy(sCube);
ELSE;
    sError = 'Cube doesn't exist';
    ProcessBreak;
ENDIF;

### Metadata ###
# leave empty

### Data ###
# leave empty

### Epilog ###

# Error Check
IF(sError @<> '');
	ItemReject(sError);
ENDIF;

# Tip - Prolog and Epilog of this process can be combined together either run all in Prolog or Epilog.