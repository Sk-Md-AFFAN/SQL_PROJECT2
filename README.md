# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/Sk-Md-AFFAN/SQL_PROJECT2/blob/main/library_transaction.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "employee"
DROP TABLE IF EXISTS emp;
CREATE TABLE emp
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS book_data;
CREATE TABLE book_data
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issue;
CREATE TABLE issue
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `book_data` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `emp` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'Vampire Diaries', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'Vampire Diaries', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Employee's Position**

```sql
UPDATE emp
SET position = 'Assistant'
WHERE emp_id = 'E102';

```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: List Members Who Have Issued More Than One Book**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1

```
### 3. CTAS (Create Table As Select)

**Task 5: CTAS (Create Table As Select)**

```sql
CREATE TABLE emp_manager AS
SELECT manager_id,emp_id,position AS emp_position
FROM emp
INNER JOIN branch
ON emp.branch_id=branch.branch_id

```

### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

6. **Task 6: Find Total Rental Income by Category**:

```sql
SELECT category,SUM(book_data.rental_price),COUNT(*)
FROM issue 
JOIN book_data
ON book_data.isbn = issue.issued_book_isbn
GROUP BY 1

```

7. **List Members Who Registered in the Last 500 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '500 DAY';

```

8. **List Employees with Their Branch Manager's ID and their position**:

```sql
SELECT*FROM emp_manager 
```

Task 9. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM book_data
WHERE rental_price > 7.00

```

Task 10: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issue AS ist
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

```

## Advanced SQL Operations

**Task 11: Identify Members with Overdue Books**  
Identify Members with Overdue Books and count the Days of Overdue

```sql
SELECT DISTINCT member_id,CURRENT_DATE-issued_date AS overdue_days FROM issue AS ist
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL
AND issued_date< CURRENT_DATE - INTERVAL'30 DAY'

```


**Task 12: Update Book Status on Return**  

```sql

UPDATE book_data
SET status = 'No'
WHERE book_title IN (
   SELECT issued_book_name FROM issue
   LEFT JOIN return_status
   ON issue.issued_id=return_status.issued_id
   WHERE return_id IS NULL 
);
UPDATE book_data
SET status = 'Yes'
WHERE book_title IN (
       SELECT issued_book_name FROM issue
   LEFT JOIN return_status
   ON issue.issued_id=return_status.issued_id
   WHERE return_id IS NOT NULL 
);
UPDATE book_data
SET status = 'Yes'
WHERE book_title IN (
       SELECT book_title FROM book_data
   LEFT JOIN issue
   ON issue.issued_book_name=book_data.book_title
   WHERE issue.issued_id IS NULL
);


--  Testing

SELECT*FROM book_data
WHERE isbn='978-0-451-52994-2'

INSERT INTO return_status(return_id,issued_id,return_book_name,return_date,return_book_isbn)
VALUES('R125','IS130','Herman Melville',CURRENT_DATE,'978-0-451-52994-2')

```



**Task 13: Creating Procedure for Updating Status**  

```sql
CREATE PROCEDURE status_update(p_return_id VARCHAR(10),p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO return_status(return_id,issued_id,return_date)
	VALUES(p_return_id,p_issued_id,CURRENT_DATE);

    UPDATE book_data
    SET status = 'No'
    WHERE book_title IN (
    SELECT issued_book_name FROM issue
    LEFT JOIN return_status
    ON issue.issued_id=return_status.issued_id
    WHERE return_id IS NULL );
                           
    UPDATE book_data
    SET status = 'Yes'
    WHERE book_title IN (
       SELECT issued_book_name FROM issue
   LEFT JOIN return_status
   ON issue.issued_id=return_status.issued_id
   WHERE return_id IS NOT NULL );

	-- The code below prevents any error as a non_issued book may be given
	-- the status of unavailable i.e(no)
	
    UPDATE book_data
    SET status = 'Yes'
    WHERE book_title IN (
       SELECT book_title FROM book_data
   LEFT JOIN issue
   ON issue.issued_book_name=book_data.book_title
   WHERE issue.issued_id IS NULL);

   RAISE NOTICE 'Thank you for returning the book';

END;
$$


-- Testing Function

CALL status_update('R126','IS128')

SELECT*FROM book_status
WHERE issued_id='IS128'


SELECT * FROM branch_reports;
```

**Task 14: Branch Performance Report**
--  Create a query that generates a performance report for each branch
--  showing the number of books issued and the total revenue generated from book rentals  


```sql

SELECT branch.branch_id,COUNT(issue.issued_id) AS books_issued,
SUM(
CASE
WHEN issue.issued_id IS NOT NULL THEN book_data.rental_price
ELSE 0
END
) AS revenue
FROM book_data
INNER JOIN issue
ON book_data.isbn=issue.issued_book_isbn
INNER JOIN emp
ON issue.issued_emp_id=emp.emp_id
LEFT JOIN branch
ON emp.branch_id=branch.branch_id
GROUP BY branch.branch_id


```


**Task 15: 
--  Create a Table of Active Members** 
--  Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
--  containing members who have issued at least one book in the last 2 months

```sql
CREATE TABLE active_members AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT member_id   
                    FROM issue
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )

SELECT * FROM active_members


--  Find Employees with the Most Book Issues Processed
--  Display the employee name, number of books processed, and their branch
--  Find the top 3 employees

SELECT   emp_name,emp.branch_id,
COUNT(issue.issued_id) AS no_book_issued
FROM issue 
JOIN emp
ON emp.emp_id = issue.issued_emp_id
JOIN branch 
ON emp.branch_id = branch.branch_id
GROUP BY 1, 2

```

**Task 16: Write a CTAS query to create a new table that lists each member and** 
--  the books they have issued but not returned within 30 days. 
--  The table should include The number of overdue Days
--  The total fines, with each day's fine calculated at $0.10.& Member name     


```sql

SELECT DISTINCT members.member_id,member_name,CURRENT_DATE-issued_date AS overdue_days,(CURRENT_DATE-issued_date)*0.1
AS fine
FROM issue 
LEFT JOIN return_status 
ON return_status.issued_id = issue.issued_id
INNER JOIN members
ON members.member_id=issue.member_id
WHERE return_status.return_id IS NULL
AND issued_date< CURRENT_DATE - INTERVAL'30 DAY'


```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/najirh/Library-System-Management---P2.git
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Sk Md Affan

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:

**Thank you for your interest in this project!**
