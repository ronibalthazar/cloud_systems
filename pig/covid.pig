--Load data Format 1
csv_lines_covid_format_1 = LOAD '/user/hdfs/covid/format1/' USING PigStorage(',','-tagFile') AS (
			filename:chararray,
			state:chararray,
			country:chararray,
			date:datetime,
			confirmed:int,
			deaths:int,
			recovered:int,
			latitude:float,
			longitude:float
		);

--Load data Format 2
csv_lines_covid_format_2 = LOAD '/user/hdfs/covid/format2/' USING PigStorage(',','-tagFile') AS (
			filename:chararray,
			fips:int,
			admin2:chararray,
			state:chararray,
			country:chararray,
			date:datetime,
			latitude:float,
			longitude:float,
			confirmed:int,
			deaths:int,
			recovered:int,
			active:int,
			combined:chararray
		);

--Remove duplication
lines_covid_format_1 = DISTINCT csv_lines_covid_format_1;

lines_covid_format_2 = DISTINCT csv_lines_covid_format_2;

--Use two different structures to create a matching table structure
output_etl_complete_covid_1 = foreach lines_covid_format_1 generate
	state,
	(CASE country
		WHEN 'UK' THEN 'United Kingdom'
		WHEN 'US' THEN 'United States'
		WHEN 'Republic of Ireland' THEN 'Ireland'
		WHEN 'North Ireland' THEN 'United Kingdom'
		WHEN 'Mainland China' THEN 'China'
		WHEN 'Country/Region' THEN 'China'
		WHEN 'Iran (Islamic Republic of)' THEN 'Iran'
		WHEN 'Hong Kong SAR' THEN 'Hong Kong'
		WHEN 'Macao SAR' THEN 'Macau'
		WHEN 'Korea South' THEN 'South Korea'
		WHEN 'Republic of Korea' THEN 'South Korea'
		WHEN 'Others' THEN 'Cruise Ship'
		ELSE country
	END) AS country,
	ToDate(REPLACE(filename,'.csv',''), 'MM-dd-yyyy') AS date,
	confirmed,
	deaths,
	recovered,
	confirmed - deaths - recovered AS active,
	latitude,
	longitude
;

output_etl_complete_covid_2 = foreach lines_covid_format_2 generate
	state,
	(CASE country
		WHEN 'UK' THEN 'United Kingdom'
		WHEN 'US' THEN 'United States'
		WHEN 'Republic of Ireland' THEN 'Ireland'
		WHEN 'North Ireland' THEN 'United Kingdom'
		WHEN 'Mainland China' THEN 'China'
		WHEN 'Country/Region' THEN 'China'
		WHEN 'Iran (Islamic Republic of)' THEN 'Iran'
		WHEN 'Hong Kong SAR' THEN 'Hong Kong'
		WHEN 'Macao SAR' THEN 'Macau'
		WHEN 'Korea South' THEN 'South Korea'
		WHEN 'Republic of Korea' THEN 'South Korea'
		WHEN 'Others' THEN 'Cruise Ship'
		ELSE country
	END) AS country,
	ToDate(REPLACE(filename,'.csv',''), 'MM-dd-yyyy') AS date,
	confirmed,
	deaths,
	recovered,
	active,
	latitude,
	longitude
;

--Merge the previously created structures
merged_dataset = UNION ONSCHEMA output_etl_complete_covid_1, output_etl_complete_covid_2;

--Create group by country and date
group_date_country_covid = GROUP merged_dataset BY (ToString($2, 'yyyy-MM-dd'),$1);

--Create table grouped by country and date
output_etl_country_per_day_covid = foreach group_date_country_covid generate
	ToString(ToDate(group.$0, 'yyyy-MM-dd'), 'yyyy-MM-dd HH:mm:ss.SSS'),
	REPLACE(group.$1,'[\\\'\\(\\)]+',''),
	SUM(merged_dataset.confirmed),
	SUM(merged_dataset.deaths),
	SUM(merged_dataset.recovered),
	SUM(merged_dataset.active);

--Save the results
STORE merged_dataset into '/user/pig/covid_19_complete' using PigStorage('|');

STORE output_etl_country_per_day_covid into '/user/pig/covid_19_country_per_day' using PigStorage('|');