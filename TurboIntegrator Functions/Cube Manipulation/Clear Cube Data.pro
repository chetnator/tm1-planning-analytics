### Prolog ###
 
sError = '';
sCube = ' < enter cube name > ' ;

# Check if Cube Exists
IF (CubeExists(sCube)= 0);
    sError = 'Cube doesn't exist';
    ProcessBreak;
ENDIF;

# Clear all Data before load
# Tip - it is a standard practise to clear existing data in the cube before loading new data to avoid miscalculations

# CAUTION - CubeClearData clear everthing from the cube, ViewZeroOut is reccommended shown in View Manipulation
CubeClearData(sCube);

### Metadata ###
# leave empty

### Data ###
# leave empty

### Epilog ###

# Error Check
IF(sError @<> '');
	ItemReject(sError);
ENDIF;