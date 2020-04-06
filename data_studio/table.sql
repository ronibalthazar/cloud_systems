--Custom table used as a source for Google Data Studio.
--It adds the calculated fields NEW_CASES and DAYS_SINCE_FIRST_CASE to the tables created by PIG

SELECT
  COUNTRY,
  DATE_TIME,
  CONFIRMED,
  DEATHS,
  RECOVERED,
  ACTIVE,
  (CONFIRMED - LAG(CONFIRMED,1,0) OVER (PARTITION BY (COUNTRY) ORDER BY (DATE_TIME))) AS NEW_CASES,
  ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY DATE_TIME) AS DAYS_SINCE_FIRST_CASE
FROM
  `bigdata-270011.default.covid_19_country_per_day`
ORDER BY
  COUNTRY, DATE_TIME ASC