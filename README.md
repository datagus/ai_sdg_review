# Systematic Literature Review Repository

Welcome to the **Systematic Literature Review (SLR)** repository! This repository was prepared for a study submitted to **Nature Sustainability**. It provides all relevant data, scripts, and instructions for replicating or understanding the workflow. This README is meant to guide reviewers or anyone else who may be new to GitHub or software repositories.

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

.
├── database
│   ├── EER_diagram.mwb            # MySQL Workbench EER diagram
│   ├── database_dump.sql          # SQL dump of the database
│   ├── database_creation_script.sql  # SQL script to create the database
│   └── additional_tables          # Folder with any extra SQL tables
│
├── excel_tables
│   ├── empirical_clusters_revised.xlsx
│   ├── environment.xlsx
│   ├── …
│   # These Excel files store data derived from or imported into SQL.
│
├── images
│   └── … # Vector images used in the article
│
├── python
│   ├── pdf_extraction.py    # Script to extract text from PDFs using Python
│   ├── pushing_to_sql.ipynb # Script/Notebook to insert data into SQL
│   ├── from_sql.ipynb       # Script/Notebook to pull data from SQL
│   ├── config.json          # Configurations (e.g., database credentials)
│   └── …
│
├── R-files
│   ├── word_analysis
│   │   ├── package_draft.R
│   │   ├── normal_cloud.R
│   │   └── …
│   │   # Scripts performing word analysis, detrended correspondence analysis, etc.
│   └── text_files
│       └── …
│       # Output from certain R-based analyses
│
├── tableau
│   └── analysis.twbx
│   # Tableau workbook for visualizing the data
│
└── README.md  # (This file)


**Note:** Some filenames may differ slightly from what is shown here, but this structure should help you navigate.

---

## 3. Tools & Versions

Below are the primary tools used in this study, along with the versions tested.  
Feel free to adapt these to reflect your exact software versions:

- **Python** (version 3.9 or higher)
  - Major libraries: `nltk`, `unstructured`, `pandas`, `sqlalchemy`
- **R** (version 4.2.x)
  - Major packages: `vegan`, `tm`, `wordcloud`, etc.
- **MySQL** (version 8.0.x)
  - The SQL scripts (`database_dump.sql`, `database_creation_script.sql`) were tested on MySQL 8.0.x
- **Tableau** (version 2022.x)
  - The workbook `analysis.twbx` was created in this version
- **Microsoft Excel** (version 2019 or 2021)
  - Used to store and manipulate some data

If you do not have these exact versions, the code and data should still work with close versions.

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
   - All Excel files are located in `excel_tables`.
   - You can open them in any modern spreadsheet application for further inspection or analysis.

4. **Python Scripts**
   - The `python` folder contains scripts for:
     - **`pdf_extraction.py`**: Extract text from PDFs.  
     - **`pushing_to_sql.ipynb`**: Insert data from local files into the SQL database.  
     - **`from_sql.ipynb`**: Pull data from the SQL database into Python or Excel.  
   - Update `config.json` with your database credentials (host, user, password) before running.

5. **R Scripts**
   - The `R-files/word_analysis` folder holds scripts for advanced word analysis.
   - **Detrended Correspondence Analysis** is performed here using relevant R packages (e.g., `vegan`).
   - The `text_files` folder may contain intermediate outputs or text data used in analyses.

6. **Tableau Visualization**
   - The `tableau/analysis.twbx` file can be opened in Tableau Desktop (2022.x or above).
   - Once opened, you may need to configure the data source connection to your local SQL database.

7. **Images**
   - The `images` folder includes vector images referenced in the article.

---

## 5. Contact & Additional Information

- For questions regarding specific scripts, please see code-level comments.
- If you need guidance on replicating the environment or re-running any steps, please refer to the instructions inside each script and the relevant sections of this README.

**Thank you** for reviewing this repository and for your interest in our systematic literature review!