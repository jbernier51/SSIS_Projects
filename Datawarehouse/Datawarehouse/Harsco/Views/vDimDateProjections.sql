








/****** Script for SelectTopNRows command from SSMS  ******/
CREATE   VIEW [Harsco].[vDimDateProjections]
AS

SELECT  [DateKey]
      --,[DateType] as [Date]
      ,[FullDate]  AS [Date]
      ,
	  
	  CASE 
		WHEN [YearNum] = YEAR (GETDATE()) THEN 'Current Year' 
		ELSE CAST([YearNum] AS VARCHAR)
	  END AS [Year]
     -- ,[YearBeginDate]
     -- ,[YearEndDate]
      ,[DayNumOfWeek] AS [Day Num of Week]
     -- ,[DayNumOfMonth]
     -- ,[DayNumOfQuarter]
     -- ,[DayNumOfYear]
      ,[DayOfWeekName] AS [Day of Week]
      ,[DayOfWeekAbbreviation] AS [Day of Week Abbrev]
      --,[JulianDayNumOfYear]
      ,[JulianJDEDate] AS [Julian JDE Date]
     -- ,[IsWeekday] as [Is Weekay]
     -- ,[IsFederalUSHoliday]
      ,[HolidayDescription] AS [Holiday]
     -- ,[IsLastDayOfWeek]
    --  ,[IsLastDayOfMonth]
     -- ,[IsLastDayOfQuarter]
    --  ,[IsLastDayOfYear]
    --  ,[WeekOfYearBeginDate]
      --,[WeekOfYearEndDate]
      --,[WeekOfMonthBeginDate]
      --,[WeekOfMonthEndDate]
      --,[WeekOfQuarterBeginDate]
      --,[WeekOfQuarterEndDate]
      --,[WeekNumOfMonth]
      --,[WeekNumOfQuarter]
      --,[WeekNumOfYear]
      ,
	  CASE 
		WHEN MONTH([FullDate]) = MONTH (GETDATE()) AND YEAR([FullDate]) = YEAR (GETDATE()) THEN 'Current Month' 
		ELSE FORMAT([FullDate],'MMM yyyy')
	  END AS [Month]
      ,[MonthNameAbbreviation] AS [Month Short]
,[MonthNameAbbreviation] + ' ' + CAST([DayNumOfMonth] AS NVARCHAR(10)) AS [Month-Day]
, CASE WHEN datekey = -1 THEN '' ELSE 
	CASE  
			WHEN [FullDate]= CAST(GETDATE() AS DATE) THEN 'Current Date'
			ELSE CAST([DayNumOfMonth] AS NVARCHAR(10))  + ' ' + [MonthNameAbbreviation] + ' ' + CAST([yearnum] AS NVARCHAR(5)) 
	END
END AS [Day-Month-Year]

    --  ,[MonthBeginDate] 

    --  ,[MonthEndDate]
      ,[MonthNumOfYear]
      ,[MonthFormatYYYYMM] AS [YYYY/MM]
      ,[QuarterNumOfYear] AS [Quarter Number]
     -- ,[QuarterBeginDate]
     -- ,[QuarterEndDate]
      ,[QuarterFormatYYYYQQ] AS [YYYY/QQ]
      ,[QuarterFormatQQ] AS [Quarter]
      --,[FiscalMonthOfYear]
      --,[FiscalQuarter]
      --,[FiscalYear]
      --,[FiscalYearMonthYYYYMM]
      --,[FiscalYearQuarterYYYYQQ]
  FROM [Harsco].[DimDate]
  WHERE datekey >= (SELECT MIN(projectiondatekey) FROM harsco.FactARProjections )
  AND datekey <= (SELECT MAX(projectiondatekey) FROM harsco.FactARProjections )
