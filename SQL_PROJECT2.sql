--  Table Creation

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
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
DROP TABLE IF EXISTS books;
CREATE TABLE books
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
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
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


--  Create a New Book Record 

INSERT INTO book_data(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'Vampire Diaries', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM book_data;


--  Update an Existing Employee's Position

UPDATE emp
SET position = 'Assistant'
WHERE emp_id = 'E102';


--   Delete a Record from the Issued Status Table

DELETE FROM issue
WHERE   issued_id =   'IS121';


--  List Members Who Have Issued More Than One Book

SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1


--   CTAS (Create Table As Select)

CREATE TABLE emp_manager AS
SELECT manager_id,emp_id,position AS emp_position
FROM emp
INNER JOIN branch
ON emp.branch_id=branch.branch_id


--  Data Analysis & Findings
--  Find Total Rental Income by Category

SELECT category,SUM(book_data.rental_price),COUNT(*)
FROM issue 
JOIN book_data
ON book_data.isbn = issue.issued_book_isbn
GROUP BY 1


--  List Members Who Registered in the Last 500 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '500 DAY';



--  List Employees with Their Branch Manager's ID and their position

SELECT*FROM emp_manager


--   Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books AS
SELECT * FROM book_data
WHERE rental_price > 7.00


--  Retrieve the List of Books Not Yet Returned

SELECT * FROM issue AS ist
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;


--   Identify Members with Overdue Books and count the Days of Overdue

SELECT DISTINCT member_id,CURRENT_DATE-issued_date AS overdue_days FROM issue AS ist
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL
AND issued_date< CURRENT_DATE - INTERVAL'30 DAY'


--  Update Book Status on Return

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


--  CTAS for Convenience

CREATE TABLE book_status AS
SELECT issued_id,isbn,status
FROM book_data
INNER JOIN issue 
ON issue.issued_book_isbn=book_data.isbn



--  Creating Procedure for Updating Status

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


--  Branch Performance Report
--  Create a query that generates a performance report for each branch
--  showing the number of books issued and the total revenue generated from book rentals


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


--  Create a Table of Active Members
--  Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
--  containing members who have issued at least one book in the last 2 months


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

--  Write a CTAS query to create a new table that lists each member and 
--  the books they have issued but not returned within 30 days. 
--  The table should include The number of overdue Days
--  The total fines, with each day's fine calculated at $0.10.& Member name

SELECT DISTINCT members.member_id,member_name,CURRENT_DATE-issued_date AS overdue_days,(CURRENT_DATE-issued_date)*0.1
AS fine
FROM issue 
LEFT JOIN return_status 
ON return_status.issued_id = issue.issued_id
INNER JOIN members
ON members.member_id=issue.member_id
WHERE return_status.return_id IS NULL
AND issued_date< CURRENT_DATE - INTERVAL'30 DAY'

























