# TM1 Power BI Integration using TM1 REST API

**This section covers the basics of the TM1 REST API to help you get started. For a detailed overview of OData query options and operations, refer to [*ODATARESTAPI.md*](/ODATA-RESTAPI.md)**

If you're already familiar with OData standards, you can skip the above file.

## Getting Started

### Prerequisities

#### TM1 side
Ensure that the TM1 REST API is enabled by setting the `HTTPPortNumber` parameter in the **tm1s.cfg** file. E.g. `HTTPPortNumber=5555`

Additionally, configure the `UseSSL` parameter to either T (true) or F (false) to specify the protocol (HTTP or HTTPS). E.g. `UseSSL=T`

Validate your TM1 REST API by simply putting a `GET` request in any browser such as Edge or Google. 

Use this URL format:
```
<protocol>://<serverName>:<httpPortNumber>/api/v1/
```

Example:
```
https://saturn-06.ac.uk:8081/api/v1/
```

If you receive a response, the TM1 REST API is successfully accessible.

You can use **Postman** an API platform to test different TM1 REST API endpoints available for the model.

#### Power BI side

1. Install Python (3.7 or higher) on your local machine.
2. Power BI's Python integration requires two Python libraries to be downloaded: pandas and matplotlib. Download them using the following commands in Terminal or PowerShell:
    1. pip install pandas
    2. pip install matplotlib
3. Enable Python scripting in Power BI by navigating to **File > Options and Settings > Options > Python scripting**, then click **OK**.

You can use a Python IDE like VSCode to run your scripts in Power BI Desktop or use the Python Script connector in the Get Data section.

## Authentication

TM1 supports five different authentication methods/modes. The authentication mode is set in the tm1s.cfg file. E.g. `IntegratedSecurityMode=5`

1. Mode 1:
Standard Planning Analytics security. The server validates usernames and passwords against its internal database.

2. Mode 2:
Allows switching between integrated login and native Planning Analytics security.

3. Mode 3:
Uses Integrated Login with Microsoft Windows network authentication. Requires the SecurityPackageName parameter.

4. Mode 4:
Uses IBM Cognos Analytics security.
- Cognos users belong only to Cognos Analytics groups or predefined Planning Analytics administrator groups (ADMIN, DataAdmin, etc.).
Group assignments made in Planning Analytics are overridden by Cognos Analytics when users log in.

5. Mode 5:
Supports both Planning Analytics and Cognos Analytics groups. Essential for Planning Analytics Workspace on Cloud and TM1 Applications with Cognos Analytics.
- Cognos users can belong to both Cognos and Planning Analytics groups.
Native Planning Analytics groups cannot be used to assign rights in this mode; only Cognos groups are available.

Below, the Python script will be provided to authenticate using **mode 5**.

## API Calls

### API Requests

An API request is how a client communicates with an API to perform specific actions. For a REST API, it typically includes:

1. Endpoint: A URL targeting a specific resource (e.g., /Cubes for TM1 cube-related operations).
2. Method: Specifies the action, such as GET, POST, PUT, PATCH, or DELETE (e.g., GET /Dimensions retrieves all dimensions from the TM1 model).
3. Parameters: Variables sent in the URL, query string, or request body to provide additional instructions (e.g., a name parameter to filter dimensions by name).
4. Headers: Key-value pairs offering extra details like Content-Type (data format) or Authorisation (API key or token).
5. Body: The data required for creating, updating, or deleting resources, formatted as specified by the API (e.g., JSON).

Each component works together to ensure the API server processes the request correctly.

### API Responses
An API response is the server's reply to a client's request, typically including:

1. Status Code: HTTP status codes indicating the request's outcome (e.g., 200 OK for success, 201 Created for a new resource, or 404 Not Found for a missing resource).
2. Headers: Additional information about the response, such as Cache-Control for caching instructions or Set-Cookie for session management.
3. Body: The main content, often structured data (e.g., JSON), representing the requested resource, metadata, or error messages in case of failure.
These components help the client understand and process the server's response.

## TM1 - Power BI connection

To simplify the demonstration of connecting TM1 to Power BI, the following assumptions are made:
1. The TM1 model is configured with security mode 5, requiring the ClientServerURI parameter to be set in the tm1s.cfg file.
2. The query extracts cell values from a cube view.
3. Sensitive information, such as credentials, is securely stored in Azure Key Vault, with two variables: TM1User and TM1Pass (assuming your environment is set up in Azure by your IT team).
4. The required cube and view exist

