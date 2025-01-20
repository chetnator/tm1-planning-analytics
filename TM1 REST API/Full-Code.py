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
os.environ["AZURE_CLIENT_ID"] = " < enter value > "
os.environ["AZURE_CLIENT_SECRET"] = " < enter value > "
os.environ["AZURE_TENANT_ID"] = " < enter value > "
os.environ["VAULT_URL"] = " < enter value > "

# Create a DefaultAzureCredential instance
credential = DefaultAzureCredential()
 
# Create a SecretClient instance
client = SecretClient(vault_url=os.environ["VAULT_URL"], credential=credential)
 
# Retrieve the secrets
username_secret = client.get_secret(" < enter your key vault variable name for username > ")
password_secret = client.get_secret(" < enter your key vault variable name for password > ")
 
# Send GET Reguest to Cognos BI Server to receive CAM Passport via kerberos auth
# ========================================================================================
Username = username_secret.value
Password = password_secret.value

Domain = " < enter value > " 
# e.g "ADS"

CognosURL = " < enter value > "
# Syntax: "<protocol>://<server name>:<port number>/ibmcognos/bi/v1/disp"
# e.g "https://mercury.ads.ide.ac.uk:5000/ibmcognos/bi/v1"

# Send GET request if Keberos Auth is used (preferred)
kerberos_auth = HTTPKerberosAuth(principal=f'{Username}@{Domain}', password=Password, mutual_authentication=REQUIRED)
CAMresponse = requests.get(CognosURL, auth=kerberos_auth)

if CAMresponse.status_code == 200:
    CAMPassport = CAMresponse.cookies['cam_passport']
elif CAMresponse.status_code == 404:
    print(CAMresponse.status_code)
    print(CAMresponse.json()['error']['message'])
else:
    print(CAMresponse.status_code)

# POST request to retrieve CellSet from the cube view
# =================================================================================
cubename = "' < enter cube name > '"
viewname = "' < enter view name > '"

vTM1URL = " < enter TM1 API endpoint > "
# Syntax: "<protocol>://<server name>:<port number>/api/v1"
# e.g., "https://saturn.ads.ide.ac.uk:8881/api/v1"

TM1URL = f"{vTM1URL}/Cubes({cubename})/Views({viewname})/tm1.Execute?$expand=Cells"

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response = requests.post(TM1URL, headers=httpheaders, verify=False)


if tm1response.status_code == 200 or tm1response.status_code == 201:
    CellSetID = tm1response.json()['ID']
elif tm1response.status_code == 404:
    print(tm1response.status_code)
    print(tm1response.json()['error']['message'])
else:
    print(tm1response.status_code)

# GET request to retrive cell values with dimension names using cellset ID
# =================================================================================
TM1URL2 = f"{vTM1URL}/Cellsets('{CellSetID}')/Cells?$expand=Members($select=Name)"
# if you need dimension names replace ($select=Name) to ($select=Name;$expand=Hierarchy($select=Name)) in the URL above

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response2 = requests.get(TM1URL2, headers=httpheaders, verify=False)

print(tm1response2.json())
# the output returned is in json with complex data structures. Therefore further data manipulation is required either in this same Python script or in M code in Power Query. Python is faster than Power Query especially when manipulating data with more than 1 million rows.
# Scripts for further manipulation is below, this code returns the data in tabular format to load into Power Query.

if tm1response2.status_code == 200 or tm1response2.status_code == 201:    
    jsonoutput = tm1response2.json()['value']
    for i in jsonoutput:
        yy= []
        zz = {}
        for y in i['Members']:
            key = y['Hierarchy']['Name']
            value = y['Name']
            yy.append({key:value})
        i['Members'] = yy
        for z in i['Members']:
            zz.update(z)
        i['Members'] = zz
    # print(jsonoutput)
    df = pd.json_normalize(jsonoutput)
    print(df)
elif tm1response2.status_code == 404:
    print(tm1response2.status_code)
    print(tm1response2.json()['error']['message'])
else:
    print(tm1response2.status_code)