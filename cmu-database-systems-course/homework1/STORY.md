I was trying out sqlite3

https://github.com/jpwhite3/northwind-SQLite3

https://sqlite.org/cli.html#getting_started

```bash
homework1 $ sqlite3 ex1
SQLite version 3.32.3 2020-06-18 14:16:19
Enter ".help" for usage hints.
sqlite> .help
.auth ON|OFF             Show authorizer callbacks
.backup ?DB? FILE        Backup DB (default "main") to FILE
.bail on|off             Stop after hitting an error.  Default OFF
.binary on|off           Turn binary output on or off.  Default OFF
.cd DIRECTORY            Change the working directory to DIRECTORY
.changes on|off          Show number of rows changed by SQL
.check GLOB              Fail if output since .testcase does not match
.clone NEWDB             Clone data into NEWDB from the existing database
.databases               List names and files of attached databases
.dbconfig ?op? ?val?     List or change sqlite3_db_config() options
.dbinfo ?DB?             Show status information about the database
.dump ?TABLE?            Render database content as SQL
.echo on|off             Turn command echo on or off
.eqp on|off|full|...     Enable or disable automatic EXPLAIN QUERY PLAN
.excel                   Display the output of next command in spreadsheet
.exit ?CODE?             Exit this program with return-code CODE
.expert                  EXPERIMENTAL. Suggest indexes for queries
.explain ?on|off|auto?   Change the EXPLAIN formatting mode.  Default: auto
.filectrl CMD ...        Run various sqlite3_file_control() operations
.fullschema ?--indent?   Show schema and the content of sqlite_stat tables
.headers on|off          Turn display of headers on or off
.help ?-all? ?PATTERN?   Show help text for PATTERN
.import FILE TABLE       Import data from FILE into TABLE
.imposter INDEX TABLE    Create imposter table TABLE on index INDEX
.indexes ?TABLE?         Show names of indexes
.limit ?LIMIT? ?VAL?     Display or change the value of an SQLITE_LIMIT
.lint OPTIONS            Report potential schema issues.
.log FILE|off            Turn logging on or off.  FILE can be stderr/stdout
.mode MODE ?TABLE?       Set output mode
.nullvalue STRING        Use STRING in place of NULL values
.once ?OPTIONS? ?FILE?   Output for the next SQL command only to FILE
.open ?OPTIONS? ?FILE?   Close existing database and reopen FILE
.output ?FILE?           Send output to FILE or stdout if FILE is omitted
.parameter CMD ...       Manage SQL parameter bindings
.print STRING...         Print literal STRING
.progress N              Invoke progress handler after every N opcodes
.prompt MAIN CONTINUE    Replace the standard prompts
.quit                    Exit this program
.read FILE               Read input from FILE
.recover                 Recover as much data as possible from corrupt db.
.restore ?DB? FILE       Restore content of DB (default "main") from FILE
.save FILE               Write in-memory database into FILE
.scanstats on|off        Turn sqlite3_stmt_scanstatus() metrics on or off
.schema ?PATTERN?        Show the CREATE statements matching PATTERN
.selftest ?OPTIONS?      Run tests defined in the SELFTEST table
.separator COL ?ROW?     Change the column and row separators
.session ?NAME? CMD ...  Create or control sessions
.sha3sum ...             Compute a SHA3 hash of database content
.shell CMD ARGS...       Run CMD ARGS... in a system shell
.show                    Show the current values for various settings
.stats ?on|off?          Show stats or turn stats on or off
.system CMD ARGS...      Run CMD ARGS... in a system shell
.tables ?TABLE?          List names of tables matching LIKE pattern TABLE
.testcase NAME           Begin redirecting output to 'testcase-out.txt'
.testctrl CMD ...        Run various sqlite3_test_control() operations
.timeout MS              Try opening locked tables for MS milliseconds
.timer on|off            Turn SQL timer on or off
.trace ?OPTIONS?         Output each SQL statement as it is run
.vfsinfo ?AUX?           Information about the top-level VFS
.vfslist                 List all available VFSes
.vfsname ?AUX?           Print the name of the VFS stack
.width NUM1 NUM2 ...     Set column widths for "column" mode
sqlite> create table tbl1(one varchar(10), two smallint);
sqlite> show t
TABLE       TEMP        THEN        TO          TRIGGER    
tbl1        TEMPORARY   TIES        TRANSACTION two        
sqlite> show table;
Error: near "show": syntax error
sqlite> .tables
tbl1
sqlite> .tables tb
sqlite> .tables ?tb?
sqlite> ;
sqlite> .tables 
Display all 149 possibilities? (y or n) 
sqlite> .tables 
Display all 149 possibilities? (y or n) 
ABORT             CONSTRAINT        EXPLAIN           INTO              OUTER             TABLE            
ACTION            CREATE            FAIL              IS                OVER              tbl1             
ADD               CROSS             FILTER            ISNULL            PARTITION         TEMP             
AFTER             CURRENT           FIRST             JOIN              PLAN              TEMPORARY        
ALL               CURRENT_DATE      FOLLOWING         KEY               PRAGMA            THEN             
ALTER             CURRENT_TIME      FOR               LAST              PRECEDING         TIES             
ALWAYS            CURRENT_TIMESTAMP FOREIGN           LEFT              PRIMARY           TO               
ANALYZE           DATABASE          FROM              LIKE              QUERY             TRANSACTION      
AND               DEFAULT           FULL              LIMIT             RAISE             TRIGGER          
AS                DEFERRABLE        GENERATED         main              RANGE             two              
ASC               DEFERRED          GLOB              MATCH             RECURSIVE         UNBOUNDED        
ATTACH            DELETE            GROUP             NATURAL           REFERENCES        UNION            
AUTOINCREMENT     DESC              GROUPS            NO                REGEXP            UNIQUE           
BEFORE            DETACH            HAVING            NOT               REINDEX           UPDATE           
BEGIN             DISTINCT          IF                NOTHING           RELEASE           USING            
BETWEEN           DO                IGNORE            NOTNULL           RENAME            VACUUM           
BY                DROP              IMMEDIATE         NULL              REPLACE           VALUES           
CASCADE           EACH              IN                NULLS             RESTRICT          VIEW             
CASE              ELSE              INDEX             OF                RIGHT             VIRTUAL          
CAST              END               INDEXED           OFFSET            ROLLBACK          WHEN             
CHECK             ESCAPE            INITIALLY         ON                ROW               WHERE            
COLLATE           EXCEPT            INNER             one               ROWS              WINDOW           
COLUMN            EXCLUDE           INSERT            OR                SAVEPOINT         WITH             
COMMIT            EXCLUSIVE         INSTEAD           ORDER             SELECT            WITHOUT          
CONFLICT          EXISTS            INTERSECT         OTHERS            SET              
sqlite> .tables tbl1
tbl1
sqlite> .tables tbl
sqlite> .tables %tbl%
tbl1
sqlite> .tables %t%
tbl1
sqlite> insert into tbl1 values('hello!',10);
sqlite>  insert into tbl1 values('goodbye', 20);
sqlite>  insert into tbl1 values('goodbye', a);
Error: no such column: a
sqlite>  insert into tbl1 values('goodbye', 'a');
sqlite> select * from tbl1;
hello!|10
goodbye|20
goodbye|a
sqlite> ^D
homework1 $ ls
ex1
homework1 $ file ex1 
ex1: SQLite 3.x database, last written using SQLite version 3032003
homework1 $ 
```

