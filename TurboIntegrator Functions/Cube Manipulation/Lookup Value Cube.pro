### Prolog ###

## Define Data Source using Local TI variables
# This process is for TM1 clients such as Architect or PAW
# There are multiple options to select your data source, this example assumes .csv file
# 1. Use the interface to define your variables once the file is selected
# 2. Set Decimal Seperator, Delimiter, Header Records, Quote Character and Thousand Seperator or assign them using Local Variables
# 3. Set Parameters, very useful for certain cases, in this process there are none

DataSourceType = 'CHARACTERDELIMITED';

DatasourceASCIIDelimiter = ',';
DatasourceASCIIHeaderRecords = 1;
DatasourceASCIIQuoteCharacter = '''';

DatasourceNameForClient = ' < enter your data directory path where the source file is stored > ';
DatasourceNameForServer = ' < enter your data directory path where the source file is stored > ';
# E.g. = D:/TM1DataSource/Demo-file.csv

# Check if Cube Exists
sCube = ' < enter cube name > ' ;
sLookupCube = ' < enter lookup cube name > ' ;

IF (CubeExists(sCube)= 0);
    sError = 'Cube doesn't exist';
    ProcessBreak;
ENDIF;

# Clear all Data before load
# Tip - it is a standard practise to clear existing data in the cube before loading new data to avoid miscalculations
# However, this process skips this part assuming it is a brand new cube with no existing data

### Metadata ###
# leave empty

### Data ###

# Assuming we have 4 variables assigned in the source file, each variable correspondes to Dim values
# remember the variables shold be in line with dimension order of the cube

# Lookup Numeric Value from different cube
sVarValue = CellGetN(sLookupCube, ' < element 1 > ', ' < element 2 >'...);

# Lookup Numeric Value from different cube
sVarValue = CellGetS(sLookupCube, ' < element 1 > ', ' < element 2 >'...);

# To replace the existing Numeric value in the cell use this
CellPutN(sVarValue, vVar2, vVar3, vVar4, ' < enter your measure element here > ');

# To replace the existing String value in the cell use this
CellPutS(sVarValue, vVar2, vVar3, vVar4, ' < enter your measure element here > ');

# To add the existing Numeric value in the cell use this
CellIncreamentN(sVarValue, vVar2, vVar3, vVar4, ' < enter your measure element here > ');

### Epilog ###

# Error Check
IF(sError @<> '');
	ItemReject(sError);
ENDIF;