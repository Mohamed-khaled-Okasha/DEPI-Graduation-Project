------------------------------------ Which Department Has The Highest Attrition Rate
SELECT Department, SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as AttritionCount
FROM EmployeeDim
GROUP BY Department
ORDER BY AttritionCount DESC;
-----------------------------------------------------------------
------------------------------------ Relationship Between JobRole and Avg Job Satisfaction Per Department --
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.JobSatisfactionID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Date DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date  
)
SELECT 
    e.JobRole,
    e.Department,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    e.JobRole, 
    e.Department
ORDER BY 
    e.Department, 
    e.JobRole;

----------------------------------------------------------- Relationship Between Avgsalary and AvgSelfRating Per Department
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    e.Department,
    AVG(e.Salary) AS AvgSalary,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    e.Department
ORDER BY 
    AvgSalary DESC;

------------------------------------------------------------ How Many Training Opportonities Taken By Employees Per EducationLevel?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.TrainingOpportunitiesTaken,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    e.Education,
    AVG(CAST(lr.TrainingOpportunitiesTaken AS FLOAT)) AS AvgTrainingTaken,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    e.Education
ORDER BY 
    e.Education;

----------------------------------------------------------------- What Is The Average Salary Per Education Level and Number Of Employees For Each Level?
SELECT 
    e.Education,
    AVG(e.Salary) AS AvgSalary,
    COUNT(*) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
GROUP BY 
    e.Education
ORDER BY 
    e.Education;

----------------------------------------------------------------- What Is The Average Self rating Per Age Group?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    CASE 
        WHEN e.Age < 25 THEN 'Under 25'
        WHEN e.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN e.Age BETWEEN 35 AND 44 THEN '35-44'
        ELSE '45 and above'
    END AS AgeGroup,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    CASE 
        WHEN e.Age < 25 THEN 'Under 25'
        WHEN e.Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN e.Age BETWEEN 35 AND 44 THEN '35-44'
        ELSE '45 and above'
    END
ORDER BY 
    AgeGroup;

----------------------------------------------------------------------- marital status & attrition count
SELECT MaritalStatus, SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) as AttritionCount
FROM EmployeeDim
GROUP BY MaritalStatus
ORDER BY AttritionCount DESC;


------------------------------------ Does Distance From Home Affect Attrition?
SELECT 
    CASE 
        WHEN e.DistanceFromHome <= 10 THEN '0-10 miles'
        WHEN e.DistanceFromHome <= 20 THEN '11-20 miles'
        WHEN e.DistanceFromHome <= 30 THEN '21-30 miles'
        ELSE 'Over 30 miles'
    END AS DistanceGroup,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount,
    COUNT(*) AS TotalEmployees,
    (COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*)) AS AttritionRate
FROM 
    EmployeeDim e
GROUP BY 
    CASE 
        WHEN e.DistanceFromHome <= 10 THEN '0-10 miles'
        WHEN e.DistanceFromHome <= 20 THEN '11-20 miles'
        WHEN e.DistanceFromHome <= 30 THEN '21-30 miles'
        ELSE 'Over 30 miles'
    END
ORDER BY 
    DistanceGroup;

------------------------------------ How Does BusinessTravel Affect Job Satisfaction and Attrition?
SELECT TravelGroup,
       SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount
FROM (
    SELECT e.EmployeeID, e.BusinessTravel as TravelGroup,
           e.Attrition
    FROM EmployeeDim e
    JOIN PerformanceRatingFact p ON e.EmployeeID = p.EmployeeID
    GROUP BY e.EmployeeID, e.BusinessTravel, e.Attrition
) as tbl
GROUP BY TravelGroup
ORDER BY TravelGroup;

------------------------------------------------------------- How Does State Affect Attrition? {Illinois - New York - California}
SELECT 
    e.State,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount,
    COUNT(*) AS TotalEmployees,
    (COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*)) AS AttritionRate
FROM 
    EmployeeDim e
GROUP BY 
    e.State
ORDER BY 
    AttritionRate DESC;

---------------------------------------------------------------- How Does Promotion Affect Attrition?
SELECT 
    CASE 
        WHEN e.YearsSinceLastPromotion = 0 THEN 'promoted this year'
        WHEN e.YearsSinceLastPromotion <= 2 THEN '1-2 years ago'
        ELSE 'more than 2 years'
    END AS PromotionGroup,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount,
    COUNT(*) AS TotalEmployees,
    (COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*)) AS AttritionRate
FROM 
    EmployeeDim e
GROUP BY 
    CASE 
        WHEN e.YearsSinceLastPromotion = 0 THEN 'promoted this year'
        WHEN e.YearsSinceLastPromotion <= 2 THEN '1-2 years ago'
        ELSE 'more than 2 years'
    END
ORDER BY 
    PromotionGroup;

