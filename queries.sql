CREATE SCHEMA pandemic;
USE pandemic;

-- Task 1
-- Normalization(Entity and Code)
-- Create table
CREATE TABLE countries(
    id INT AUTO_INCREMENT PRIMARY KEY,
    Entity VARCHAR(255) NOT NULL,
    Code VARCHAR(50) NOT NULL
);

-- Insert values from the original table
INSERT INTO countries (Entity, Code)
SELECT DISTINCT Entity, Code
FROM infectious_cases
WHERE Entity IS NOT NULL;

-- Add a new column to store an entity_id
ALTER TABLE infectious_cases
ADD COLUMN entity_id INT;

-- Disable safe updates
SET SQL_SAFE_UPDATES = 0;

-- Update the main table 
UPDATE infectious_cases as i
JOIN countries as c 
  ON i.Entity = c.Entity AND i.Code = c.Code
SET i.entity_id = c.id;

-- Re-enable safe updates
SET SQL_SAFE_UPDATES = 1;

-- Task 2
-- 3rd Normal Form (3NF)
ALTER TABLE infectious_cases
DROP COLUMN Entity,
DROP COLUMN Code;

-- Verify the final structure
SELECT * FROM infectious_cases LIMIT 100;

-- Task 3
-- Calc average, min, max, sum for Number_rabies column, removing null/empty values. 
SELECT 
    entity_id, 
    AVG(Number_rabies) AS avg_rabies,
    MIN(Number_rabies) AS min_rabies,
    MAX(Number_rabies) AS max_rabies,
    SUM(Number_rabies) AS sum_rabies
FROM 
    infectious_cases
WHERE 
    Number_rabies IS NOT NULL AND Number_rabies != ''
GROUP BY entity_id
ORDER BY 
    avg_rabies DESC
LIMIT 10;

-- Task 4
-- Calc year diff 
SELECT 
    Year,
    MAKEDATE(Year, 1) AS jan_first_date,
    CURDATE() AS current_date_val,
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE()) AS years_difference
FROM 
    infectious_cases
LIMIT 10;

-- Task 5
-- Custom function  to cal Task 4
DROP FUNCTION IF EXISTS CalculateYearDifference;

DELIMITER //

CREATE FUNCTION CalculateYearDifference(input_year INT)
RETURNS INT 
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
END //
DELIMITER ;

-- Use the custom func
SELECT 
    Year, 
    CalculateYearDifference(Year) AS years_difference
FROM 
    infectious_cases
LIMIT 10;