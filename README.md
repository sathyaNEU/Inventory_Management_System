# Inventory Management System Implementation using Oracle PL/SQL

# Objective

**Enhance Inventory Transparency**: Real-time addition of categories and products for seamless stock monitoring and accuracy

**Streamline Order Processing**: Empower customers to modify orders and add products during the "processing" stage, ensuring efficient fulfillment
Proactive Restocking Mechanism: Automatically generate product supply records for timely reorders, aiding inventory management

**Dynamic Pricing and Billing**: Apply discounts, calculate final prices, and generate accurate total bills for precise financial transactions

**Comprehensive User Management**: Allow easy updates to personal information for customers and suppliers, ensuring accurate records

**Operational Efficiency**: Optimize supplier relationships, minimize holding costs, and prevent stockouts for streamlined operations

**Scalable Growth Support**: Design for scalable growth, accommodating evolving business needs and facilitating long-term expansion


# Instructions to execute - Oracle (version 19c)

IMSDB_ADMIN script to be run 
1.  Script1.sql creates application admin IMS_ADMIN and grants privileges.
    
Login as IMS_ADMIN with credentials for steps 2 and 3
2.	Script 2.sql creates tables with appropriate constraints,sequences and views.
3.  Script 3.sql creates users for suppliers, customers, IMS_Manager and logistic_admin and grants privileges.

Login as Customer with credentials  for step 4
4.  Script 4.sql performs onboarding of customer - Insertion of customer records

Login as Supplier with credentials  for step 5
5.  Script 5.sql performs onboarding of supplier - Insertion of supplier records

Login as IMS_MANAGER with credentials for steps 6
6.  Script 6.sql to insert records into tables

Login as IMS_ADMIN with credentials for steps 7
7.  Script 7.sql to insert order and produucts

Login as LOGISTIC_ADMIN with credentials for steps 8
8.  Script 8.sql to update shipping status of order

Login as Customer with credentials for steps 9
9.  Script 9.sql to generate views for customer

Login as Supplier with credentials for steps 9
10.  Script 10.sql to generate views for supplier

# Physical Model
![image](https://github.com/sathyaNEU/Inventory_Management_System/assets/144740003/5f099bdd-15e2-4a96-aa87-39bbf9424bf0)

**Please refer to [DMDD FINAL.pdf](https://github.com/sathyaNEU/Inventory_Management_System/files/14487278/DMDD.FINAL.pdf) to know more about our project**

