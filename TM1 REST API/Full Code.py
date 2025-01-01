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