```bash
homework1 $ wget https://15445.courses.cs.cmu.edu/fall2021/files/northwind-cmudb2021.db.gz
homework1 $ md5sum northwind-cmudb2021.db.gz
-bash: md5sum: command not found
homework1 $ md
md5         mdatopbm    mddiagnose  mdfind      mdimport    mdls        mdutil      
homework1 $ md5 northwind-cmudb2021.db.gz
MD5 (northwind-cmudb2021.db.gz) = f4fd955688d0dd9b5f4799d891f3f646
homework1 $ sqlite3 northwind-cmudb2021.db.gz 
SQLite version 3.32.3 2020-06-18 14:16:19
Enter ".help" for usage hints.
sqlite> .tables
Error: file is not a database
sqlite> ^D
homework1 $ gunzip northwind-cmudb2021.db.gz 
homework1 $ ls
ex1			northwind-cmudb2021.db	trying-out-sqlite3.md
homework1 $ file northwind-cmudb2021.db 
northwind-cmudb2021.db: SQLite 3.x database, last written using SQLite version 3008009
homework1 $ sqlite3 northwind-cmudb2021.db 
SQLite version 3.32.3 2020-06-18 14:16:19
Enter ".help" for usage hints.
sqlite> .tables
Category              EmployeeTerritory     Region              
Customer              Order                 Shipper             
CustomerCustomerDemo  OrderDetail           Supplier            
CustomerDemographic   Product               Territory           
Employee              ProductDetails_V    
sqlite> .schema Category
CREATE TABLE IF NOT EXISTS "Category" 
(
  "Id" INTEGER PRIMARY KEY, 
  "CategoryName" VARCHAR(8000) NULL, 
  "Description" VARCHAR(8000) NULL 
);
sqlite> select * from Category LIMIT 1;
1|Beverages|Soft drinks, coffees, teas, beers, and ales
sqlite> select count(*) from Category;
8
sqlite> select * from Category
Category     CategoryId   CategoryName
sqlite> select * from Category;
1|Beverages|Soft drinks, coffees, teas, beers, and ales
2|Condiments|Sweet and savory sauces, relishes, spreads, and seasonings
3|Confections|Desserts, candies, and sweet breads
4|Dairy Products|Cheeses
5|Grains/Cereals|Breads, crackers, pasta, and cereal
6|Meat/Poultry|Prepared meats
7|Produce|Dried fruit and bean curd
8|Seafood|Seaweed and fish
sqlite> .schema Customer
CREATE TABLE IF NOT EXISTS "Customer" 
(
  "Id" VARCHAR(8000) PRIMARY KEY, 
  "CompanyName" VARCHAR(8000) NULL, 
  "ContactName" VARCHAR(8000) NULL, 
  "ContactTitle" VARCHAR(8000) NULL, 
  "Address" VARCHAR(8000) NULL, 
  "City" VARCHAR(8000) NULL, 
  "Region" VARCHAR(8000) NULL, 
  "PostalCode" VARCHAR(8000) NULL, 
  "Country" VARCHAR(8000) NULL, 
  "Phone" VARCHAR(8000) NULL, 
  "Fax" VARCHAR(8000) NULL 
);
sqlite> select * from Customer LIMIT 1;
ALFKI|Alfreds Futterkiste|Maria Anders|Sales Representative|Obere Str. 57|Berlin|Western Europe|12209|Germany|030-0074321|030-0076545
sqlite> select * from Customer LIMIT 1;
Customer             CustomerDemographic  CustomerId          
CustomerCustomerDemo CustomerDesc         CustomerTypeId      
sqlite> 
```

