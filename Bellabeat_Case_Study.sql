ASK

Bellabeat is a successful small company, but they have the potential to become a larger player in the global smart device market. 
Urška Sršen, co-founder and Chief Creative Officer of Bellabeat, believes that analyzing smart device fitness data could help unlock new growth opportunities for the company. 

Business task
	You have been asked to focus on one of Bellabeat’s products and analyze smart device data to gain insight into how consumers are using their smart devices. The insights you discover will then help guide a marketing strategy for the company towards growth. 

Key stakeholders
  1. Urška Sršen: Bellabeat’s co-founder and Chief Creative Officer 
  2. Sando Mur: Mathematician and Bellabeat co-founder; key member of the Bellabeat executive team 
  3. Bellabeat marketing analytics team: A team of data analysts responsible for collecting, analyzing, and reporting data that helps guide Bellabeat’s marketing strategy. You joined this team six months ago and have been busy learning about Bellabeat’’s mission and business goals — as well as how you, as a junior data analyst, can help Bellabeat achieve them.

Deliverable
	Bellabeat, a high-tech company specializing in health focused smart products is looking to grow their company, and become a larger player in the global smart device market. We have prepared and analyzed the appropriate data on smart device fitness data from consumers using non-bellabeat devices in order to come up with a recommendation for Bellabeat’s future marketing strategy with their smart device product. 


PREPARE

The dataset was distributed by Amazon Mechanical Turk between March 12, 2016 and May 12, 2016. It is stored in Kaggle, and dedicated under a public domain license. 

- The data is organized into 18 sheets detailing a wide area of fitness such as calories, steps, activity and sleep data. The sheets are formatted long. 
- The data is also classified as structured, secondary and external 
- ROCCC
  1. Reliable - Needs Improvement
    The data surveys 30 eligible fitbit users; however, this is quite a small sample size compared to the population of fitbit users - and smart device users in general. Additionally, there is no data on gender, and age which have an impact on one’s health and fitness activity.
  2. Original - Needs Improvement
    This is external data from a third-party source, Amazon Mechanical Turk. As a result, it is difficult to locate the original data source. 
  3. Comprehensive - Excellent
    Data is comprehensive and covers various facets of fitness on both a macro and micro level - daily, hourly and minute activity.
    Additionally, data is organized into 18 sheets so that each sheet is detailed and covers each topic of data
  4. Current - Satisfactory/Needs Improvement
    The data is from 2016; fitness technology has made massive strides and daily integration which can change how people view these smart devices.
    Physical activity and overall fields within health and fitness such as fitness metrics are unchanged however. 
  5. Cited - Excellent
    Source is well documented, and all information on Kaggle is made visible for viewers. The original company distributing the surveys, as well as the authors are all made visible within the platform. 
    Our data is focused on the fitbit smart device. As Bellabeat wants us to analyze smart device data, the product we will most likely focus on for the company will be Bellabeat’s version of the fitbit.
    We can analyze data on daily user activity that covers major health and fitness metrics such as weight, sleep, calories, steps, activity, and general intensity to find patterns and/or solutions to how Bellabeat should market their smart device.



Six datasets were imported to Google Sheets to be cleaned and processed for BigQuery. Data recorded daily was favored, to avoid repetitive analysis on micro data points such as the sheets with hourly and minute metrics. 

dailyActivity_merged.csv
dailyCalories_merged.csv
dailyIntensities_merged.csv
dailySteps_merged.csv
sleepDay_merged.csv
WeightInfo_merged.csv

PROCESS

To check for data integrity issues, an established rubric was followed in which the dataset was checked for datatype, datarange, mandatory values, primary/foreign keys, completeness, and consistency.

Many columns held unclean data; dates and numbers were to be properly formatted on Google Sheets. Additional functions such as split were also implemented to break down columns with DATETIME. 
Dataset was formatted long, as a result there was no identifiable primary/foreign key for each dataset and table
Additionally, all six sheets were processed for consistency with participant Id. However, this test failed the data integrity check.

-- 

#33 unique individuals were surveyed
SELECT 
  DISTINCT Id
FROM 
  `dailyActivity_merged.dailyActivity_merged`;

#33 unique individuals were surveyed
SELECT
  DISTINCT Id
FROM
  `dailyCalories_merged.dailyCalories_merged`;

#33 unique individuals were surveyed
SELECT
  DISTINCT Id
FROM
  `dailyIntensities_merged.dailyIntensities_merged`;

#33 unique individuals were surveyed
SELECT
  DISTINCT Id
FROM
  `dailySteps_merged.dailySteps_merged`;

#24 unique individuals were surveyed
SELECT
  *
FROM
  `sleepDay.sleepDay`;

#8 unique individuals were surveyed
SELECT
  DISTINCT Id