### Approach

We will approach this in 3 simple steps.

1. Retrieving TM1 username and TM1 password from Azure key vaults to authenticate on Cognos BI server
2. Retreiving CAM Passport by sending a request to Cognos BI server 
3. Query TM1 model


### Coding

Please replace the variable mentioned in `< enter value >`  
```python
# ===================================================================================
# Connect TM1 to Power BI via TM1 REST API
# Python script
# ===================================================================================

import requests
from requests_kerberos import HTTPKerberosAuth, REQUIRED

import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

import json
import pandas as pd

## Azure Key Vaults
# =================================================================================
# Set environment variables directly in the script
os.environ["AZURE_CLIENT_ID"] = " <enter value> "
os.environ["AZURE_CLIENT_SECRET"] = " <enter value> "
os.environ["AZURE_TENANT_ID"] = " <enter value> "
os.environ["VAULT_URL"] = " <enter value> "

# Create a DefaultAzureCredential instance
credential = DefaultAzureCredential()
 
# Create a SecretClient instance
client = SecretClient(vault_url=os.environ["VAULT_URL"], credential=credential)
 
# Retrieve the secrets
username_secret = client.get_secret("TM1User")
password_secret = client.get_secret("TM1Pass")
 
# Send GET Reguest to Cognos BI Server to receive CAM Passport via kerberos auth
# ========================================================================================
Username = username_secret.value
Password = password_secret.value

Domain = " <enter value> " 
# e.g "ADS"

CognosURL = " <enter value> "
# e.g "https://saturn-03.ads.ide.ac.uk:883/ibmcognos/bi/v1/disp"

# Send GET request if Keberos Auth is used
kerberos_auth = HTTPKerberosAuth(principal=f'{Username}@{Domain}', password=Password, mutual_authentication=REQUIRED)
CAMresponse = requests.get(CognosURL, auth=kerberos_auth)

CAMPassport = CAMresponse.cookies['cam_passport']

# POST api request to retrieve CellSet from the cube view
# =================================================================================
cubename = "'< enter value >'"
viewname = "'< enter value >'"

TM1URL = f"https://saturn-06.ads.ide.ac.uk:8881/api/v1/Cubes({cubename})/Views({viewname})/tm1.Execute?$expand=Cells"

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response = requests.post(TM1URL, headers=httpheaders, verify=False)

# Retrieve the location of the cell values stored
CellSetID = tm1response.json()['ID']

# GET api request to retrive cell values with dimension names using cellset ID
# =================================================================================
TM1URL2 = f"https://helium-06.ads.ntu.ac.uk:5050/api/v1/Cellsets('{CellSetID}')/Cells?$expand=Members($select=Name)"
# if you need dimension values replace ($select=Name) to ($select=Name;$expand=Hierarchy($select=Name)) in the URL above

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response2 = requests.get(TM1URL2, headers=httpheaders, verify=False)

print(tm1response2.json())
# the output returned is in json with complex data structures. Therefore further data manipulation is required either in this same Python script or in M code in Power Query. Python is faster than Power Query especially when manipulating data with more than 1 million rows.
# Scripts for further manipulation will be shared in due course
```
Access code file [*here*](/Full-Code.md)

## Alternatives to REST API

Other methods to connect TM1 with Power BI include:

1. ODBC Data Connector: Available only for TM1 on Cloud environments.
    - If you're using TM1 on-premises and prefer the ODBC connector, consider creating an intermediate relational database in your data warehouse. Use TI functions like ODBCOpen, ODBCClose, and ODBCOutput to transfer data to this database, and then connect Power BI to the database via ODBC.
2. TI Scripts with CSV Export: Export cube data as .csv files using TurboIntegrator (TI) processes.

# Documentation

https://www.ibm.com/docs/en/planning-analytics/2.0.0?topic=analytics-tm1-rest-api

# Issues

If you find issues, sign up in GitHub and open an Issue in this repository

# Contribution

I am an independent developer.
If you find a bug or feel like you can contribute please fork the repository, update the code and then create a pull request so we can merge in the changes.

<!-- section for managing active sessions on TM1 model coming soon -->