```bash
sqlite> .schema Employee
CREATE TABLE IF NOT EXISTS "Employee" 
(
  "Id" INTEGER PRIMARY KEY, 
  "LastName" VARCHAR(8000) NULL, 
  "FirstName" VARCHAR(8000) NULL, 
  "Title" VARCHAR(8000) NULL, 
  "TitleOfCourtesy" VARCHAR(8000) NULL, 
  "BirthDate" VARCHAR(8000) NULL, 
  "HireDate" VARCHAR(8000) NULL, 
  "Address" VARCHAR(8000) NULL, 
  "City" VARCHAR(8000) NULL, 
  "Region" VARCHAR(8000) NULL, 
  "PostalCode" VARCHAR(8000) NULL, 
  "Country" VARCHAR(8000) NULL, 
  "HomePhone" VARCHAR(8000) NULL, 
  "Extension" VARCHAR(8000) NULL, 
  "Photo" BLOB NULL, 
  "Notes" VARCHAR(8000) NULL, 
  "ReportsTo" INTEGER NULL, 
  "PhotoPath" VARCHAR(8000) NULL 
);
sqlite> select * from Employee LIMIT 1;
1|Davolio|Nancy|Sales Representative|Ms.|1980-12-08|2024-05-01|507 - 20th Ave. E. Apt. 2A|Seattle|North America|98122|USA|(206) 555-9857|5467||Education includes a BA in psychology from Colorado State University in 1970.  She also completed 'The Art of the Cold Call.'  Nancy is a member of Toastmasters International.|2|http://accweb/emmployees/davolio.bmp
sqlite> .schema EmployeeTerritory 
CREATE TABLE IF NOT EXISTS "EmployeeTerritory" 
(
  "Id" VARCHAR(8000) PRIMARY KEY, 
  "EmployeeId" INTEGER NOT NULL, 
  "TerritoryId" VARCHAR(8000) NULL 
);
sqlite> select * from Employee LIMIT 1;
Employee          EmployeeId        EmployeeTerritory
sqlite> select * from EmployeeTerritory  LIMIT 1;
1/06897|1|06897
sqlite> select * from EmployeeTerritory  LIMIT 2;
1/06897|1|06897
1/19713|1|19713
sqlite> .schema Order
CREATE TABLE IF NOT EXISTS "Order" 
(
  "Id" INTEGER PRIMARY KEY, 
  "CustomerId" VARCHAR(8000) NULL, 
  "EmployeeId" INTEGER NOT NULL, 
  "OrderDate" VARCHAR(8000) NULL, 
  "RequiredDate" VARCHAR(8000) NULL, 
  "ShippedDate" VARCHAR(8000) NULL, 
  "ShipVia" INTEGER NULL, 
  "Freight" DECIMAL NOT NULL, 
  "ShipName" VARCHAR(8000) NULL, 
  "ShipAddress" VARCHAR(8000) NULL, 
  "ShipCity" VARCHAR(8000) NULL, 
  "ShipRegion" VARCHAR(8000) NULL, 
  "ShipPostalCode" VARCHAR(8000) NULL, 
  "ShipCountry" VARCHAR(8000) NULL 
);
sqlite> select * from Order  LIMIT 2;
Error: near "Order": syntax error
sqlite> select * from 'Order'  LIMIT 2;
10248|VINET|5|2012-07-04|2012-08-01|2012-07-16|3|16.75|Vins et alcools Chevalier|59 rue de l'Abbaye|Reims|Western Europe|51100|France
10249|TOMSP|6|2012-07-05|2012-08-16|2012-07-10|1|22.25|Toms Spezialitäten|Luisenstr. 48|Münster|Western Europe|44087|Germany
sqlite> .schema OrderDetail
CREATE TABLE IF NOT EXISTS "OrderDetail" 
(
  "Id" VARCHAR(8000) PRIMARY KEY, 
  "OrderId" INTEGER NOT NULL, 
  "ProductId" INTEGER NOT NULL, 
  "UnitPrice" DECIMAL NOT NULL, 
  "Quantity" INTEGER NOT NULL, 
  "Discount" DOUBLE NOT NULL 
);
sqlite> select * from 'OrderDetail'  LIMIT 2;
10248/11|10248|11|14|12|0.0
10248/42|10248|42|9.8|10|0.0
sqlite> .schema Product
CREATE TABLE IF NOT EXISTS "Product" 
(
  "Id" INTEGER PRIMARY KEY, 
  "ProductName" VARCHAR(8000) NULL, 
  "SupplierId" INTEGER NOT NULL, 
  "CategoryId" INTEGER NOT NULL, 
  "QuantityPerUnit" VARCHAR(8000) NULL, 
  "UnitPrice" DECIMAL NOT NULL, 
  "UnitsInStock" INTEGER NOT NULL, 
  "UnitsOnOrder" INTEGER NOT NULL, 
  "ReorderLevel" INTEGER NOT NULL, 
  "Discontinued" INTEGER NOT NULL 
);
sqlite> select * from 'Product'  LIMIT 2;
1|Chai|1|1|10 boxes x 20 bags|18|39|0|10|0
2|Chang|1|1|24 - 12 oz bottles|19|17|40|25|0
sqlite> .schema Region
CREATE TABLE IF NOT EXISTS "Region" 
(
  "Id" INTEGER PRIMARY KEY, 
  "RegionDescription" VARCHAR(8000) NULL 
);
sqlite> select * from 'Region'  LIMIT 2;
1|Eastern
2|Western
sqlite> .schema Shipper
CREATE TABLE IF NOT EXISTS "Shipper" 
(
  "Id" INTEGER PRIMARY KEY, 
  "CompanyName" VARCHAR(8000) NULL, 
  "Phone" VARCHAR(8000) NULL 
);
sqlite> select * from 'Ship'  LIMIT 2;
ShipAddress    ShipCountry    ShippedDate    ShipPostalCode ShipVia       
ShipCity       ShipName       Shipper        ShipRegion    
sqlite> select * from 'Shipper'  LIMIT 2;
1|Speedy Express|(503) 555-9831
2|United Package|(503) 555-3199
sqlite> .schema Supplier
CREATE TABLE IF NOT EXISTS "Supplier" 
(
  "Id" INTEGER PRIMARY KEY, 
  "CompanyName" VARCHAR(8000) NULL, 
  "ContactName" VARCHAR(8000) NULL, 
  "ContactTitle" VARCHAR(8000) NULL, 
  "Address" VARCHAR(8000) NULL, 
  "City" VARCHAR(8000) NULL, 
  "Region" VARCHAR(8000) NULL, 
  "PostalCode" VARCHAR(8000) NULL, 
  "Country" VARCHAR(8000) NULL, 
  "Phone" VARCHAR(8000) NULL, 
  "Fax" VARCHAR(8000) NULL, 
  "HomePage" VARCHAR(8000) NULL 
);
sqlite> select * from 'Supplier'  LIMIT 2;
1|Exotic Liquids|Charlotte Cooper|Purchasing Manager|49 Gilbert St.|London|British Isles|EC1 4SD|UK|(171) 555-2222||
2|New Orleans Cajun Delights|Shelley Burke|Order Administrator|P.O. Box 78934|New Orleans|North America|70117|USA|(100) 555-4822||#CAJUN.HTM#
sqlite> select * from 'Supplier'  LIMIT 2;
Supplier   SupplierId
sqlite> select * from 'Territory'  LIMIT 2;
01581|Westboro|1
01730|Bedford|1
sqlite> select * from 'Territory'  LIMIT 2;
Territory            TerritoryDescription TerritoryId         
sqlite> select * from 'Territory^E LIMIT 2;

01581|Westboro|1
01730|Bedford|1
sqlite> .schema Territory
CREATE TABLE IF NOT EXISTS "Territory" 
(
  "Id" VARCHAR(8000) PRIMARY KEY, 
  "TerritoryDescription" VARCHAR(8000) NULL, 
  "RegionId" INTEGER NOT NULL 
);
sqlite> select count(*) from 'Order';
16818
sqlite> 
```

