# cloud_systems
**Cloud Systems Project - DCU**

**Project URLs – Live Endpoint**

https://bit.ly/cloudsystems
or
https://datastudio.google.com/u/0/reporting/4919b44a-5795-4236-ab51-58206f5b987f/

**GitHub – Source Code**

https://github.com/ronibalthazar/cloud_systems

**YouTube – Application Demo**

https://youtu.be/vTgUnagTdXQ


**Introduction**

World Health Organization (WHO) received a report that a pneumonia of unknown cause was detected in Wuhan, China on 31 December 2019. The disease, caused by a novel coronavirus (SARS-CoV-2), was named COVID-19 and declared a Public Health Emergency of International Concern after the outbreak quickly spread around the world on 30 January 2020 [1].
Many websites started tracking COVID-19 cases around the world. I started looking for a comparison between my home country (Brazil) and the most affected countries in the world. However, at that time no websites had an interactive comparison where you could select a few countries and interactively compare the evolution of the number of cases and fatalities. This was the motivation to select a COVID-19 dataset to create this project.
The application is called APPCOMPARE and consists of 5 dashboard pages:
- Cases Per Day
- World Map
- Cases Evolution Per Country - Animation
- Country Comparison Since First Reported Case
- Death Rate Comparison / New Cases Evolution
The technology choice was based on what data was available and how to present the data to the end-user. Google Cloud Platform (GCP) was the Cloud Platform of choice. It was used to create an Apache Hadoop cluster on Dataproc, which was used to store the source datasets on HDFS and process the data. Apache Pig was also used and a Pig Latin script was used to perform the data transformation. A GCP storage bucket was created to store the processed data used by GCP BigQuery, that was the data warehouse used in the project.
Initially, Grafana was used as a frontend, but to keep the app running we would need to also keep an instance running since the free Grafana Cloud doesn’t allow public sharing. Google Data Studio was then chosen as the project’s frontend because it is free, permits public sharing, and the app could run with a very low cost consuming only BigQuery and eventually the Hadoop cluster and the bucket while the data is updated.

**Data Source and Preparation**

The most trusted COVID-19 information comes from WHO, the Johns Hopkins University Center started collection data from WHO and other reliable sources. They used the data to create very good dashboards [2] and also made the datasets available on a GitHub repository [3].
In the repository, there are the raw daily datasets and also a pre-processed time-series report. This project uses the provided raw daily datasets to have more flexibility to transform the data.
To prepare the data, automate the data collection, and perform the data transformation, it was created a shell script, available in the project’s repository, to download the original dataset, send to HDFS and run a PIG script that cleans, transforms the data, and saves to a storage bucket. The processed data is then consumed by the frontend.

**Data Processing**

After downloading the dataset, as CSV format files from the original source, the shell script creates a storage bucket on GCP, executes some small changes in the original CSV files, and copies the files to an HDFS directory and executes a Pig Latin script.
The Pig Latin script was responsible for most of the data transformation. It reads the CSV files, which were available in two different formats depending on the date and starts to apply the required transformations. Since the main motivation for the project was the country comparison, the countries names should have a standard and the dataset had some variations in the country name field, so the Pig Latin script converts them to a standard format. It also recreates the date field using the date in the file name. It was necessary because in some days, the country didn’t provide the data for a specific day and the data from previous days was inserted in the file and this kind of data couldn’t be considered as it was duplicated.
The output of the script were two CSV formatted files. A file with the complete set of modified data and another file with the data grouped by country and day. It was stored on another HDFS directory using the PigStorage module.
A second shell script was used to get the output files from the HDFS directory and upload them to the storage bucket in a new directory.
There is also a third shell script that was used to get the files from the storage bucket and import them to GCP BigQuery creating two different tables using a pre-defined format.
The frontend, Google Data Studio, was connected to BigQuery using the standard product’s connection and a third table was created based on the country per day grouped table. This table was created to provide data such as “new cases per day” and the “number of days since the first reported case”.

**Challenges and Lessons Learned**

The main challenge in this project was to deal with non-standard data in some fields and to very good lessons were learnt, mainly to use new tools like Apache Pig and GCP since I have always used AWS as my cloud platform of choice.
Two changes were necessary to be made on the CSV files using the shell script.
The first one was to remove the commas inside the double-quotes. The commas were used when a province/state was provided. It was necessary because the Pig module PigStorage doesn’t consider the comma between double quotes, creating multiple columns instead of a single column. Since all CSV files have the date as part of their file name, the PigStorage module was used instead of CSVExcelStorage to create a new data column with the file name (“-tagsource” parameter). CSVExcelStorage doesn’t provide such feature and the date in the file name was used as the main date.
The second change made using the shell script was also related to the dates. The dataset source provides the data in two different directories with different CSV structures, depending on the date. They have changed the CSV format to add further information on 21/03/2020, so the shell script was required to be changed in the middle of the project and it was also responsible to split the files in different directories depending on the file date. All source CSV files have the date as part of the file names. To do this task using the default Linux “find” command, all file dates should match the file names, so the shell script changes the dates of the original files accordingly.
Another challenge was that country names were not standard in the CSV files. For instance, in some files the country name was “US” and in other files, it was “United States”. The Pig Latin script was used to create a standard over the country names.
	Since this project is of my interest, I will continue to update the data and add new features and comparisons after the assignment is graded.

**References**

[1] World Health Organization (WHO), Events as the happen. [Online]. Available:   https://www.who.int/emergencies/diseases/novel-coronavirus-2019/events-as-they-happen [Accessed April 5, 2020]

[2] Johns Hopkins Universiy Center, Visual Dashboard COVID-19. [Online]. Available: https://www.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6
 [Accessed April 5, 2020]

[3] Johns Hopkins Universiy Center,  Novel Coronavirus (COVID-19) Cases. [Online]. Available: https://github.com/CSSEGISandData/COVID-19 [Accessed April 6, 2020]

