# OPEN DATA PROTOCOL

OData (Open Data Protocol) is an open standard for querying and manipulating data using RESTful APIs. It defines a uniform way to describe data models and interact with them, making it easier for developers to consume and manipulate data across different systems.

Key Aspects of OData:

Uniform Data Access:
- OData abstracts the complexity of underlying data stores, enabling consistent access regardless of the source.

Metadata Representation:
- The data model (schema) is described using CSDL (Common Schema Definition Language), which defines entities, properties, relationships, and more.

Query Parameters:
- Supports query options like $filter, $select, $expand, $orderby, $top, $skip, and $count for fine-grained data retrieval.

Actions and Functions:
- Allows calling server-defined behaviors for additional flexibility.

# Components of CSDL XML

1. EntityType:
- Defines an entity in the model, similar to a table in a database.

Example:
```xml
<EntityType Name="Cube">
  <Key>
    <PropertyRef Name="Name" />
  </Key>
  <Property Name="Name" Type="Edm.String" Nullable="false" />
</EntityType>
```
Cube is the entity type, and Name is its primary key.

2. ComplexType:
- Represents structured data without a key (like a JSON object).

3. NavigationProperty:
- Describes relationships between entities (e.g., Cube has Dimensions).

4. EntitySet:
- A collection of entities, like a database table.

Example:
```xml
<EntitySet Name="Cubes" EntityType="Cube" />
```

5. Action/Function:
- Represents server-side operations you can invoke.

6. Annotations:
- Provides additional metadata for documentation, validation, or UI hints.

# Metadata query ($metadata)

To get started, use $metadata in your REST API URL to retrieve TM1 server/instance Entity Data Model (EDM). This model approach is common in oData to describe data and its relationships with other entities (schema). 

CSDL is XML-based language used to represent EDM.

To query $metadata, simple enter the REST API URI + $metadata in any avaible browser. Replace the protocol, servername and httpportnumber accordign to your needs.

Syntax:
```
<protocol>://<tm1 server name>:<http port number>/api/v1/$metadata
```

Example:
```
https://saturn-dev:8081/api/v1/$metadata
```

# API Endpoints

Some of the most common TM1 REST API endpoints are:
- Cubes: `/Cubes`, specific cube: `/Cubes('<enter cube name>')` 
- Dimensions `/Dimensions`, specific dimension `/Dimension('<enter dimension name>')`

Sub-endpoints to above ( you may add specific name of each below just as shown above):
- Views: `/Cubes('enter cube name')/Views`
- Cellsets: `/Cellsets('enter cellset ID')/Cells`
- Dimensions: `/Cubes('<enter cube name>')/Dimensions`
- Hierarchies: `/Dimensions('<enter dim name>')/Hierarchies('<enter hierarchy name>')`
- Elements: `/Dimensions('<enter dim name>')/Hierarchies('<enter hierarchy name>')/Elements`
- Subsets: `/Dimensions('<enter dim name>')/Hierarchies('<enter hierarchy name>')/Subsets`

These are the key endpoints to be able to retrieve data from cubes.

# oData Options

There are many useful oData operations that you can execute to assist data queries. These are $select, $expand, $filter, $top, $skip, $orderby and $count

- $select helps you to select a property assigned within that entity.
- $expand helps you to select a navigation property within that entity which in return displays the property of the mapped entity.
- $filter helps you to filter your property assigned within that entity applying a specific condition.
- $top helps you to select the number of results from the top (essentially records).
- $skip helps you to skip the number of results from the top (essentially records).

<!-- to be updated oData Operations and String functions -->

# Documentation

https://www.ibm.com/docs/en/planning-analytics/2.0.0?topic=analytics-tm1-rest-api

# Issues

If you find issues, sign up in GitHub and open an Issue in this repository

# Contribution

I am an independent developer.
If you find a bug or feel like you can contribute please fork the repository, update the code and then create a pull request so we can merge in the changes.