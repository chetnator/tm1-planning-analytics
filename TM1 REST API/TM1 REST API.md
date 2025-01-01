# TM1 Power BI Integration via REST API

You can use TM1 REST API to Create, Read, Update and Delete (CRUD) data objects on IBM Cognos TM1 instances/servers using oData version 4 standards allowing clients such as Microsoft Power BI to query the TM1 database.

This repository demonstrates how to establish a connection to TM1 instances via REST API by executing Python scripts in Power BI.

All TM1 REST API responses are returned in JSON output.

Prerequisites
=======================

<strong>TM1 side:</strong><br>
Ensure that the TM1 REST API is enabled by setting the HTTPPortNumber parameter in the tm1s.cfg file. E.g. `HTTPPortNumber=5555`

Additionally, configure the UseSSL parameter to either T (true) or F (false) to specify the protocol (HTTP or HTTPS). E.g. `UseSSL=T`

Validate your TM1 REST API by simply putting a GET request in any browser such as Edge or Google. Use this URL format:
```
<protocol>://<serverName>:<httpPortNumber>/api/v1/
```
Example:
```
https://saturn-06.ac.uk:8081/api/v1/
```

If you receive a response, the TM1 REST API is successfully accessible.

<strong>Power BI side:</strong><br>
1. Install Python (3.7 or higher) on your local machine.
2. Power BI's Python integration requires two Python libraries: pandas and matplotlib. Install them using the following commands in Terminal or PowerShell:

```
pip install pandas
pip install matplotlib
```

3. Enable Python scripting in Power BI by navigating to File > Options and Settings > Options > Python scripting, then click OK.

You can use a Python IDE like VSCode to run your scripts in Power BI Desktop or use the Python Script connector in the Get Data section.

Authentication
=======================

TM1 supports five different authentication methods. This repository focuses on connecting to the TM1 server when the IntegratedSecurityMode parameter in tm1s.cfg is set to 5. E.g. `IntegratedSecurityMode=5`

Mode 5 uses IBM Cognos Analytics or Cognos Authentication Manager (CAM) authentication. It involves two steps:

<strong>Step 1 - Authenticating to your Cognos BI server</strong>

The URL for this will be in your tm1s.cfg file with parameter set up as ClientCAMURI. This URL is necessary to log in into Cognos BI server which will return a CAMPassport cookie/token upon authenticating into Cognos BI server. The example below assumes your Cognos BI server configuration is set to accept kerberos authentication method.

On top of the two libraries installed earlier, you will also need to download these Python libraries: requests and requests_kerberos

```python
import requests
from requests_kerberos import HTTPKerberosAuth, REQUIRED

Username = " <enter your username> "
Password = " <enter your password> "

Domain = " <enter your domain e.g. ADS> "

# Assign Cognos BI server URL found in tm1s.cfg file example shown below
CognosURL = "https://saturn-02:440/ibmcognos/bi/v1/disp"

# Send GET request
kerberos_auth = HTTPKerberosAuth(principal=f'{Username}@{Domain}', password=Password, mutual_authentication=REQUIRED)
CAMresponse = requests.get(CognosURL, auth=kerberos_auth)

CAMPassport = CAMresponse.cookies['cam_passport']
```

<strong>Step 2 - Authenticating to TM1 server using CAMPassport token</strong>

```python
TM1URL = "https://saturn-dev:8081/api/v1/Cubes"

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response = requests.get(TM1URL, headers=httpheaders, verify=False)

jsonoutput = tm1response.json()
```

Managing Sessions
=======================

Once successuly authenticated on TM1 server, the repsonse will have a cookie "TM1SessionID". The value of this cookie can be re-used when sending following REST API requests meaning you don't need to re-authenticate on every request sent.

By default, the session ID cookie expires in 20 minutes but this can be changed by setting up a parameter "HTTPSessionTimeoutMinutes" in the tm1s.cfg file. E.g. HTTPSessionTimeoutMinutes=40

Value represents in minutes.

