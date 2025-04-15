# Artificial Intelligence for Sustainable Development: A Systematic Review - Repository

Welcome to the **Artificial Intelligence for Sustainable Development: A Systematic Review** repository! This repository was prepared for a study submitted to **Nature Sustainability** journal. It provides all relevant data, scripts, and instructions for understanding and reproducing the data workflow undertaken in the review. 

---

## 1. Overview

1. **Objective**  
   - The main purpose of this repository is to document the systematic literature review process, detailing how data was collected, stored, analyzed, and visualized.

2. **Components**  
   - **Database** in both SQL and Excel formats.  
   - **Python Scripts** for PDF text extraction and database handling (insertion into SQL, exporting from SQL to Excel, etc.).  
   - **R Scripts** for word analysis and statistics (including a detrended correspondence analysis).  
   - **Tableau** workbook for visualizing the data.  
   - **Images** (vector graphics) used in the article.

---

## 2. Repository Structure

Below is a simplified description of each main folder:
<pre>
.
├── database
│   ├── sql
│   │   ├── EER_diagram.mwb             # MySQL Workbench EER diagram
│   │   ├── database_dump.sql           # SQL dump of the database
│   │   ├── database_creation_script.sql  # SQL script to create the database
│   │
│   └── excel_tables
│       ├── master_table_copy.xlsx     # Master Excel table
│       └── individual_tables          # Folder with individual Excel data tables
│
├── images
│   └── …                               # Vector images used in the article
│
├── python
│   ├── pdf_extraction.py               # Script to extract text from PDFs using Python
│   ├── pushing_to_sql.ipynb            # Script/Notebook to insert data into SQL
│   ├── from_sql.ipynb                  # Script/Notebook to pull data from SQL
│   └── … 
│
├── R-files
│   ├── word_analysis
│   │   ├── package_draft.R
│   │   ├── normal_cloud.R
│   │   └── …                           # Scripts for word analysis, DCA, etc.
│   └── text_files
│       └── …                           # The pdfs transformed into text files containing only nouns.
│
├── tableau
│   └── analysis.twbx                   # Tableau workbook for visualizing the data
│
└── README.md                           # (This file)

</pre>

---

## 3. Tools & Versions

Below are the primary tools used in this study, along with the versions tested.  The operative system used was MacOS 15 Sequoia.

- **Python** (version 3.9 or higher)
  - conda package manager used (conda 24.11.0)
- **R** (version 4.4.0)
- **MySQL** (version 8.3.0)
- **Tableau** (version 2024.3)
- **Microsoft Excel** (vVersion 16.95.4)

If you do not have these exact versions, the code and data should still work with close versions. Even instead of using MySQL, PostgreSQL or other relational database software can be used, with minimal adaptation to the scripts.

---

## 4. How to Use this Repository

Below is a simplified set of steps for those unfamiliar with GitHub or code repositories:

1. **Clone or Download** this repository
   - If you are new to GitHub, you can click the green “Code” button (above, on the main page of the repository) and select **“Download ZIP”**.

2. **Database Setup**
   - Navigate to the `database` folder.
   - Create a new MySQL database (if needed) and run `database_creation_script.sql`, followed by `database_dump.sql` to replicate the tables and data locally.
   - Alternatively, you can consult the `EER_diagram.mwb` file in MySQL Workbench to understand the schema.

3. **Excel Files**
   - The Excel files are structured to mimic a relational database, with shared **ID fields** establishing relationships between tables.
   - All Excel files of the database are located in the `excel_tables` folder (within the `database` directory).
   - These files can be opened in any modern spreadsheet application for inspection, analysis, or integration with tools like Power BI or Tableau.
   - The `master_table_copy.xlsx` serves as a central table, while additional tables in the `individual_tables` folder provide related data linked by these common IDs. However, for better data practice, it is recommended to use the individual tables.

4. **Python Scripts**
   - The `python` folder contains scripts for:
     - **`pdf_extraction.py`**: Extract text from PDFs.  
     - **`pushing_to_sql.ipynb`**: Insert data from local files into the SQL database.  
     - **`from_sql.ipynb`**: Pull data from the SQL database into Python or Excel.  
   - To run the scrips it is necessary to have the SQL database credentials (host, user, password) before running.

5. **Word Analysis**
   - The `word_analysis` folder holds R scripts for multivariate statistical word analysis.
   - **R-Scripts** contains the code that imports the text files from the folder text_files and performs a detrented correspondance analysis plus a abundance species analysis of the nouns.
   - The `text_files` folder contains the individual scientific papers for the review but only the nouns and in .txt format.

6. **Tableau Visualization**
   - The `tableau/analysis.twbx` file can be opened in Tableau Desktop (2024.3 or earlier versions).
   - Once opened, you may need to configure the data source connection to your local SQL database, or you can import manuall the individual excel_tables

7. **Images**
   - The `images` folder includes vector images referenced in the article.

---

## 5. Additional Information

- For questions regarding specific scripts, please see code-level comments.
- If you need guidance on replicating the environment or re-running any steps, please refer to the instructions inside each script and the relevant sections of this README.
