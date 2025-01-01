# TM1/Planning Analytics

Disclaimer
=======================
This repository is newly set up and undergoes continous amendments on a daily basis. I reccommend following the guides and documentations provided by industry leaders within this space such as IBM and Cubewise. Thanking you for visiting my page.

A complete repository showcasing my knowledge and understanding of IBM TM1/Planning Analytic. In this repository I demostrate how to build an end to end TM1 application as well as TI Functions to get started with any TM1 model requirement.

It also covers REST API and a prototype Sales model for a Company showcasing my TM1 portfolio. 

This page demostrates how to launch a TM1 server as a service.

Configuration
=======================

To get started with TM1 Application, you must have three files at the minimum: data directory folder, log directory folder and tm1s.cfg file

The tm1s.cfg must specify these parameters:
- Server name
- Server port number
- data directory file path
- log directory file path
- HTTP Port number
- Security Mode
- Use SSL
- Admin Host
- IPVersion

Might-want parameters:
- MTQ
- Use Sandboxes
- Persistent Feeders
- Enable Hierarchies
- Progress Message
- Audit Log On
- Audit Log Size
- Audit Log Update
- Server CAM URI (only if the security mode is 4 or 5)
- Client CAM URI (only if the security mode is 4 or 5)
- Allow Seperate rule name calculations
- Force Feeder Re-calculation after change
- Startup Chores

Folder Structure:
TM1 Application Server Name Folder (parent) <br>
(children below) <br>
-> Data Folder <br>
-> Log Folder <br>
-> tm1s.cfg File <br>
-> Backup Folder <br>
-> Migrate Folder <br>
-> Output Folder (optional if you are exporting cube data into a .csv) <br>

<strong>IBM Cognos Configuration</strong>

To launch the model as a service, you need to create a new instance in Cognos Configuration.

Step 1 - Open Cognos Configuration <br>
Step 2 - right-click Data Access > TM1 Server > New Resource > TM1 Server instances <br>
Step 3 - Put the server name (make sure the name matches the server name mentioned in your tm1s.cfg) <br>
Step 4 - assign the path <br>
Step 5 - right-click and start the instance <br>

TurboIntegrator Functions
=======================

TurboIntegrator (TI) is an IBM created scripting tool to Extract, Tranform and Load (ETL) TM1 data. It adds creativity into resolving complex data loading and system processes into more manageable. It is more flexibe and dynamic than system generated scripts therefore an essential skill for all TM1 developers.

The TI process script consists of 4 sections: <strong>Prolog, Metadata, Data and Epilog</strong>

1. <strong>Prolog:</strong> this section runs once before opening the data source of the TI process.
2. <strong>Metadata:</strong> this section opens the data source and runs on each record of the data source. However, it only gets committed once at the end of the execution of this particular section. It creates a virtual copy of the dimension and makes changes in this virutal dimension until the iteration terminates and then commits the changes. Exception if you are using direct functions to add or delete elements then the its committed straightaway (however this might reduc perfomarnce and make the process slower). The Metadata is used for manipulating dimensions, this section must not be used to input/load data into cubes. 
3. <strong>Data:</strong> this section runs on each record of the data source and is mainly used to load data into the cubes. You may manipulate the dimension in this section by using the direct functions without affecting the perfomance to manage errors or unexpectency more easily.
4. <strong>Epilog:</strong> this sections runs once after the data source file is closed and this is the last section of the TI process. Mainly use this to send error messages to server log and call different TI process to run.

The TI process always runs in this sequence above.

Rules
=======================

Rules are part of cubes that enables derive cells values through calculations. The scripting used for Rules is also Turbointegrator however, there are restrictions on what TI functions can and cannot be used. 

Naturally, TM1 engine is designed in such a way that it uses TM1 consolidation engine to calculate consolidations in a cube as TM1 engine only stores leaf level values, consolidations are always recalculated. These calculations are performed using Sparse Consolidation Algorithm which basically insists the engine to ignore empty cells as well as rule-derived cells (unless fed) while calculating consolidations.

Therefore, TM1 engine automactically disables Sparse Consolidated Algorithm as soon as there is a rule-derived calculation. So the engine now checks each and every cell to ensure it's empty or not when consolidating data. This may lead to low performance and highly time consuming task for the engine especially if your cube is largely sparse (i.e. contains vast empty cells).

<strong>SKIPCHECK</strong> and <strong>FEEDERS</strong> are the two components that allow you to enable Sparse Consolidation Algorithm back again however, this time the rule-derived values are fed into the cell so the algorithm puts a flag against these cells when recalculating consolidated members of the dimension.

REST API
=======================

You can use TM1 REST API to Create, Read, Update and Delete (CRUD) data objects on IBM Cognos TM1 instances/servers using oData version 4 standards allowing clients such as Microsoft Power BI to query the TM1 database. The TM1 REST API is only enabled when you have set parameters HTTPPortNumber and UseSSL in your tm1s.cfg file.

All TM1 REST API responses are returned in JSON output.

Company XYZ Sales Model - prototype (coming soon...)
=======================

