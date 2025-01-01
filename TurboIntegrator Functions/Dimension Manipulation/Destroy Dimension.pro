### Prolog ###

sError = '';
sDim = ' < enter dimension name > ' ;

# Check if Dimension exists
IF (DimensionExists(sDim)= 0);
    sError = 'Dimension doesn't exist';
    ProcessBreak;
ELSE;
    DimensionDestroy(sDim);
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