----

Q1. List all Category Names ordered alphabetically. 

```
sqlite> .schema Category
CREATE TABLE IF NOT EXISTS "Category" 
(
  "Id" INTEGER PRIMARY KEY, 
  "CategoryName" VARCHAR(8000) NULL, 
  "Description" VARCHAR(8000) NULL 
);
sqlite> SELECT CategoryName from Category ORDER BY CategoryName ASC;
Beverages
Condiments
Confections
Dairy Products
Grains/Cereals
Meat/Poultry
Produce
Seafood
sqlite> SELECT CategoryName from Category ORDER BY CategoryName;
Beverages
Condiments
Confections
Dairy Products
Grains/Cereals
Meat/Poultry
Produce
Seafood
sqlite> 
```

---

Q2. Get all unique ShipNames from the Order table that contain a hyphen '-'.

Details: In addition, get all the characters preceding the (first) hyphen. Return ship names alphabetically. Your first row should look like Bottom-Dollar Markets|Bottom 

```bash
sqlite> .schema Order
CREATE TABLE IF NOT EXISTS "Order" 
(
  "Id" INTEGER PRIMARY KEY, 
  "CustomerId" VARCHAR(8000) NULL, 
  "EmployeeId" INTEGER NOT NULL, 
  "OrderDate" VARCHAR(8000) NULL, 
  "RequiredDate" VARCHAR(8000) NULL, 
  "ShippedDate" VARCHAR(8000) NULL, 
  "ShipVia" INTEGER NULL, 
  "Freight" DECIMAL NOT NULL, 
  "ShipName" VARCHAR(8000) NULL, 
  "ShipAddress" VARCHAR(8000) NULL, 
  "ShipCity" VARCHAR(8000) NULL, 
  "ShipRegion" VARCHAR(8000) NULL, 
  "ShipPostalCode" VARCHAR(8000) NULL, 
  "ShipCountry" VARCHAR(8000) NULL 
);
sqlite> SELECT ShipName from O
OF          ON          ORDER       OrderDetail OTHERS      OVER       
OFFSET      OR          OrderDate   OrderId     OUTER      
sqlite> SELECT ShipName from 'Order' LIMIT 5;
Vins et alcools Chevalier
Toms Spezialitäten
Hanari Carnes
Victuailles en stock
Suprêmes délices
sqlite> SELECT ShipName from 'Order' WHERE ShipName LIKE '%-%' LIMIT 5;
Chop-suey Chinese
HILARION-Abastos
GROSELLA-Restaurante
QUICK-Stop
LILA-Supermercado
sqlite> SELECT ShipName from 'Order' WHERE ShipName LIKE '%-%' ORDER BY ShipName LIMIT 5;
Bottom-Dollar Markets
Bottom-Dollar Markets
Bottom-Dollar Markets
Bottom-Dollar Markets
Bottom-Dollar Markets
sqlite> SELECT DISTINCT ShipName from 'Order' WHERE ShipName LIKE '%-%' ORDER BY ShipName LIMIT 5;
Bottom-Dollar Markets
Chop-suey Chinese
GROSELLA-Restaurante
HILARION-Abastos
Hungry Owl All-Night Grocers
sqlite> 
```
