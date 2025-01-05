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
TM1URL2 = f"https://saturn-06.ads.ide.ac.uk:8881/api/v1/Cellsets('{CellSetID}')/Cells?$expand=Members($select=Name)"
# if you need dimension values replace ($select=Name) to ($select=Name;$expand=Hierarchy($select=Name)) in the URL above

httpheaders = { 'Authorization': 'CAMPassport ' + CAMPassport, 'Content-type': 'application/json'}
tm1response2 = requests.get(TM1URL2, headers=httpheaders, verify=False)

print(tm1response2.json())
# the output returned is in json with complex data structures. Therefore further data manipulation is required either in this same Python script or in M code in Power Query. Python is faster than Power Query especially when manipulating data with more than 1 million rows.
# Scripts for further manipulation will be shared in due course