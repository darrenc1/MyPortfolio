
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

