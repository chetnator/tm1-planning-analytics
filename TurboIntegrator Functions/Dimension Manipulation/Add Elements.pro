### Prolog ###

## Define Data Source using Local TI variables 
# This process is for TM1 clients such as Architect or PAW
# There are multiple options to select your data source, this example assumes .csv file
# 1. Use the interface to define your variables once the file is selected
# 2. Set Decimal Seperator, Delimiter, Header Records, Quote Character and Thousand Seperator or assign them using Local Variables
# 3. Set Parameters, very useful for certain cases, in this process you may include a parameter for dimension mode selection for the user.
# Example, either rebuild the whole dimension or just update the dimension by adding new elements

DataSourceType = 'CHARACTERDELIMITED';

DatasourceASCIIDelimiter = ',';
DatasourceASCIIHeaderRecords = 1;
DatasourceASCIIQuoteCharacter = '''';

DatasourceNameForClient = ' < enter your data directory path where the source file is stored > ';
DatasourceNameForServer = ' < enter your data directory path where the source file is stored > ';
# E.g. = D:/TM1DataSource/Demo-file.csv

sError = '';
nFirstMetaDataRecord = 1;
nUpdate = 0;
nRebuild = 0;
sInsertionPoint = '';
nWeight = 1;
sTypeS = 'S';
sTypeC = 'C';
sTypeN = 'N';

sDim = ' < enter dimension name > ' ;
sConsol = 'Total';

sCompSortType = 'ByName';
sCompSortOrder = 'Ascending';
sElSortType = 'ByHierarchy';
sElSortOrder = 'Ascending';

# Set sort Order
DimensionSortOrder(sDim, sCompSortType, sCompSortOrder, sElSortType, sElSortOrder );

# Check if the user wants to rebuild the whole dimension or only add new elements
IF ( pDim = 0 );
    nUpdate = 1;
ELSE;
    nRebuild = 1;
ENDIF;

# Check if Dimension exists
IF (DimensionExists(sDim)= 0);
    sError = 'Dimension doesn't exists';
    ProcessBreak;
ENDIF;

nDimSiz = DIMSIZ(sDim);

### Metadata ###

# Skip Blanks
IF ( vElement @= '' );
    ItemSkip;
ENDIF;

# On First Record
# Remove Existing Consolidations

IF (nFirstMetaDataRecord = 1);

    IF(nRebuild = 1);
      DimensionDeleteAllElements( sDim );
      DimensionElementInsert( sDim, sInsertionPoint, sConsol, sTypeC );

    ELSEIF(nUpdate = 1);
      i = nDimSiz;
          WHILE( i > 0);
              sLoopEl = ElementName( sDim, sDim, i);
              IF( ElementLevel( sDim, sDim, sLoopEl) > 0 );
                  IF( sLoopEl @<> sConsol );
                      DimensionElementDelete( sDim, sLoopEl);
                  ENDIF;
              ELSE; 
                  IF( ElementType( sDim, sDim, sLoopEl) @= 'C' );
                      IF( sLoopEl @<> sConsol );
                          DimensionElementDelete( sDim, sLoopEl);
                      ENDIF;
                  ENDIF;
              ENDIF;
              i = i -1;
          END;    
  ENDIF;
  nFirstMetaDataRecord = 0;
ENDIF;

# Single Hierarchy use this
# DimensionElementInsert( sDim, sInsertionPoint, vElement, sTypeN );

# Multiple Hierarchies use this (tip - best practise is this method)
IF ( DimensionElementExists( sDim, vElement) = 0 );
    DimensionElementComponentAdd( sDim, sConsol, vElement , nWeight );
ELSEIF;
    DimensionElementInsert( sDim, sInsertionPoint, , sTypeN );
    DimensionElementComponentAdd( sDim, sConsol, vElement , nWeight );
ENDIF;

### Data ###
# leave empty

### Epilog ###

# Error Check
IF( sError @<> '');
	ItemReject( sError);
ENDIF;