--------------------------------------------------------------- How Does Satisfaction Affect Attrition?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.JobSatisfactionID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    CASE 
        WHEN lr.JobSatisfactionID = 1 THEN 'Very Dissatisfied'
        WHEN lr.JobSatisfactionID = 2 THEN 'Dissatisfied'
        WHEN lr.JobSatisfactionID = 3 THEN 'Neutral'
        WHEN lr.JobSatisfactionID = 4 THEN 'Satisfied'
        WHEN lr.JobSatisfactionID = 5 THEN 'Very Satisfied'
    END AS SatisfactionLevel,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount,
    COUNT(DISTINCT e.EmployeeID) AS TotalEmployees,
    (COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(DISTINCT e.EmployeeID)) AS AttritionRate
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    lr.JobSatisfactionID
ORDER BY 
    lr.JobSatisfactionID;

--------------------------------------------------------------------- How Does JobRole Affect Work-Life Balance?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.WorkLifeBalanceID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    e.JobRole,
    CASE 
        WHEN s.SatisfactionID = 1 THEN 'Very Dissatisfied'
        WHEN s.SatisfactionID = 2 THEN 'Dissatisfied'
        WHEN s.SatisfactionID = 3 THEN 'Neutral'
        WHEN s.SatisfactionID = 4 THEN 'Satisfied'
        WHEN s.SatisfactionID = 5 THEN 'Very Satisfied'
    END AS WorkLifeBalanceLevel,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
JOIN 
    SatisfactionDim s ON lr.WorkLifeBalanceID = s.SatisfactionID
WHERE 
    lr.rn = 1
GROUP BY 
    e.JobRole,
    s.SatisfactionID
ORDER BY 
    e.JobRole, 
    s.SatisfactionID;

------------------------------------------------------------------------------- Deos Employee Salary Affect attrition count
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    CASE 
        WHEN e.Salary < 50000 THEN 'Under 50K'
        WHEN e.Salary BETWEEN 50000 AND 100000 THEN '50K-100K'
        WHEN e.Salary BETWEEN 100001 AND 150000 THEN '100K-150K'
        ELSE 'Over 150K'
    END AS SalaryRange,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    CASE 
        WHEN e.Salary < 50000 THEN 'Under 50K'
        WHEN e.Salary BETWEEN 50000 AND 100000 THEN '50K-100K'
        WHEN e.Salary BETWEEN 100001 AND 150000 THEN '100K-150K'
        ELSE 'Over 150K'
    END 
ORDER BY 
    SalaryRange;

--------------------------------------------------------------------- Does Married Employees Tend To Take More Training Opportunities Than Singles?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.TrainingOpportunitiesTaken,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    e.MaritalStatus,
    SUM(lr.TrainingOpportunitiesTaken) AS TotalTrainingTaken,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    e.MaritalStatus
ORDER BY 
    TotalTrainingTaken DESC;

----------------------------------------------------------------------- Does Ethnicity Affect Employee's Self Rating?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.SelfRatingID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    e.Ethnicity,
    CASE 
        WHEN lr.SelfRatingID = 1 THEN 'Poor'
        WHEN lr.SelfRatingID = 2 THEN 'Satisfactory'
        WHEN lr.SelfRatingID = 3 THEN 'Good'
        WHEN lr.SelfRatingID = 4 THEN 'Very Good'
        WHEN lr.SelfRatingID = 5 THEN 'Excellent'
    END AS SelfRatingLevel,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    e.Ethnicity,
    lr.SelfRatingID
ORDER BY 
    e.Ethnicity,
    lr.SelfRatingID;

------------------------------------ Does Job Satisfaction Relates To Opportunities Provided?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.JobSatisfactionID,
        p.TrainingOpportunitiesWithinYear,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    lr.JobSatisfactionID AS JobSatisfaction,
    SUM(lr.TrainingOpportunitiesWithinYear) AS TotalTrainingOpportunities,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    lr.JobSatisfactionID
ORDER BY 
    lr.JobSatisfactionID;

------------------------------------ Are Employees With High Stock Option Level Tend To Be More Satisfied In The Job?
WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        p.JobSatisfactionID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
        PerformanceRatingFact p
    JOIN 
        TimeDim t ON p.ReviewDate = t.Date
)
SELECT 
    e.StockOptionLevel,
    CASE 
        WHEN lr.JobSatisfactionID = 1 THEN 'Very Dissatisfied'
        WHEN lr.JobSatisfactionID = 2 THEN 'Dissatisfied'
        WHEN lr.JobSatisfactionID = 3 THEN 'Neutral'
        WHEN lr.JobSatisfactionID = 4 THEN 'Satisfied'
        WHEN lr.JobSatisfactionID = 5 THEN 'Very Satisfied'
    END AS JobSatisfactionLevel,
    COUNT(DISTINCT e.EmployeeID) AS EmployeeCount,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1
GROUP BY 
    e.StockOptionLevel,
    lr.JobSatisfactionID
ORDER BY 
    e.StockOptionLevel,
    lr.JobSatisfactionID;
-------------------------------------------------------------التأكد من عدد الموظفين

