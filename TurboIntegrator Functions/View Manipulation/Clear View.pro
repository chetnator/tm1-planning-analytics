### Prolog ###

# Views are mainly created to clear data in cubes to avoid duplication

sCube = ' < enter cube name > ' ;

# Fastest way to clear all cube data be cautious though
CubeClearData( sCube );

# If you need to clear a slice of cube data then you need to create a view covering that area to clear out data
sView = ' < enter view name > ' ;
IF (ViewExists( sCube, sView )= 1);
    # Destroy first if the view already exists to rearrange dimension
    ViewDestroy(sCube, sView);
ELSE;
    # set 1 to create a temporary view which will be deleted after the process runs successfully
    ViewCreate(sCube, sView, 0);
ENDIF;

ViewColoumnDimensionSet( sCube, sView, ' < enter your dimension name > ', 1 );
ViewColoumnDimensionSet( sCube, sView, ' < enter your dimension name > ', 2 );

ViewRowDimensionSet( sCube, sView, ' < enter your dimension name > ', 1 );
ViewRowDimensionSet( sCube, sView, ' < enter your dimension name > ', 1 );

ViewTitleDimensionSet( sCube, sView, ' < enter your dimension name > ' );
ViewTitleDimensionSet( sCube, sView, ' < enter your dimension name > ' );
ViewTitleDimensionSet( sCube, sView, ' < enter your dimension name > ' );

ViewZeroOut( sCube, sView );

# Another way of doing this is by creating subsets and assigning these subsets to the dimensions

sSub = 'Dummy TI Subset';
# Create temporary subsets, deleted after process runs successfully
SubsetCreate( ' < enter your dimension name > ', sSub, 1);
SubsetCreate( ' < enter your dimension name > ', sSub, 1);
SubsetCreate( ' < enter your dimension name > ', sSub, 1);

# Add elements to subsets
SubsetElementInsert( ' < enter your dimension name > ', sSub, ' < enter element name here > ', 1);
SubsetElementInsert( ' < enter your dimension name > ', sSub, ' < enter element name here > ', 1);

# Create temporary view, deleted after process runs successfully
ViewCreate(sCube, sView, 1);

# Assign Subsets to dimensions
ViewSubsetAssign(sCube, sView, ' < enter your dimension name > ', sSub);
ViewSubsetAssign(sCube, sView, ' < enter your dimension name > ', sSub);

# Clear cube cells
ViewZeroOut(sCube, sView);

### Metadata ###
# leave empty

### Data ###
# leave empty

### Epilog ###
# leave empty