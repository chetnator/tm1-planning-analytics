### Prolog ###

# Assuming you want to add 5 dimensions that already exist to create a cube

sError = '';
sCube = ' < enter cube name > ' ;

# Tip - measure dimension is practised to be the last dimension of the cube in order
sDim = ' < enter dimension name > ';
sDim2 = ' < enter dimension name > ';
sDim3 = ' < enter dimension name > ';
sDim4 = ' < enter dimension name > ';
sDim5 = ' < enter measure dimension name > ';

# Check if Cube Exists
IF (CubeExists(sCube)= 1);
    sError = 'Cube already exists';
ELSE;
    # The order of the dimension is very important
    CubeCreate(sCube, sDim, sDim2, sDim3, sDim4, sDim5);
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