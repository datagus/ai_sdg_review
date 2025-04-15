
## 🗃️ SQL Database Setup (For Beginners)

This folder contains everything you need to **recreate the project's database** using **MySQL**. Don't worry if you're new to SQL — just follow the steps below.

### 📁 Folder Structure

<pre>
sql/
├── EER_diagram.mwb               # MySQL Workbench visual diagram
├── database_dump.sql             # Full SQL dump of the database (structure + data)
├── database_creation_script.sql  # SQL script to create empty tables (structure only)
<pre>

---

### 🪰 Requirements

- **MySQL Server** (e.g., [MySQL Community Edition](https://dev.mysql.com/downloads/mysql/))
- **MySQL Workbench** (GUI tool to interact with MySQL)  
  Download here: https://dev.mysql.com/downloads/workbench/

---

### 📝 What Are These Files?

| File                         | Description                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|
| `EER_diagram.mwb`           | A visual diagram of the database schema, viewable in MySQL Workbench.       |
| `database_creation_script.sql` | Creates all tables, but does **not** include data.                        |
| `database_dump.sql`         | Includes both the **structure and data** of the database.                   |
---

### 🚀 Steps to Recreate the Database

#### **Option 1: Easiest – Use the Full SQL Dump**

1. **Open MySQL Workbench**  
   - Create a **new connection** if you haven't already.

2. **Create a New Schema (Database)**  
   - Example name: `my_project_db`  
   - Click the lightning bolt to execute and create it.

3. **Import the Dump**
   - Go to `File > Open SQL Script` and select `database_dump.sql`.
   - Make sure your target schema (e.g. `my_project_db`) is selected in the SQL tab.
   - Run the script (lightning bolt icon).

✅ You now have the full database including data.

---

#### **Option 2: Build from Scratch**

Use this if you want to **create the structure only**, and populate it yourself:

1. Follow Steps 1–2 above to create a schema.
2. Open and run `database_creation_script.sql`.
3. If needed, explore files in `additional_tables/` and run them as needed.

---

### 🛍️ Exploring the Database Visually

1. Open `EER_diagram.mwb` in MySQL Workbench.
2. You'll see a diagram showing how tables are related via foreign keys.
3. This helps you understand the **relational structure** of the database.

---

### 💡 Tips for Beginners

- MySQL commands end with a semicolon `;`
- You can explore table contents using:
  ```sql
  SELECT * FROM table_name;
  ```
- Be sure to back up your database before making changes.

