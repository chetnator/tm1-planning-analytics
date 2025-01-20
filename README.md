# TM1/Planning Analytics Showcase Repository

![IBM Logo](https://www.ibm.com/content/dam/connectedassets-adobe-cms/worldwide-content/creative-assets/s-migr/ul/g/18/f9/ibm_logo_pos_blue60_rgb.png/_jcr_content/renditions/cq5dam.web.1280.1280.png)

This repository highlights my understanding of the TM1/Planning Analytics system, covering a wide range of topics, including TurboIntegrator (TI) processes, integration with other systems, and more.

Please refer to IBM's official documentation for the most accurate and up-to-date guidance on using Planning Analytics.

As this is a newly established repository, it is actively updated and refined on a weekly basis to ensure continuous improvement and relevance.

## Getting Started

IBM's Planning Analytics is available in multiple deployment options:
- Planning Analytics on Cloud
- Planning Analytics as a Service
- Planning Analytics On-Premises (Local Installation)

Each option has its unique advantages. The choice of deployment should align with your organisation's specific requirements, including cost considerations, scalability, and infrastructure needs.

For simplicity, this repository focuses on the on-premises (local installation) deployment of Planning Analytics.

### tm1s.cfg

The **tm1s.cfg** file is an ASCII file that contains IBM TM1 server parameters.

#### Configuration Parameters

Must-have parameters:
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

### TM1 Directory Structure

A TM1 Application should always have two folders nested in folder for your TM1 Application:

- Data Folder:
Stores the data directory for the TM1 application. This folder contains subfolders like `model_upload` and critical files such as `.pro`, `.rux`, `.cub`, and others.

- Log Folder:
Contains the log directory for the TM1 application, including message logs, server logs (serverlog), agent logs (agentlog), and action logs (actionlog).

- Configuration File:
A file named `tm1s.cfg`, which serves as the TM1 application's configuration file.

Optional (Recommended) Folders

- Backup Folder:
Used to store compressed backup files, typically in `.zip` format, to ensure data security and recovery.

- Migrate Folder:
Facilitates the migration of the TM1 application between environments, such as from development to production.

- ModelExports Folder:
A repository for files exported via TurboIntegrator (TI) processes, often in `.csv` format.

### Starting Up TM1 Application/TM1 Instance

To launch the TM1 Instance, follow these steps to create a new instance in *IBM Cognos Configuration* (an application that must be installed beforehand):

1. Open Cognos Configuration
    - Start the Cognos Configuration application.

2. Create a New TM1 Server Instance
    1. Navigate to Data Access > TM1 Server.
    2. Right-click and select New Resource > TM1 Server Instance.

3. Set the Server Name
    1. Enter the server name.
    2. Ensure the server name matches the name specified in your tm1s.cfg file.

4. Assign the Path
    - Specify the path to the directory where your TM1 application files are stored.

5. Start the Instance
    - Right-click on the newly created instance and select Start to initialise the service.

## Components of TM1 Instance

A TM1 instance mainly has four components: **Cubes, Dimensions, Processes and Chores**. **Control Objects** is also considered one of the key components of a TM1 instance

1. **Cubes**
    - Data containers formed by two or more dimensions. Each intersection between dimensions contains either a value or is empty. Cubes are TM1 objects that are stored in the data directory of the TM1 server.
    - Views are arrangements of dimensions within a Cube tailored to meet specific requirements from the end-users. Views come in two forms: Native Views and MDX Views.
        1. **Native Views** are stored views within TM1 that have fixed rows, columns, and context dimensions.
        2. **MDX Views** use Multidimensional Expressions to query the Cube and create a dynamic view using MDX-enabled interfaces such as TM1 Planning Analytics Workspace. These are not original TM1 objects unless explicitly saved by the modeller.

2. **Dimensions**
    - Contain elements that are addressed as members of the dimension. Modellers create parent-child relationships between elements, which adds levels to the elements.
    - Attributes can be set for each element to provide additional information about the element. The most common use is Alias, which defines a more user-friendly name for the elements (these must be unique). Other attributes such as format and picklist are pre-defined TM1 attributes that perform a specific function.
    -  With the new **Hierarchy** feature added to TM1's architecture, these are now primarily hierarchy containers.
        - Hierarchies are alternative roll-ups that offer different consolidation definitions to cater to reporting needs. Leaves are rearranged with alternative parent relationships.

3. **Processes**
- These can be created by the TM1 system or a modeller. More information can be found below.

4. **Chores**
- Schedule TurboIntegrator (TI) processes by setting time and date to automate TM1 server activities.

5. **Control Objects**
- Typically store system-generated cubes and dimensions. These are very useful to understand how the TM1 server stores or controls data objects and also provide access to security cubes to define user permissions and data accessibility.

## TurboIntegrator (TI) Functions

TurboIntegrator (TI) processes are also one of the many TM1 Objects. TI language is IBM's scripting tool for **Extract, Transform, and Load** (ETL) operations in TM1. It enables developers to handle complex data loading and system processes efficiently, offering flexibility and dynamism beyond system-generated scripts. Mastery of TI is essential for all TM1 developers.

TI Process Sections
A TI process script is divided into four sections: **Prolog, Metadata, Data, and Epilog**, executed in the following order:

1. **Prolog**:
Executes once before opening the data source. Used for initial setups like variable declarations and configuration settings.

2. **Metadata**:
Iterates through each record of the data source, creating a virtual copy of dimensions for manipulation. Changes are committed only at the end of this section unless direct functions (e.g., DimensionElementInsertDirect(), DimensionElementComponentAddDirect(), etc.) are used, which commit changes immediately. However, frequent use of direct functions may reduce performance. This section is solely for dimension manipulation and should not be used to load data into cubes.

3. **Data**:
Processes each record of the data source and is primarily used to load data into cubes. Dimension manipulations can also be performed here using direct functions without significant performance impact, allowing for better error handling and flexibility.

4. **Epilog**:
Executes once after the data source is closed. This section is typically used for tasks such as logging errors, summarising the process outcome, or calling other TI processes.

TI processes always follow this sequence, ensuring a structured and logical flow for data and system operations.

## Cube Rules

Rules are scripts within cubes that enable calculated cell values. The scripting used for Cube Rules is also TurboIntegrator (TI) however, there are restrictions on what TI functions can and cannot be used.

By design, the TM1 engine relies on its **consolidation engine** to calculate consolidations dynamically, as it only stores values at the leaf level. Consolidations are recalculated using the **Sparse Consolidation Algorithm**, which optimises performance by ignoring empty cells and rule-derived cells (unless fed) during these calculations.

However, when rule-derived calculations exist, in another terms, when the Cube contains a Rule (`.rux` file) the TM1 engine automatically disables the **Sparse Consolidation Algorithm**. In this case, the engine evaluates every cell—both populated and empty—during consolidations, leading to potential performance degradation, especially in sparse cubes with many empty cells.

To mitigate this, TM1 provides two key components: `SKIPCHECK` and `FEEDERS`.

- **SKIPCHECK**: Re-enables the Sparse Consolidation Algorithm.
- **FEEDERS**: Marks rule-derived cells as "fed," ensuring the algorithm includes these cells in consolidation while maintaining performance optimisation.

Using `SKIPCHECK` and `FEEDERS` together helps maintain efficient consolidations, even with rule-derived calculations.

## TM1 REST API

The TM1 REST API enables users to perform **Create, Read, Update, and Delete (CRUD)** operations on IBM Cognos TM1 instances using the OData v4 standard. This allows integration with clients like Microsoft Power BI to query and interact with TM1 databases seamlessly.

This repository showcases how to connect to TM1 instances via the REST API by executing Python scripts within Power BI. While you can also use M code in Power Query, there are two key considerations:

1. Power BI natively blocks requests to environments with self-signed certificates.
2. Transforming JSON output into tabular data (e.g., Lists, Records, and Tables) requires advanced proficiency in M code.

All TM1 REST API responses are returned in JSON format, making it essential to understand JSON structures for effective data manipulation.

**To get started with TM1 REST API please click visit [*TM1RESTAPI.md*](/TM1%20REST%20API/TM1RESTAPI.md) for further information.**

<!-- ## TM1 Model Prototype (coming soon...) -->

## Approaches to Project Management/Product Development

**1. Waterfall Approach**
- More of a systematic and static approach. If the product you are trying to deliver requires involvement of multiple teams and stakeholders especially in hierarchy intensive companies. This approach might work better.
- Downfall is reduction in product deployment time and less flexible to making changes in the product requirements and objectives. 

**2. Agile Approach**
- More flexible and friendly approach when product requirements are not clearly defined upfront. Enables colobaration with various teams however, tasks are identified and prioritised according to the product needs and wants. Industry famous as this encourages continous feedback loop between users and developers.
- Hard to predict product delivery due to looping/iterative nature of project management.
- Use SCRUM to follow sprint planning, daily standups and prioritising product backlogs and sprint backlogs

**3. Prototyping Approach**
- Best to showcase users what the product you are trying to deliver can offer. Helps to develop a proof of concept model before unleashing full development of the system/product. Therefore may not have to be fully functional.
- This approach is ideally embedded in both waterfall and agile delivery pipelines.

## References

https://www.ibm.com/docs/en/planning-analytics/2.0.0?topic=analytics-planning-workspace

## Issues

If you find issues, sign up in GitHub and open an Issue in this repository.

## Contribution

I am an independent developer.
If you find a bug or feel like you can contribute please fork the repository, update the code and then create a pull request so we can merge in the changes.