Company XYZ requires a TM1 application to streamline the reporting of sales information. XYZ employs a team of sales representatives to market a diverse range of products across various categories to customers. While the company establishes a standard monthly list price for each product, sales representatives have the flexibility to negotiate prices with customers to close deals.

<strong>Objective</strong>

The primary goal for XYZ is to maximize revenue by achieving sales as close to the list price as possible. The company seeks a system to monitor discounting levels used by their salesforce to secure sales. Additionally, they aim to review and analyze total sales data across the organization with the capability to drill down into specific dimensions such as sales representatives, products, product categories, customers, and time periods.

<strong>Requirements</strong>

Granular Sales Analysis:<br>
XYZ requires the ability to analyze data by multiple dimensions:
- Sales Representatives
- Products & Product Categories
- Customers
- Time (summarized by year, quarter, month, and week).

Time Aggregation Standards: 
- Monthly totals should include all days in the month.
- Weekly totals should align with a Monday-to-Sunday sales cycle.

Discounting Insights:<br>
XYZ wants to monitor:
- Discount dollars ($)
- Discount percentages (%)

Future Scalability:<br>
In the future, XYZ plans to integrate budgeting capabilities into the application:
- Budgets will be tracked by month, sales representative, customer, and product category.
- Monthly list prices will serve as a baseline, with sales representatives expected to achieve at least 90% of the list price on average.

Data for budgets and sales will be sourced from daily extracts:
- Individual sales data in one extract.
- Monthly list price data in another.

<strong>Key Reporting Metrics</strong>

At a minimum, the TM1 application must support reporting on the following fields:
- Units Sold
- List Price
- Sale Price
- Revenue
- Discount (both in dollars and as a percentage)

<strong>User Interface and Integration</strong>

The application will support multiple end users and provide flexibility in reporting using standard TM1 interfaces, including:

- Planning Analytics Workspace
- Perspectives (Excel and TM1 Web)

In the future, XYZ plans to leverage TM1 cubes as a data source for their existing Cognos BI system, enhancing their reporting ecosystem.

<strong>Conclusion</strong>

The TM1 application will provide Company XYZ with a powerful tool to analyze sales performance, monitor discounting practices, and support revenue optimization. The scalable design will accommodate future needs, including budgeting and integration with Cognos BI.

<strong>Initial Working Outs:</strong>

Decide what Model Approach is the best based on these factors below:

<strong>Single Cube or Multiple Cubes?</strong>
- Level of Granularity
- Take Lookup Approach to avoid 'dummy' elements

<strong>Dimension Presentation vs Physical Order?</strong>
- Memory Consumption
- Performance
- Usability 
- Consistency
- Maintenance

Order dimensions from smallest sparse to largest sparse, followed by smallest dense to largest
dense

<strong>Measure Dimension?</strong>
- clear model requirement for calculated members available for end users
- can include single element
- must always be the last dimension of the cube to determine the data type of the cube cell

<strong>Time Dimesnion?</strong>
- flexibility to compare data between years, months, etc.
- is the model rolling or one year model
- maintenance effort required to add new time cycles

<strong>Naming Conventions:</strong> it is an important practise for every developer to follow naming conventions to migitate confusion, better handover delivery and maintain consistency throught the TM1 model.

- For Cubes: must be descriptive and can contain spaces. Priortise spaces over underscores, commas, etc. E.g. instead of GL_SalesandRevenue maybe just use General Legder Sales or even Sales
- For Dimension: must always be singular than plural. Keep it one word if you can. E.g. use Department instead of Departments
- For TI processes: initiate process to describe what the process is going to update/manipulate. E.g. CU for Cube Update, DU for Dimension Update, SU for System Update, } for Control Object processes. Try use underscores as I would avoid using spaces in naming TI processes. 

Approaches to Project Management/Product Development
=======================

<strong>1. Waterfall Approach</strong>
- More of a systematic and static approach. If the product you are trying to deliver requires involvement of multiple teams and stakeholders especially in hierarchy intensive companies. This approach might work better.
- Downfall is reduction in product deployment time and less flexible to making changes in the product requirements and objectives. 

<strong>2. Agile Approach</strong>
- More flexible and friendly approach when product requirements are not clearly defined upfront. Enables colobaration with various teams however, tasks are identified and prioritised according to the product needs and wants. Industry famous as this encourages continous feedback loop between users and developers.
- Hard to predict product delivery due to looping/iterative nature of project management.

<strong>3. Prototyping Approach</strong>
- Best to showcase users what the product you are trying to deliver can offer. Helps to develop a proof of concept model before unleashing full development of the system/product. Therefore may not have to be fully functional.
- This approach is ideally embedded in both waterfall and agile delivery pipelines.

References
=======================

https://www.ibm.com/docs/en/planning-analytics/2.0.0?topic=analytics-planning-workspace

Issues
=======================

If you find issues, sign up in GitHub and open an Issue in this repository

Contribution
=======================

I am an independent developer.
If you find a bug or feel like you can contribute please fork the repository, update the code and then create a pull request so we can merge in the changes.