API calls
=======================

REST API offers handy calls to interact with TM1, but this repository only focus on 2 calls GET and POST:

- GET to read data from cubes through cube views or MDX queries (e.g. `/Cubes('<cubename>')`)
- POST to write data to cubes (e.g. `Cubes('<cubename>')/Views('<viewname>')/tm1.Execute?$expand=Cells`)

In this repository we won't use POST to update cube data but to only query cube view as only POST allows you to query a cube view (using GET will throw an error). The response of this call will include a `cellsetid` which defines the location of the cellset. This is needed to retrieve cell values of a cube view using GET request.

For Example:
```python
# Step 1: send POST request to recieve cellset ID with empty body
# =================================================================================
cubename = "'< enter cubename >'"
viewname = "'< enter view name >'"

TM1URL = f"https://saturn-dev:8081/api/v1/Cubes({cubename})/Views({viewname})/tm1.Execute?$expand=Cells"

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response = requests.post(TM1URL, headers=httpheaders, verify=False)

CellsetID = tm1response.json()['ID']

# Step 2: send GET request to retrieve Cell Values using cellset ID
# =================================================================================

TM1URL2 = f"https://saturn-dev:8081/api/v1/Cellsets('{CellsetID}')/Cells?$expand=Members($select=Name)"

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response2 = requests.get(TM1URL2, headers=httpheaders, verify=False)

jsonoutput = tm1response2.json()
```

Full Code
=======================

```python
import pandas as pd
import requests
from requests_kerberos import HTTPKerberosAuth, REQUIRED

Username = " <enter your username> "
Password = " <enter your password> "

Domain = " <enter your domain e.g. ADS> "

# Assign Cognos BI server URL found in tm1s.cfg file example shown below
CognosURL = "https://saturn-02:440/ibmcognos/bi/v1/disp"

# Send GET request
kerberos_auth = HTTPKerberosAuth(principal=f'{Username}@{Domain}', password=Password, mutual_authentication=REQUIRED)
CAMresponse = requests.get(CognosURL, auth=kerberos_auth)

CAMPassport = CAMresponse.cookies['cam_passport']

# Step 1: send POST request to recieve cellset ID with empty body
# =================================================================================
cubename = "'< enter cubename >'"
viewname = "'< enter view name >'"

TM1URL = f"https://saturn-dev:8081/api/v1/Cubes({cubename})/Views({viewname})/tm1.Execute?$expand=Cells"

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response = requests.post(TM1URL, headers=httpheaders, verify=False)

CellsetID = tm1response.json()['ID']

# Step 2: send GET request to retrieve Cell Values using cellset ID
# =================================================================================

TM1URL2 = f"https://saturn-dev:8081/api/v1/Cellsets('{CellsetID}')/Cells?$expand=Members($select=Name)"

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response2 = requests.get(TM1URL2, headers=httpheaders, verify=False)

df = tm1response2.json()
```
I would reccommend running this script in VSCode first to validate and check for any errors before you run this in Power BI Desktop.

Alternatives to REST API
=======================

Other methods you may use to connect to TM1 in Power BI are ODBC data connector (only works if you using TM1 on cloud) or running TI scripts to export cube data into .csv files.

If you have a data warehouse and wish to go ahead via ODBC connector and you are using TM1 on premises. I suggest you to create an intermediatary relational database in your warehouse and add an ODBC connector to this new database. Then use TI functions such as ODBCOpen, ODBCClose and ODBCOutput in your TI processes.

Documentation
=======================

https://www.ibm.com/docs/en/planning-analytics/2.0.0?topic=analytics-tm1-rest-api

Issues
=======================

If you find issues, sign up in GitHub and open an Issue in this repository

Contribution
=======================

I am an independent developer (beginner to moderate level friendly).
If you find a bug or feel like you can contribute please fork the repository, update the code and then create a pull request so we can merge in the changes.

<strong>Additions to this repository coming soon: JSON to Dataframe manipulation and managing sessions using TM1 session ID</strong>