WITH LatestRating AS (
    SELECT 
        p.EmployeeID,
        ROW_NUMBER() OVER (PARTITION BY p.EmployeeID ORDER BY t.Year DESC) AS rn
    FROM 
       PerformanceRatingFact p
    JOIN 
        timedim t ON p.ReviewDate = t.Date
)
SELECT 
    COUNT(DISTINCT e.EmployeeID) AS TotalEmployees,
    COUNT(CASE WHEN e.Attrition = 'Yes' THEN 1 END) AS AttritionCount
FROM 
    EmployeeDim e
JOIN 
    LatestRating lr ON e.EmployeeID = lr.EmployeeID
WHERE 
    lr.rn = 1;
-----------------------------------------------------
select count(distinct EmployeeID) 
from EmployeeDim;

select count(distinct EmployeeID) 
from performanceratingfact p ;
---------------------------------------- بيانات عن الموظفين اللي متقيموش
SELECT 
    e.*
FROM 
    EmployeeDim e
LEFT JOIN 
    performanceratingfact p ON e.EmployeeID = p.EmployeeID
WHERE 
    p.EmployeeID IS NULL
order by HireDate asc;
----------------------------------------------------عدد الموظفين في 2013
SELECT 
    COUNT(DISTINCT e.EmployeeID) AS Total_Employees
FROM EmployeeDim e
JOIN PerformanceRatingFact p 
ON e.EmployeeID = p.EmployeeID
WHERE YEAR(p.ReviewDate) = 2013;

----------------------------------------------- عدد الموظفين اللي عملو اتيريشن في 2013

SELECT 
    COUNT(DISTINCT e.EmployeeID) AS Attrition_Count_2013
FROM EmployeeDim e
JOIN PerformanceRatingFact p 
ON e.EmployeeID = p.EmployeeID
WHERE YEAR(p.ReviewDate) = 2013
AND e.Attrition = 'Yes';
---------------------------------------------------التواريخ اللي الموظفين مشيوا فيها
SELECT 
    EmployeeID,
    HireDate,
    CASE 
        WHEN Attrition = 'Yes' 
        THEN DATE_ADD(HireDate, INTERVAL YearsAtCompany year)
        ELSE NULL
    END AS LeaveDate
FROM EmployeeDim;
---------------------------------------------------------------------------وقت التقييم مقارنة بالوقت اللي كان فيه في الشركة(دول ال6600 موظف)
SELECT 
    p.EmployeeID,
    p.ReviewDate,
    p.EnvironmentSatisfactionID ,
    e.HireDate,
    CASE 
        WHEN e.Attrition = 'Yes' 
        THEN DATE_ADD(e.HireDate, INTERVAL e.YearsAtCompany YEAR)
        ELSE NULL
    END AS LeaveDate
FROM PerformanceRatingFact p
JOIN EmployeeDim e ON p.EmployeeID = e.EmployeeID
WHERE 
    p.ReviewDate >= e.HireDate
    AND (
        (e.Attrition like 'Yes' AND p.ReviewDate <= DATE_ADD(e.HireDate, INTERVAL e.YearsAtCompany YEAR))
        OR 
        (e.Attrition like 'No' AND p.ReviewDate <= CURRENT_DATE)
    );

-------------------------------------------عدد الموظفين اللي اتقيموا واصحاب تقييمات حقيقية
SELECT 
    COUNT(PerformanceID) AS Total_Ratings
FROM PerformanceRatingFact p
JOIN EmployeeDim e 
ON p.EmployeeID = e.EmployeeID
WHERE 
    p.ReviewDate >= e.HireDate
    AND (
        (e.Attrition like 'yes' AND p.ReviewDate <= DATE_ADD(e.HireDate, INTERVAL e.YearsAtCompany YEAR))
        OR 
        (e.Attrition like 'No' AND p.ReviewDate <= CURRENT_DATE)
    );
----------------------------------------------------------------(تقييم حقيقي )عدد الموظفين اللي اتقيموا للتقييم الواحد
SELECT 
    p.SelfRatingID ,
    COUNT(*) AS TotalRatings
FROM PerformanceRatingFact p
JOIN EmployeeDim e ON p.EmployeeID = e.EmployeeID
WHERE 
    p.JobSatisfactionID IS NOT NULL
    AND p.ReviewDate >= e.HireDate
    AND (
        (e.Attrition like 'yes' AND p.ReviewDate <= DATE_ADD(e.HireDate, INTERVAL e.YearsAtCompany YEAR))
        OR 
        (e.Attrition like 'no' AND p.ReviewDate <= CURRENT_DATE)
    )
GROUP BY p.SelfRatingID  ;
-----------------------------------------------exclude all fake ratingsss

DELETE p
FROM PerformanceRatingFact p
JOIN EmployeeDim e 
ON p.EmployeeID = e.EmployeeID
WHERE NOT (
    p.ReviewDate >= e.HireDate
    AND (
        (e.Attrition LIKE 'Yes' AND p.ReviewDate <= DATE_ADD(e.HireDate, INTERVAL e.YearsAtCompany YEAR))
        OR 
        (e.Attrition LIKE 'No' AND p.ReviewDate <= CURRENT_DATE)
    )
);
-------------------------------------------making sure
select count(PerformanceID)
from PerformanceRatingFact;