FROM
  `weightLogInfo.weightLogInfo`;
  
 --
 
dailyActivity_merged.csv
dailyCalories_merged.csv
dailyIntensities_merged.csv
dailySteps_merged.csv

These sheets contain 33 unique participants which is more than the original 30 participants stated within the dataset description.

sleepDay_merged.csv
WeightInfo_merged.csv

sleepDay contains only 24 unique Ids and weightInfo contains only 8 unique Ids


ANALYZE

There is a positive correlation between daily calories burnt and intense activity.
The below query finds the daily active distance, time, intense time, intense distance, and calories in order to find the possible relationship
The data set is ordered by users who have the most time recorded being very active

--

# Positive correlation betweeen calories burnt and intense activity
SELECT
  Id,
  ActivityDate,
  TotalSteps, 
  TotalDistance - SedentaryActiveDistance AS active_distance, 
  VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes AS active_time,
  VeryActiveMinutes/ NULLIF((VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes), 0) AS intense_activity,
  VeryActiveMinutes,
  Calories
FROM
  `dailyActivity_merged.dailyActivity_merged`
WHERE
  TotalSteps <> 0 
ORDER BY
  VeryActiveMinutes DESC;
  
 --
 
There is a correlation between daily calories burnt, and individual BMI
This query pulls total daily active time for each user, their calories burnt, and their weight information
This data set is ordered by highest BMI first

--

#Negative correlation between active time with BMI
#Users who are more active have a lower BMI
SELECT
  a.Id,
  a.VeryActiveMinutes + a.FairlyActiveMinutes + a.LightlyActiveMinutes AS active_time,
  a.Calories,
  w.WeightPounds,
  w.BMI
FROM
  `dailyActivity_merged.dailyActivity_merged` a 
INNER JOIN
  `weightLogInfo.weightLogInfo` w ON a.Id = w.Id
ORDER BY
  w.BMI DESC;
  
 --
 
There is a correlation between user’s active time, and quality of sleep time
This query pulls total daily active time, total time which includes sedentary minutes, calories burnt, as well as their total time asleep in minutes
This data set is ordered by highest calories burnt

--

# Weak correlation between active time and sleeptime
SELECT
 a.Id,
 a.ActivityDate,
 a.VeryActiveMinutes,
 a.VeryActiveMinutes + a.FairlyActiveMinutes + a.LightlyActiveMinutes AS active_time,
 a.VeryActiveMinutes + a.FairlyActiveMinutes + a.LightlyActiveMinutes + a.SedentaryMinutes AS total_time,
 a.Calories,
 s.Sleepday,
 s.totalMinutesAsleep
FROM
 `dailyActivity_merged.dailyActivity_merged` a
INNER JOIN
 `sleepDay.sleepDay` s ON a.Id = s.Id
WHERE
  a.ActivityDate = s.SleepDay
ORDER BY
 a.Calories DESC;
 
 --
 
DATA VISUAL

https://public.tableau.com/app/profile/darren.chang4554/viz/BellabeatDashboard_16611949673190/Dashboard1?publish=yes


INSIGHTS & RECOMMENDATION

Based on the sorted datasets, and the dynamic visualizations, Fitbit users that dedicate a greater amount of time to intense activity and active minutes lead a healthier lifestyle in three areas: calories burnt, sleep achieved, and BMI. 
There is a strong positive correlation between a user’s very active time, and calories burnt. 
There is a strong positive correlation when factoring total steps taken during the day, and calories burnt.
There is a slight downward trend on a user’s active minutes and sleep time. Most users average 7.5 hours; however, as active time increases this trends down towards 6 hours. 
There is a negative correlation between a user’s active time and BMI; user’s that spend significantly less time active (<200) have a higher BMI

Bellabeat can implement new functions within their own smart device that already active users will appreciate, and new users can directly benefit from
Hourly reminder to complete daily fitness goals
Goals can be established within the smart device’s free fitness recommendation; 45 minutes daily on cardio and/or weights
Add graphics and encouragement to smart device platform when daily intense activity goals are reached to incentivize users to stay committed 
Provide daily statistics that show calories burnt and the allocation of calories burnt based on different activities such as intense exercise vs walking.
Provide hourly notifications for user’s to meet their total step goals 
Add new graphics and encouragement to smart device when daily goals with steps are reached to incentivize users to stay committed on an hourly basis and reduce weight/BMI in the long run. 
Provide sleep data based on a user’s fitness level that day. 
Given that there is a general limit to daily sleep that ranges between 6-7.5 hours, Bellabeat should market their technology and data as insights to consumers as ways to improve their daily sleep
This can be intuitive with the initial hourly reminder by encouraging daily activity, and reaching daily step goals


