# 🚀 Incremental Data Loading Project and Audit with SSIS

## 📌 Description  
This project implements an **incremental data load process** using **SQL Server Integration Services (SSIS)**.  
It integrates data from a CSV file into a SQL Server database without duplicates and includes a change audit.  

---

## 📊 **Technologies Used**  
✅ **CSV as data source**  
✅ **SQL Server**  
✅ **SQL Server Agent**  
✅ **SSIS (SQL Server Integration Services)** 

---

## 🛠 **Database Structure**  

🔹 **Ventas_Origen** → Staging table with raw data from CSV.  
🔹 **Ventas_Destino** → Final table with consolidated data.  
🔹 **Ventas_Auditoria** → Table where changes in records are logged.  

---

## ⚙ **Project Workflow**  

1️⃣ **Load data from CSV** into a Intermediate table (**Ventas_Origen**).  
2️⃣ **Compare with the final table** (**Ventas_Destino**) to detect new or modified records.  
3️⃣ **Log changes** in the **Ventas_Auditoria** table.  
4️⃣ **Update existing records** in **Ventas_Destino**.  
5️⃣ **Insert new records** into **Ventas_Destino**.  
6️⃣ **Clean up the staging table** (**Ventas_Origen**) for future runs.  
7️⃣ **Automate execution every 2 hours** using SQL Server Agent.  

---

## 🚀 **Running the Project**  

### 📥 **Prerequisites**  
- Download the **dataset** from [Kaggle](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final).
- **SQL Server** installed.  
- **SSIS** enabled.
- **SQL Server Agent** enabled.  

### ⚡ **Steps to Execute**  
1️⃣ Import the **SSIS project** into SQL Server Data Tools.  
2️⃣ Set up the **CSV file path** in the Data Flow Task.  
3️⃣ Run the ETL process in SSIS.  
4️⃣ Verify the data in SQL Server.  
5️⃣ Deploy the project in **Integration Services Catalogs**.  
6️⃣ Create a **Job in SQL Server Agent** for automated execution every 2 hours.  

---

## 📊 **Conclusion**

The process for this project automates the incremental loading of data without duplication and maintains an audit log of changes to the database.

---

### 📌 Notes:
The complete and detailed project process can be found in the PDF: SSIS - Incremental Data Loading and Auditing.pdf

---

**Author:** Eng. Máximo Silva Parraguez
