### Prolog ###

## Define Data Source using Local TI variables 
# This process is for TM1 clients such as Architect or PAW
# There are multiple options to select your data source, this example assumes .csv file
# 1. Use the interface to define your variables once the file is selected
# 2. Set Decimal Seperator, Delimiter, Header Records, Quote Character and Thousand Seperator or assign them using Local Variables
# 3. Set Parameters, very useful for certain cases

DataSourceType = 'CHARACTERDELIMITED';

DatasourceASCIIDelimiter = ',';
DatasourceASCIIHeaderRecords = 1;
DatasourceASCIIQuoteCharacter = '''';

DatasourceNameForClient = ' < enter your data directory path where the source file is stored > ';
DatasourceNameForServer = ' < enter your data directory path where the source file is stored > ';
# E.g. = D:/TM1DataSource/Demo-file.csv

sError = '';
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

# Check if Dimension exists
IF (DimensionExists(sDim)= 0);
    sError = 'Dimension doesn't exists';
    ProcessBreak;
ENDIF;

# Create Attributes
# Attributes can also be added in metadata section too
sAttrDesc = 'Description';
AttrInsert( sDim, '', sAttrDesc, sTypeA );

sAttrDescAlias = 'Description(Alias)';
AttrInsert( sDim, sAttrDesc, sAttrDescAlias, sTypeA );

### Metadata ###
leave empty

### Data ###

# Skip Blanks
IF ( vElement @= '' );
    ItemSkip;
ENDIF;

AttrPutS( vElementAttr1, sDim, vElement, sAttrDesc );
AttrPutS( vElementAttr2, sDim, vElement, sAttrDescAlias );

### Epilog ###

# Error Check
IF( sError @<> '');
	ItemReject( sError);
ENDIF;