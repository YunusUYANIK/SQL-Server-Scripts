/*--------------------------------------------------------------------------
Written by Yunus UYANIK, yunusuyanik.com
Version 1.0
Date : 06.08.2020
(c) 2020, yunusuyanik.com. All rights reserved.

For more scripts and sample code, check out 
www.yunusuyanik.com

MIT License

Copyright (c) 2020 YunusUYANIK

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
---------------------------------------------------------------------------*/

/*

@MinJobRunDateTime = Start date for historical average you want to evaluate.
@MinJobDurationSec = Threshold for minimum job duration. Minimum value to be considered job duration seconds.
@ThresholdPercent = How long exceed the average working time? (Percent) 
					Example: Avg job complete in 100 seconds, you want to see more then 110. You should specify this parameter is 10
					Process : AVGRunDurationSeconds > (AVGRunDurationSeconds>@ThresholdPercent)
          
*/

DECLARE @MinJobRunDateTime DATETIME = GETDATE()-10 
DECLARE @MinJobDurationSec INT = 60
DECLARE @ThresholdPercent DECIMAL(18,2) = 10 


SET @ThresholdPercent = (@ThresholdPercent+100)*0.01

;WITH CTE AS (
SELECT	JobName = sj.name,
		StepName = jh.step_name,
		AVGRunDurationSeconds = AVG(run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100)
FROM msdb.dbo.sysjobs sj
INNER JOIN msdb.dbo.sysjobhistory jh ON sj.job_id = jh.job_id
WHERE msdb.dbo.agent_datetime(run_date, run_time)>@MinJobRunDateTime
GROUP BY sj.name,jh.step_name
)
SELECT	JobName = sj.name,
		StepName = jh.step_name,
		RunDateTime = msdb.dbo.agent_datetime(run_date, run_time),
		EndDateTime = DATEADD(SECOND, run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100, msdb.dbo.agent_datetime(jh.run_date, jh.run_time)),
		RunDuration_DDHHMMSS = STUFF(STUFF(STUFF(RIGHT(REPLICATE('0', 8) + CAST(jh.run_duration as varchar(8)), 8), 3, 0, ':'), 6, 0, ':'), 9, 0, ':'),
		RunDurationSeconds = (run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100),
		CTE.AVGRunDurationSeconds
FROM msdb.dbo.sysjobs sj
INNER JOIN msdb.dbo.sysjobhistory jh ON sj.job_id = jh.job_id
INNER JOIN CTE ON CTE.JobName=sj.name AND CTE.StepName=jh.step_name
WHERE step_id!=0
AND (run_duration / 10000 * 3600 + run_duration % 10000 / 100 * 60 + run_duration % 100) > (CTE.AVGRunDurationSeconds*@ThresholdPercent)
AND CTE.AVGRunDurationSeconds>@MinJobDurationSec
AND msdb.dbo.agent_datetime(run_date, run_time)>@MinJobRunDateTime
