drop database EmployeeMS;
create database EmployeeMS;
use EmployeeMS;
-- Table 1: Job Department

CREATE TABLE JobDepartment (
    Job_ID INT PRIMARY KEY,
    jobdept VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    salaryrange VARCHAR(50)
);
select * from JobDepartment;
-- Table 2: Salary/Bonus
CREATE TABLE SalaryBonus (
    salary_ID INT PRIMARY KEY,
    Job_ID INT,
    amount DECIMAL(10,2),
    annual DECIMAL(10,2),
    bonus DECIMAL(10,2),
    CONSTRAINT fk_salary_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(Job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from salarybonus;
-- Table 3: Employee

CREATE TABLE Employee (
    emp_ID INT PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    gender VARCHAR(10),
    age INT,
    contact_add VARCHAR(100),
    emp_email VARCHAR(100) UNIQUE,
    emp_pass VARCHAR(50),
    Job_ID INT,
    CONSTRAINT fk_employee_job FOREIGN KEY (Job_ID)
  REFERENCES JobDepartment(Job_ID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
select * from employee;
-- Table 4: Qualification
CREATE TABLE Qualification (
    QualID INT PRIMARY KEY,
    Emp_ID INT,
    Position VARCHAR(50),
    Requirements VARCHAR(255),
    Date_In DATE,
    CONSTRAINT fk_qualification_emp FOREIGN KEY (Emp_ID)
        REFERENCES Employee(emp_ID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
select * from qualification;

-- Table 5: Leaves
CREATE TABLE Leaves (
    leave_ID INT PRIMARY KEY,
    emp_ID INT,
    date DATE,
    reason TEXT,
    CONSTRAINT fk_leave_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE
);
select * from leaves;

-- Table 6: Payroll
CREATE TABLE Payroll (
    payroll_ID INT PRIMARY KEY,
    emp_ID INT,
    job_ID INT,
    salary_ID INT,
    leave_ID INT,
    date DATE,
    report TEXT,
    total_amount DECIMAL(10,2),
    CONSTRAINT fk_payroll_emp FOREIGN KEY (emp_ID) REFERENCES Employee(emp_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_job FOREIGN KEY (job_ID) REFERENCES JobDepartment(job_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_salary FOREIGN KEY (salary_ID) REFERENCES SalaryBonus(salary_ID)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_payroll_leave FOREIGN KEY (leave_ID) REFERENCES Leaves(leave_ID)
        ON DELETE SET NULL ON UPDATE CASCADE
);
select * from payroll;

-- Analysis Questions
-- 1 . EMPLOYEE INSIGHTS
-- How many unique employees are currently in the system?
SELECT COUNT(*) AS total_employees
FROM Employee;


-- Which departments have the highest number of employees?
SELECT 
    jd.jobdept AS department,
    COUNT(e.emp_ID) AS employee_count
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
GROUP BY jd.jobdept
ORDER BY employee_count DESC;

select * from jobdepartment;
select * from employee;
select jd.jobdept,count(e.emp_id)
from jobdepartment as jd
join employee as e
on jd.job_id = e.job_id
group by jd.jobdept
order by count(e.emp_id) desc;


-- What is the average salary per department?

select* from jobdepartment;
select * from salarybonus;

select
jd.jobdept , avg(amount)
from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jd.jobdept;


SELECT 
    jd.jobdept AS department,
    ROUND(AVG(sb.amount), 2) AS avg_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept;


-- Who are the top 5 highest-paid employees?
select * from employee;
select * from salarybonus;


select emp_id, amount
from employee 
join salarybonus 
on employee.job_id =salarybonus.job_id
order by amount  desc 
limit 5;

-- What is the total salary expenditure across the company?
select sum(amount)  as total_salary_expenditure
from salarybonus;


-- 2. JOB ROLE AND DEPARTMENT ANALYSIS

-- How many different job roles exist in each department?
select * from jobdepartment;
select jobdept, count(job_id) as job_roles
from jobdepartment
group by jobdept; 


-- What is the average salary range per department?
select * from jobdepartment;

select jobdept , avg(amount) as average_salary_range, min(amount) as minimum_salary ,
 max(amount) as maximum_salary , max(amount)-min(amount) as salary_range
from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jobdept
order by salary_range desc;


-- Which job roles offer the highest salary?
select * from jobdepartment;
select jobdept as job_role , amount as highest_salary 
from jobdepartment as jd
join  salarybonus as sb
on jd.job_id = sb.job_id
order by sb.amount desc 
limit 1;

SELECT jd.name AS job_role, sb.amount AS salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
ORDER BY sb.amount DESC;


-- Which departments have the highest total salary allocation?
select * from jobdepartment;
select * from salarybonus;

select jd.jobdept,sum(sb.amount)
from jobdepartment as jd
join salarybonus as sb
on jd.job_id=sb.job_id
group by jd.jobdept
order by sum(sb.amount) desc;



SELECT jd.jobdept AS department, SUM(sb.amount) AS total_salary
FROM JobDepartment jd
JOIN SalaryBonus sb ON jd.Job_ID = sb.Job_ID
GROUP BY jd.jobdept
ORDER BY total_salary DESC;



-- 3. QUALIFICATION AND SKILLS ANALYSIS

-- How many employees have at least one qualification listed?
select * from qualification;
select * from salarybonus;

SELECT r.requirements, SUM(e.emp_id) AS qualification
FROM employee as e 
JOIN qualification as r on e.emp_id = r.emp_id
GROUP BY r.requirements;


-- Which positions require the most qualifications?
SELECT Position,COUNT(*) AS qualification_count
FROM Qualification
GROUP BY Position
ORDER BY qualification_count DESC;


-- Which employees have the highest number of qualifications?
select * from qualification;
SELECT CONCAT(e.firstname,' ',e.lastname) AS employee_name, COUNT(q.QualID) AS total_qualifications
FROM Employee e
JOIN Qualification q ON e.emp_ID = q.Emp_ID
GROUP BY e.emp_ID  
ORDER BY total_qualifications DESC;



-- 4. LEAVE AND ABSENCE PATTERNS

-- Which year had the most employees taking leaves?
select * from leaves;
SELECT YEAR(date) AS year,COUNT(*) AS total_leaves
FROM Leaves
GROUP BY YEAR(date)
ORDER BY total_leaves DESC;


-- What is the average number of leave days taken by its employees per department?
SELECT jd.jobdept AS department,ROUND(COUNT(l.leave_ID) / COUNT(DISTINCT e.emp_ID), 2) AS avg_leave_days
FROM Employee e
JOIN JobDepartment jd ON e.Job_ID = jd.Job_ID
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY jd.jobdept;


-- Which employees have taken the most leaves?
SELECT CONCAT(e.firstname,' ',e.lastname) AS employee_name, COUNT(l.leave_ID) AS leave_count
FROM Employee e
JOIN Leaves l ON e.emp_ID = l.emp_ID
GROUP BY e.emp_ID
ORDER BY leave_count DESC;


-- What is the total number of leave days taken company-wide?
SELECT COUNT(*) AS total_leave_days
FROM Leaves;


-- How do leave days correlate with payroll amounts?
SELECT e.emp_ID,COUNT(l.leave_ID) AS leave_count,SUM(p.total_amount) AS total_payroll
FROM Employee e
LEFT JOIN Leaves l ON e.emp_ID = l.emp_ID
LEFT JOIN Payroll p ON e.emp_ID = p.emp_ID
GROUP BY e.emp_ID;


-- 5. PAYROLL AND COMPENSATION ANALYSIS
-- What is the total monthly payroll processed?
select * from payroll;
SELECT SUM(total_amount) AS total_payroll
FROM Payroll;


-- What is the average bonus given per department?
select * from jobdepartment;
select * from salarybonus;


select jd.jobdept , avg(sb.bonus)
from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jd.jobdept;


-- Which department receives the highest total bonuses?

select jd.jobdept , sum(sb.bonus) as total_bonus
from jobdepartment as jd
join salarybonus as sb
on jd.job_id = sb.job_id
group by jd.jobdept
order by sum(sb.bonus) desc
limit 1;


-- What is the average value of total_amount after considering leave deductions?
select * from leaves;
select * from employee;
select * from payroll;


select l.leave_id , avg(p.total_amount)
from leaves as l
join payroll as p
on l.leave_id = p.leave_id
group by l.leave_id;







