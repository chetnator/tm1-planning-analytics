### Prolog ###

# Views are mainly created to clear data in cubes to avoid duplication

sError = '';
sCube = ' < enter cube name > ' ;
sView = ' < enter view name > ' ;

# Check if view exists
IF (ViewExists( sCube, sView )= 1);
    sError = 'View already exists';
    ProcessBreak;
ELSE;
    # set 1 to create a temporary view which will be deleted after the process runs successfully
    ViewCreate(sCube, sView, 0);
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