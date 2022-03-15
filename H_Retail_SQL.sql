use H_Retail;

-- ///// FINDING MISSING VALUES ///// -- 

-- customer table: customer_id missing = 1
SELECT 
    COUNT(`c`.`customer_id`) AS `customer_id_missing`
FROM
    `H_Retail`.`customer` AS `c`
WHERE
    `c`.`customer_id` = 0
;

SELECT count(DISTINCT `c`.`customer_id`)
FROM
    `H_Retail`.`customer` AS `c`
        LEFT JOIN
    `H_Retail`.`invoice5` AS `in` ON `c`.`customer_id` = `in`.`customer_id`
        INNER JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`;

-- customer_id from both customer table and invoice table: total unique customer_id = 32561 with 4138 unique id that does not contain null
SELECT 
    `c`.`customer_id`,
    SUM(`inl`.`quantity`) AS `quantity`,
    SUM(`inl`.`quantity` * `inl`.`unit_price`) AS `spending`
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`invoice5` AS `in` ON `c`.`customer_id` = `in`.`customer_id`
        INNER JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`
GROUP BY `customer_id`
ORDER BY `c`.`customer_id`
;

-- sex: missing sex = 0 
SELECT count( `c`.`sex_at_birth`) as `sex_missing`
FROM
    `H_Retail`.`customer` AS `c`
        LEFT JOIN
    `H_Retail`.`invoice5` AS `in` ON `c`.`customer_id` = `in`.`customer_id`
        INNER JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`
    where `c`.`sex_at_birth` = '?';

-- occupation - occupation missing = 1,843
SELECT 
    COUNT(`o`.`occupation`) AS `occupation_missing`
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`occupation` AS `o` ON `c`.`occupation_id` = `o`.`occupation_id`
WHERE
    `o`.`occupation` = '?'
;

-- employment: employment missing = 1,836
SELECT 
    COUNT(*)
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`employment_type` AS `emp` ON `c`.`employment_type_id` = `emp`.`employment_type_id`
WHERE
    `emp`.`employment_type` = '?'
;
-- education: education missing = 0
SELECT 
    COUNT(`edu`.`education`) AS `edu_missing`
FROM
    `H_Retail`.`customer` AS `c`
        LEFT JOIN
    `H_Retail`.`education` AS `edu` ON `c`.`education_id` = `edu`.`education_id`
WHERE
    `edu`.`education` = '?'
;

-- marital status: status missing = 0
SELECT 
    COUNT(`m`.`marital_status`) AS `marital_missing`
FROM
    `H_Retail`.`customer` AS `c`
        LEFT JOIN
    `H_Retail`.`marital_status` AS `m` ON `c`.`marital_status_id` = `m`.`marital_status_id`
WHERE
    `m`.`marital_status` = '?'
;

-- relationship in house hold: missing = 0
SELECT 
    COUNT(`re`.`relationship_in_household`) AS `rela_missing`
FROM
    `H_Retail`.`customer` AS `c`
        LEFT JOIN
    `H_Retail`.`relationship_in_household` AS `re` ON `c`.`relationship_in_household_id` = `re`.`relationship_in_household_id`
WHERE
    `re`.`relationship_in_household` = '?'
;

-- race: race missing = 0
SELECT 
    COUNT(`ra`.`race`) AS `race_missing`
FROM
    `H_Retail`.`customer` AS `c`
        LEFT JOIN
    `H_Retail`.`race` AS `ra` ON `c`.`race_id` = `ra`.`race_id`
WHERE
    `ra`.`race` = '?'
;

-- country: country missing = 583
SELECT 
    COUNT(`con`.`country`) AS `country_missing`
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`country` AS `con` ON `c`.`original_country_of_citizenship_id` = `con`.`country_id`
WHERE
    `con`.`country` = '?'
;

SELECT 
    *
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`country` AS `con` ON `c`.`original_country_of_citizenship_id` = `con`.`country_id`
WHERE
    `con`.`country` = '?'
;


-- ///// PREPARING DATA FOR MACHINE LEARNING ///// --
-- join the entire table without customer_id <> 0 for python
SELECT 
    `c`.`customer_id`,
    `c`.`sex_at_birth`,
    `o`.`occupation`,
    `emp`.`employment_type`,
    `edu`.`education`,
    `c`.`completed_years_of_education`,
    `m`.`marital_status`,
    `re`.`relationship_in_household`,
    `ra`.`race`,
    IF(`con`.`country` = 'Canada'
            OR `con`.`country` = 'Outlying-US(Guam-USVI-etc)'
            OR `con`.`country` = 'United-States'
            OR `con`.`country` = 'Mexico',
        'America',
        'Rest_world')  AS `country`,
    `t`.`type_of_client`,
    SUM(`inl`.`quantity`) AS `quantity`,
    SUM(`inl`.`quantity` * `inl`.`unit_price`) AS `total_spending`,
    MAX(`inl`.`invoice_line`) AS `total_invoice`
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`occupation` AS `o` ON `c`.`occupation_id` = `o`.`occupation_id`
        INNER JOIN
    `H_Retail`.`employment_type` AS `emp` ON `c`.`employment_type_id` = `emp`.`employment_type_id`
        INNER JOIN
    `H_Retail`.`education` AS `edu` ON `c`.`education_id` = `edu`.`education_id`
        INNER JOIN
    `H_Retail`.`marital_status` AS `m` ON `c`.`marital_status_id` = `m`.`marital_status_id`
        INNER JOIN
    `H_Retail`.`relationship_in_household` AS `re` ON `c`.`relationship_in_household_id` = `re`.`relationship_in_household_id`
        INNER JOIN
    `H_Retail`.`race` AS `ra` ON `c`.`race_id` = `ra`.`race_id`
        INNER JOIN
    `H_Retail`.`country` AS `con` ON `c`.`original_country_of_citizenship_id` = `con`.`country_id`
        LEFT JOIN
    `H_Retail`.`type_of_client_staging5` AS `t` ON `c`.`customer_id` = `t`.`customer_id`
        LEFT JOIN
    `H_Retail`.`invoice5` AS `in` ON `c`.`customer_id` = `in`.`customer_id`
        INNER JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`
