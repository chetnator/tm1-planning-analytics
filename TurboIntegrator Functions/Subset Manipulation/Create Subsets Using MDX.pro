### Prolog ###

# Subsets are mainly created to facilitate end user requirements, setting default dimension element selection, zero-ing out views, picklist, etc.

sError = '';
sDim = ' < enter dimension name > ' ;
# Subsets cannot have specific or reserved TM1 characters e.g. '/'
sSub = ' < enter subset name > ' ;

# Check if subset exists
IF (SubsetExists( sDim, sSub ) =1) ;
  SubsetDestroy( sDim, sSub) ;
ENDIF;

# Create a subset that includes all Level 0 members in the dimension as an example
SubsetCreatebyMDX( sSub, '['|sDim|'].['|sDim|'].levels(0).MEMBERS', 0 );

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