WHERE
    `c`.`customer_id` <> 0
GROUP BY `c`.`customer_id`
ORDER BY `c`.`customer_id` ASC;

-- checking null number on client that are already identified 
SELECT 
    `c`.`customer_id`,
    `t`.`type_of_client`,
    sum(`inl`.`quantity`),
    `inl`.`quantity` * `inl`.`unit_price` AS `spending`
FROM
    `H_Retail`.`type_of_client_staging5` AS `t`
        INNER JOIN
    `H_Retail`.`customer` AS `c` ON `t`.`customer_id` = `c`.`customer_id`
        LEFT JOIN
    `H_Retail`.`invoice5` AS `in` ON `t`.`customer_id` = `in`.`customer_id`
        inner JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`
WHERE
    `quantity` IS not null;

--  already identified customer_table
SELECT 
    `t`.`customer_id`,
    `c`.`sex_at_birth`,
    `o`.`occupation`,
    `emp`.`employment_type`,
    `edu`.`education`,
    `c`.`completed_years_of_education`,
    `m`.`marital_status`,
    `re`.`relationship_in_household`,
    `ra`.`race`,
    `con`.`country`,
    SUM(`inl`.`quantity`) AS `quantity`,
    SUM(`inl`.`quantity` * `inl`.`unit_price`) AS `total_spending`,
    MAX(`inl`.`invoice_line`) AS `total_invoice`,
    `t`.`type_of_client`
FROM
    `H_Retail`.`customer` AS `c`
        LEFT JOIN
    `H_Retail`.`type_of_client_staging5` AS `t` ON `c`.`customer_id` = `t`.`customer_id`
        INNER JOIN
    `H_Retail`.`occupation` AS `o` ON `c`.`occupation_id` = `o`.`occupation_id`
        INNER JOIN
    `H_Retail`.`employment_type` AS `emp` ON `c`.`employment_type_id` = `emp`.`employment_type_id`
        INNER JOIN
    `H_Retail`.`education` AS `edu` ON `c`.`education_id` = `edu`.`education_id`
        INNER JOIN
    `H_Retail`.`marital_status` AS `m` ON `c`.`marital_status_id` = `m`.`marital_status_id`
        INNER JOIN
    `H_Retail`.`relationship_in_household` AS `re` ON `c`.`relationship_in_household_id` = `re`.`relationship_in_household_id`
        INNER JOIN
    `H_Retail`.`race` AS `ra` ON `c`.`race_id` = `ra`.`race_id`
        INNER JOIN
    `H_Retail`.`country` AS `con` ON `c`.`original_country_of_citizenship_id` = `con`.`country_id`
        LEFT JOIN
    `H_Retail`.`invoice5` AS `in` ON `c`.`customer_id` = `in`.`customer_id`
        INNER JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`
WHERE
    `t`.`type_of_client` IS NOT NULL
GROUP BY `t`.`customer_id`
ORDER BY `t`.`customer_id`
;

-- customer who are missing type_of_clients (unidentified)
SELECT 
    `c`.`customer_id`,
    `c`.`sex_at_birth`,
    `o`.`occupation`,
    `emp`.`employment_type`,
    `edu`.`education`,
    `c`.`completed_years_of_education`,
    `m`.`marital_status`,
    `re`.`relationship_in_household`,
    `ra`.`race`,
    `con`.`country`,
    `t`.`type_of_client`,
    SUM(`inl`.`quantity`) AS `quantity`,
    SUM(`inl`.`quantity` * `inl`.`unit_price`) AS `total_spending`,
    MAX(`inl`.`invoice_line`) AS `total_invoice`
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`occupation` AS `o` ON `c`.`occupation_id` = `o`.`occupation_id`
        INNER JOIN
    `H_Retail`.`employment_type` AS `emp` ON `c`.`employment_type_id` = `emp`.`employment_type_id`
        INNER JOIN
    `H_Retail`.`education` AS `edu` ON `c`.`education_id` = `edu`.`education_id`
        INNER JOIN
    `H_Retail`.`marital_status` AS `m` ON `c`.`marital_status_id` = `m`.`marital_status_id`
        INNER JOIN
    `H_Retail`.`relationship_in_household` AS `re` ON `c`.`relationship_in_household_id` = `re`.`relationship_in_household_id`
        INNER JOIN
    `H_Retail`.`race` AS `ra` ON `c`.`race_id` = `ra`.`race_id`
        INNER JOIN
    `H_Retail`.`country` AS `con` ON `c`.`original_country_of_citizenship_id` = `con`.`country_id`
        LEFT JOIN
    `H_Retail`.`type_of_client_staging5` AS `t` ON `c`.`customer_id` = `t`.`customer_id`
        LEFT JOIN
    `H_Retail`.`invoice5` AS `in` ON `c`.`customer_id` = `in`.`customer_id`
        INNER JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`
WHERE
    `t`.`type_of_client` is null
GROUP BY `c`.`customer_id`
ORDER BY `c`.`customer_id` ASC;

-- ///// PYTHON INPUT ///// -- 

-- impute missing values with mode and added in guesstimation of client type from machine learning ---
SELECT 
    `c`.`customer_id`,
    `c`.`sex_at_birth`,
    IF(`o`.`occupation` = '?',
        ' Prof-specialty',
        `o`.`occupation`) AS `occupation`,
    IF(`emp`.`employment_type` = '?',
        'Private',
        `emp`.`employment_type`) AS `employment_type`,
    `c`.`completed_years_of_education`,
    `m`.`marital_status`,
    `re`.`relationship_in_household`,
    `ra`.`race`,
    `con`.`country`,
    SUM(`inl`.`quantity`) AS `quantity`,
    SUM(`inl`.`quantity` * `inl`.`unit_price`) AS `total_spending`,
    MAX(`inl`.`invoice_line`) AS `total_invoice`,
    `t`.`type_of_client`,
    IF(SUM(`inl`.`quantity`) > 497,
        'Wholesaler',
        'Personal') AS `client_type_MC`
FROM
    `H_Retail`.`customer` AS `c`
        INNER JOIN
    `H_Retail`.`occupation` AS `o` ON `c`.`occupation_id` = `o`.`occupation_id`
        INNER JOIN
    `H_Retail`.`employment_type` AS `emp` ON `c`.`employment_type_id` = `emp`.`employment_type_id`
        INNER JOIN
    `H_Retail`.`education` AS `edu` ON `c`.`education_id` = `edu`.`education_id`
        INNER JOIN
    `H_Retail`.`marital_status` AS `m` ON `c`.`marital_status_id` = `m`.`marital_status_id`
        INNER JOIN
    `H_Retail`.`relationship_in_household` AS `re` ON `c`.`relationship_in_household_id` = `re`.`relationship_in_household_id`
        INNER JOIN
    `H_Retail`.`race` AS `ra` ON `c`.`race_id` = `ra`.`race_id`
        INNER JOIN
    `H_Retail`.`country` AS `con` ON `c`.`original_country_of_citizenship_id` = `con`.`country_id`
        LEFT JOIN
    `H_Retail`.`type_of_client_staging5` AS `t` ON `c`.`customer_id` = `t`.`customer_id`
        LEFT JOIN
    `H_Retail`.`invoice5` AS `in` ON `c`.`customer_id` = `in`.`customer_id`
        INNER JOIN
    `H_Retail`.`invoice_line` AS `inl` ON `in`.`invoice_id` = `inl`.`invoice_id`
WHERE
    `c`.`customer_id` <> 0
GROUP BY `c`.`customer_id`
ORDER BY `c`.`customer_id` ASC;