


CREATE procedure [dbo].[CreateDimDateData](

/*******************************************************************************************************************
** Procedure Name: CreateDimDateData
** Desc:
** Auth: Gene Furibondo
** Date: 09/24/2017
********************************************************************************************************************
** Change History
--------------------------------------------------------------------------------------------------------------------
** PR   Date        Author				Description 
** --   --------   -------				------------------------------------
** 1    09/27/2017  Dhilasu Reddy       Added Inline Comments
********************************************************************************************************************/


--***********************************************************************************************************************
--1. Parameter declarations for Stored Procedure 
--***********************************************************************************************************************
  @pi_vcStartDate                             varchar(10), --   = '01/01/2015',
  @pi_vcEndDate                               varchar(10), --   = '12/31/2025',
  @pi_intFiscalMonthOffset                    smallint ,   --   = 6,
  @pi_tiResultsType                           tinyint   ,  --   = 1,
  @pi_vcColumnList                            varchar(max) --  = 
) 
As
  SET NOCOUNT ON
--***********************************************************************************************************************
--2. Declare and Set initial values of variables
--***********************************************************************************************************************
  If @pi_vcStartDate                          is null
    Set @pi_vcStartDate                       = '01/01/2015';
  If @pi_vcEndDate                            is null
    Set @pi_vcEndDate                         = '12/31/2025';
  If @pi_intFiscalMonthOffset                 is null
    Set @pi_intFiscalMonthOffset              = 6;
  If @pi_vcColumnList                         is null
    Set @pi_vcColumnList                      = 
      'DateKey,             DateType,              FullDate,             YearNum,               YearBeginDate,
       YearEndDate,           DayNumOfWeek,          DayNumOfMonth,        DayNumOfQuarter,       DayNumOfYear,
       DayOfWeekName,         DayOfWeekAbbreviation, JulianDayNumOfYear, JulianJDEDate,  IsWeekDay,             IsFederalUSHoliday, 
       HolidayDescription,    IsLastDayOfWeek,       IsLastDayOfMonth,     IsLastDayOfQuarter,    IsLastDayOfYear,
       WeekOfYearBeginDate,   WeekOfYearEndDate,     WeekOfMonthBeginDate, WeekOfMonthEndDate,    WeekOfQuarterBeginDate,
       WeekOfQuarterEndDate,  WeekNumOfMonth,        WeekNumOfQuarter,     WeekNumOfYear,         MonthName,
       MonthNameAbbreviation, MonthBeginDate,        MonthEndDate,         MonthNumOfYear,        MonthFormatYYYYMM,
       QuarterNumOfYear,      QuarterBeginDate,      QuarterEndDate,       QuarterFormatYYYYQQ,   QuarterFormatQQ,
       FiscalMonthOfYear,     FiscalQuarter,         FiscalYear,           FiscalYearMonthYYYYMM, FiscalYearQuarterYYYYQQ';
  --print '@pi_vcColumnList=' + @pi_vcColumnList
  Declare @iStart                           int;
  Declare @iEnd                             int;
  Declare @Itereator                        int;
  Declare @nvcSQL                           nvarchar(4000);
  Declare @vcColumnListForComparison        nvarchar(4000);
  Begin Try Drop Table #tblHolidays End Try Begin Catch End Catch
  Create Table #tblHolidays                       ( HolidayDesc     varchar(50),
                                                    HolidayYear     char(4),
                                                    HolidayDate     date );
  
  Begin Try Drop Table #tblDateSet End Try Begin Catch End Catch
  Create table #tblDateSet                        ( DataRow         varchar(8000) );

  Set @vcColumnListForComparison = ',' + Replace( Replace( Replace( @pi_vcColumnList,' ','' ), CHAR(10),'' ), CHAR(13),'' ) + ','
--***********************************************************************************************************************
--3. The Date algorithm keys off of the 2000 Millenium here and further below
--***********************************************************************************************************************
  Set @iStart                               = ( Select datediff(day, '1/1/2000', @pi_vcStartDate) ); 
  Set @iEnd                                 = ( Select datediff(day, '1/1/2000', @pi_vcEndDate  ) ); 

  Begin Try Drop Table #tblIntergerRepresentationOfDates End Try Begin Catch End Catch
  Create table #tblIntergerRepresentationOfDates  ( i int );

  Set @Itereator                            = @iStart;
--***********************************************************************************************************************
--4. Create a Temporary structure to hold the date data
--***********************************************************************************************************************
  Begin Try Drop Table #tblDimDate End Try Begin Catch End Catch
  CREATE TABLE #tblDimDate(
  DateKey                                 int         NOT NULL,
  DateType                                  varchar(20) NULL,
  FullDate                                  date        NULL,                
  YearNum                                   smallint    NULL,
  YearBeginDate                             DATE        NULL,
  YearEndDate                               DATE        NULL,           
  DayNumOfWeek                              tinyint     NULL,                
  DayNumOfMonth                             tinyint     NULL,                
  DayNumOfQuarter                           tinyint     NULL,                
  DayNumOfYear                              smallint    NULL,                
  DayOfWeekName                             varchar(20) NULL,                
  DayOfWeekAbbreviation                     varchar(10) NULL,                
  JulianDayNumOfYear                        int         NULL,  
    JulianJDEDate                        int         NULL,                
  IsWeekDay                                 char(1)     NULL,                
  IsFederalUSHoliday                        char(1)     NULL,
  HolidayDescription                        varchar(50) NULL,                
  IsLastDayOfWeek                           char(1)     NULL,                
  IsLastDayOfMonth                          char(1)     NULL,                
  IsLastDayOfQuarter                        char(1)     NULL,                
  IsLastDayOfYear                           char(1)     NULL,                
  WeekOfYearBeginDate                       date        NULL,                
  WeekOfYearEndDate                         date        NULL,                
  WeekOfMonthBeginDate                      date        NULL,                
  WeekOfMonthEndDate                        date        NULL,                
  WeekOfQuarterBeginDate                    date        NULL,                
  WeekOfQuarterEndDate                      date        NULL,                
  WeekNumOfMonth                            tinyint     NULL,                
  WeekNumOfQuarter                          tinyint     NULL,                
  WeekNumOfYear                             tinyint     NULL,                
  MonthName                                 varchar(20) NULL,                
  MonthNameAbbreviation                     varchar(10) NULL,                
  MonthBeginDate                            date        NULL,                
  MonthEndDate                              date        NULL,                
  MonthNumOfYear                            tinyint     NULL,
  MonthFormatYYYYMM                         CHAR(7)     NULL,                
  QuarterNumOfYear                          tinyint     NULL,                
  QuarterBeginDate                          date        NULL,                
  QuarterEndDate                            date        NULL,
  QuarterFormatYYYYQQ                       CHAR(6)     NULL,
  QuarterFormatQQ                           CHAR(2)     NULL,
  FiscalMonthOfYear                         tinyint     NULL,
  FiscalQuarter                             tinyint     NULL,
  FiscalYear                                smallint    NULL,
  FiscalYearMonthYYYYMM                     varchar(10) NULL,
  FiscalYearQuarterYYYYQQ                   varchar(10) NULL );
--***********************************************************************************************************************
--5. Populate a variable table of the dates needed in integer equivalent form
--***********************************************************************************************************************
  While ( @Itereator                        <= @iEnd )
  Begin
    Insert into #tblIntergerRepresentationOfDates ( i ) 
      values ( @Itereator );
    Set @Itereator                          = @Itereator + 1;
  End
--Select * From #tblIntergerRepresentationOfDates

--***********************************************************************************************************************
--6. Insert into the temporary Date structure the initial values.  Not all values are populated with the initial
--insert.  Other columns have update statements below.  Essentially, any column that has an insert value of NULL
--will have a corresponing update statement after that creates the data for that column.
--***********************************************************************************************************************
INSERT INTO #tblDimDate
  SELECT
  CAST(YEAR(ddate) AS CHAR(4)) 
    + CASE WHEN MONTH(ddate)<10 THEN 
                  '0' + CAST(MONTH(ddate) AS CHAR(1)) 
                ELSE CAST(MONTH(ddate) AS CHAR(2)) END
    + CASE WHEN DAY(ddate)<10 THEN 
                  '0' + CAST(DAY(ddate) AS CHAR(1)) 
                ELSE CAST(DAY(ddate) AS CHAR(2)) End                              AS DateKey  
  ,NULL                                                                           AS DateType              
  ,CONVERT(varchar(10),ddate,111)                                                 AS FullDate
  ,YEAR(ddate)                                                                    AS YearNum
  ,NULL                                                                           AS YearBeginDate
  ,NULL                                                                           AS YearEndDate
  ,datepart(weekday, ddate)                                                       AS DayNumOfWeek
  ,day(ddate)                                                                     AS DayNumOfMonth
  ,NULL                                                                           AS DayNumOfQuarter
  ,datename(dayofyear, ddate)                                                     As DayNumOfYear
  ,datename(dw, ddate)                                                            AS DayOfWeekName        
  ,left(datename(dw, ddate),3)                                                    AS DayOfWeekAbbreviation 
  ,year(ddate) * 1000 + datepart(dy, ddate)                                       AS JulianDayNumOfYear
  ,1000*(year(ddate)-1900) + DATEDIFF(day,STR(YEAR(ddate),4)+'0101',ddate)+1		AS JulianJDEDate
  ,case when datepart(weekday, ddate) in (1,7) then 'N' else 'Y' END              As IsWeekDay        
  ,'N'                                                                            AS IsFederalUSHoliday
  ,'Not a Holiday'                                                                AS HolidayDescription
  ,case when datepart(weekday, ddate) = 7 then 'Y' else 'N' end                   AS IsLastDayOfWeek
  ,case when day(dateadd(Day,+1,ddate)) = 1 then 'Y' else 'N' END                 AS IsLastDayOfMonth
  ,NULL                                                                           AS IsLastDayOfQuarter
  ,NULL                                                                           AS IsLastDayOfYear
  ,NULL                                                                           AS WeekOfYearBeginDate                
  ,NULL                                                                           AS WeekOfYearEndDate                
  ,NULL                                                                           AS WeekOfMonthBeginDate                
  ,NULL                                                                           AS WeekOfMonthEndDate                
  ,NULL                                                                           AS WeekOfQuarterBeginDate                
  ,NULL                                                                           AS WeekOfQuarterEndDate                
  , DATEPART(week, ddate)
          -  DATEPART(week, CONVERT(CHAR(6), ddate, 112)+'01')
          + 1                                                                     AS WeekNumOfMonth
  , datepart(wk, ddate)
         -(datepart(qq, ddate)-1)
         * 13                                                                     AS WeekNumOfQuarter
  , 	DATEPART(ww,ddate)                                                          AS WeekNumOfYear
  , 	DATENAME(MM,ddate)                                                          AS MonthName
  ,    case datepart(month, ddate) when 1 then 'Jan'
                                       when 2 then 'Feb'
                                       when 3 then 'Mar'
                                       when 4 then 'Apr'
                                       when 5 then 'May'
                                       when 6 then 'Jun'
                                       when 7 then 'Jul'
                                       when 8 then 'Aug'
                                       when 9 then 'Sept'
                                       when 10 then 'Oct'
                                       when 11 then 'Nov'
                                       when 12 then 'Dec'
              end                                                                 AS MonthNameAbbreviation

  , 	CAST(dateadd(mm, datediff(mm, 0, ddate) ,0) AS DATE)                        AS MonthBeginDate
  , 	CAST(dateadd(mm, datediff(mm, -1, ddate) ,-1) AS DATE)                      AS MonthEndDate
  , DATEPART(MM,ddate)                                                            AS MonthNumOfYear
  ,    cast(YEAR(ddate) as CHAR(4)) + '/' +
         case when MONTH(ddate) < 10 then '0'+cast(MONTH(ddate) as char(1))
          else cast(MONTH(ddate) as char(2)) end                                  AS MonthFormatYYYYMM
  , DATEPART(QQ,ddate)                                                            AS QuarterNumOfYear
  , CAST(DATEADD(qq, DATEDIFF(qq,0,ddate), 0)AS DATE)	                            AS QuarterBeginDate
  , CAST(DATEADD(qq, DATEDIFF(qq,-90,ddate), -1)AS DATE)                          AS QuarterEndDate
  , CAST(YEAR(ddate) AS CHAR(4)) + 'Q' + CAST(datepart(qq,ddate) AS CHAR(1))      AS QuarterFormatYYYYQQ
  ,    case quarter_id when 1 then 'Q1'
                      when 2 then 'Q2'
                      when 3 then 'Q3'
                      when 4 then 'Q4'
            end                                                                   AS QuarterFormatQQ
  , DATEPART(MM,DATEADD(MM,@pi_intFiscalMonthOffset,ddate))                       AS FiscalMonthOfYear
  , DATEPART(QQ,DATEADD(MM,@pi_intFiscalMonthOffset,ddate))                       AS FiscalQuarter
  , YEAR(DATEADD(MM,@pi_intFiscalMonthOffset,ddate))                              AS FiscalYear
  , Cast(YEAR(DATEADD(MM,@pi_intFiscalMonthOffset,ddate)) as varchar(4)) + 
      Case When DATEPART(MM,DATEADD(MM,@pi_intFiscalMonthOffset,ddate)) 
                                            < 10 Then
             '0'+ cast(DATEPART(MM,DATEADD(MM,@pi_intFiscalMonthOffset,ddate)) as varchar(1))
           Else
             Cast(DATEPART(MM,DATEADD(MM,@pi_intFiscalMonthOffset,ddate)) as varchar(2)) End         
                                                                                  AS FiscalYearMonthYYYYMM
  , Cast(YEAR(DATEADD(MM,@pi_intFiscalMonthOffset,ddate)) as varchar(4)) + 
      'Q' + Cast(datepart(qq,DATEADD(MM,@pi_intFiscalMonthOffset,ddate)) as char(1))             
                                                                                  AS FiscalYearQuarterYYYYQQ
  From (
      Select
         day_id                             = datepart( dy,      dateadd(day, day_id, '1/1/2000'))                           
        ,ddate                              = ddate
        ,first_day_of_week                  = datepart( day,     dateadd(day, (-1 * (datepart(weekday,ddate)-1)), ddate))
        ,week_id                            = datepart( week,    ddate)
        ,weekday_id                         = datepart( weekday, ddate)
        ,month_id                           = datepart( month,   ddate)
        ,[year]                             = datepart( year,    ddate)
        ,[day]                              = datepart( day,     ddate)
        ,quarter_id                         = datepart( quarter, ddate)

      From (
          Select i as day_id
               ,dateadd(day, i, '1/1/2000') as ddate
          From #tblIntergerRepresentationOfDates
      ) as a 
  ) as a order by FullDate;
--Select * From #tblDimDate

--***********************************************************************************************************************
--7. Populate DateType column(s) of temporary Date structure.
--***********************************************************************************************************************
  Update #tblDimDate
    Set DateType                            = 'Normal';
--***********************************************************************************************************************
--8. Populate DayNumOfQuarter column(s) of temporary Date structure.
--***********************************************************************************************************************
  Update #tblDimDate
    Set DayNumOfQuarter                     = DATEDIFF(d, QuarterBeginDate, FullDate) + 1
--***********************************************************************************************************************
--9. Populate YearBeginDate and YearEndDate column(s) of temporary Date structure.
--***********************************************************************************************************************
  Begin Try Drop Table #tblYearNum End Try Begin Catch End Catch
  Create Table #tblYearNum              ( YearNum       smallint,
                                          YearBeginDate date,
                                          YearEndDate   date );
  Insert Into #tblYearNum
    Select YearNum
        , min(FullDate)                   as YearBeginDate
        , max(FullDate)                   as YearEndDate
    From #tblDimDate s
    group by YearNum;

  Update #tblDimDate
    Set YearBeginDate                       = #tblYearNum.YearBeginDate
      , YearEndDate                         = #tblYearNum.YearEndDate
    From #tblYearNum 
    Where #tblYearNum.YearNum               = #tblDimDate.YearNum;
--***********************************************************************************************************************
--10. Populate IsLastDayOfQuarter column(s) of temporary Date structure.
--***********************************************************************************************************************
  Update #tblDimDate
    Set IsLastDayOfQuarter                  = 'N';
--***********************************************************************************************************************
--11. Populate IsLastDayOfQuarter column(s) of temporary Date structure.
--***********************************************************************************************************************
  Update #tblDimDate
    Set IsLastDayOfQuarter                  = 'Y'
    where QuarterEndDate                    = FullDate;
--***********************************************************************************************************************
--12. Populate IsLastDayOfYear column(s) of temporary Date structure.
--***********************************************************************************************************************
  Update #tblDimDate
    Set IsLastDayOfYear                     = 'N';
--***********************************************************************************************************************
--13. Populate YearEndDate column(s) of temporary Date structure.
--***********************************************************************************************************************
  Update #tblDimDate
    Set IsLastDayOfYear                     = 'Y'
    where YearEndDate                       = FullDate;
--***********************************************************************************************************************
--14. Populate WeekNumOfQuarter column(s) of temporary Date structure.
--***********************************************************************************************************************
  Update #tblDimDate
    Set WeekNumOfQuarter                    = 1
    Where WeekNumOfQuarter                  = 0;
--***********************************************************************************************************************
--15. Populate WeekOfYearBeginDate and WeekOfYearEndDate column(s) of temporary Date structure.
--***********************************************************************************************************************
  Begin Try Drop Table #tblWeekOfYear End Try Begin Catch End Catch
  Create Table #tblWeekOfYear               ( YearNum             smallint,
                                              WeekNumOfYear       tinyint,
                                              WeekOfYearBeginDate date,
                                              WeekOfYearEndDate   date )
  Insert Into #tblWeekOfYear --( YearNum, WeekNumOfYear, WeekOfYearBeginDate, WeekOfYearEndDate )
     Select YearNum
          , WeekNumOfYear
          , min(FullDate)                   as WeekOfYearBeginDate
          , max(FullDate)                   as WeekOfYearEndDate
     From #tblDimDate
     group by YearNum, WeekNumOfYear

  Update #tblDimDate 
    Set WeekOfYearBeginDate                 = #tblWeekOfYear.WeekOfYearBeginDate
      , WeekOfYearEndDate                   = #tblWeekOfYear.WeekOfYearEndDate
    From #tblWeekOfYear
      Where #tblWeekOfYear.YearNum          = #tblDimDate.YearNum
        and #tblWeekOfYear.WeekNumOfYear    = #tblDimDate.WeekNumOfYear;
--***********************************************************************************************************************
--16. Populate WeekOfMonthBeginDate and WeekOfMonthEndDate column(s) of temporary Date structure.
--***********************************************************************************************************************
  Begin Try Drop Table #tblWeekOfMonth End Try Begin Catch End Catch
  Create Table #tblWeekOfMonth            ( YearNum                 smallint,
                                            MonthNumOfYear          tinyint,
                                            WeekNumOfMonth          tinyint,
                                            WeekOfMonthBeginDate    date,
                                            WeekOfMonthEndDate      date )
  Insert Into #tblWeekOfMonth ( YearNum, MonthNumOfYear, WeekNumOfMonth, WeekOfMonthBeginDate, WeekOfMonthEndDate )
     Select YearNum
          , MonthNumOfYear
          , WeekNumOfMonth
          , min(FullDate)                    as WeekOfMonthBeginDate
          , max(FullDate)                    as WeekOfMonthEndDate
     From #tblDimDate
     group by YearNum, MonthNumOfYear, WeekNumOfMonth
    
  Update #tblDimDate
    Set WeekOfMonthBeginDate              = #tblWeekOfMonth.WeekOfMonthBeginDate
      , WeekOfMonthEndDate                = #tblWeekOfMonth.WeekOfMonthEndDate
    From #tblWeekOfMonth
    Where #tblDimDate.YearNum             = #tblWeekOfMonth.YearNum
      and #tblDimDate.MonthNumOfYear      = #tblWeekOfMonth.MonthNumOfYear
      and #tblDimDate.WeekNumOfMonth      = #tblWeekOfMonth.WeekNumOfMonth;
--***********************************************************************************************************************
--17. Populate WeekOfQuarterBeginDate and WeekOfQuarterEndDate column(s) of temporary Date structure.
--***********************************************************************************************************************
  Begin Try Drop Table #tblWeekOfQuarter End Try Begin Catch End Catch
  Create Table #tblWeekOfQuarter          ( YearNum                   smallint,
                                            QuarterNumOfYear          tinyint,
                                            WeekNumOfQuarter          tinyint,
                                            WeekOfQuarterBeginDate    date,
                                            WeekOfQuarterEndDate      date )

  Insert Into #tblWeekOfQuarter ( YearNum, QuarterNumOfYear, WeekNumOfQuarter, WeekOfQuarterBeginDate, WeekOfQuarterEndDate )
     Select YearNum
          , QuarterNumOfYear
          , WeekNumOfQuarter
          , min(FullDate)                    as WeekOfQuarterBeginDate
          , max(FullDate)                    as WeekOfQuarterEndDate
     From #tblDimDate
     group by YearNum, QuarterNumOfYear, WeekNumOfQuarter;

  Update #tblDimDate
    Set WeekOfQuarterBeginDate              = #tblWeekOfQuarter.WeekOfQuarterBeginDate
      , WeekOfQuarterEndDate                = #tblWeekOfQuarter.WeekOfQuarterEndDate
    From #tblWeekOfQuarter
    Where #tblDimDate.YearNum               = #tblWeekOfQuarter.YearNum
      and #tblDimDate.QuarterNumOfYear      = #tblWeekOfQuarter.QuarterNumOfYear
      and #tblDimDate.WeekNumOfQuarter      = #tblWeekOfQuarter.WeekNumOfQuarter;
--***********************************************************************************************************************
--18. Insert Members for Instances the date is not known
--***********************************************************************************************************************
  Insert #tblDimDate 
    ( DateKey,            DateType,             FullDate,            YearNum,              YearBeginDate,
      YearEndDate,          DayNumOfWeek,         DayNumOfMonth,       DayNumOfQuarter,      DayNumOfYear,
      DayOfWeekName,        DayOfWeekAbbreviation,JulianDayNumOfYear,  IsWeekDay,            IsFederalUSHoliday, 
      HolidayDescription,   IsLastDayOfWeek,      IsLastDayOfMonth,    IsLastDayOfQuarter,   IsLastDayOfYear,
      WeekOfYearBeginDate,  WeekOfYearEndDate,    WeekOfMonthBeginDate,WeekOfMonthEndDate,   WeekOfQuarterBeginDate,
      WeekOfQuarterEndDate, WeekNumOfMonth,       WeekNumOfQuarter,    WeekNumOfYear,        MonthName,
      MonthNameAbbreviation,MonthBeginDate,       MonthEndDate,        MonthNumOfYear,       MonthFormatYYYYMM,
      QuarterNumOfYear,     QuarterBeginDate,     QuarterEndDate,      QuarterFormatYYYYQQ,  QuarterFormatQQ,
      FiscalMonthOfYear,    FiscalQuarter,        FiscalYear,          FiscalYearMonthYYYYMM,FiscalYearQuarterYYYYQQ )
    Values        
    ( -1,                   'UNKNOWN',            '1/1/1900',          0,                    '1/1/1900',
      '1/1/1900',           0,                    0,                   0,                    0,
      'UNKNOWN',            'UNK',                0,                   '-',                  0,
      '-',                  0,                    0,                   0,                    0,
      '1/1/1900',           '1/1/1900',           '1/1/1900',          '1/1/1900',           '1/1/1900',
      '1/1/1900',           0,                    0,                   0,                    '-',
      '-',                  '1/1/1900',           '1/1/1900',          0,                    '-',
      0,                    '1/1/1900',           '1/1/1900',          '-',                  '-',
      0,                    0,                    0,                   '-',                  '-' );

  --Insert #tblDimDate 
  --  ( DateKey,            DateType,             FullDate,            YearNum,              YearBeginDate,
  --    YearEndDate,          DayNumOfWeek,         DayNumOfMonth,       DayNumOfQuarter,      DayNumOfYear,
  --    DayOfWeekName,        DayOfWeekAbbreviation,JulianDayNumOfYear,  IsWeekDay,            IsFederalUSHoliday, 
  --    HolidayDescription,   IsLastDayOfWeek,      IsLastDayOfMonth,    IsLastDayOfQuarter,   IsLastDayOfYear,
  --    WeekOfYearBeginDate,  WeekOfYearEndDate,    WeekOfMonthBeginDate,WeekOfMonthEndDate,   WeekOfQuarterBeginDate,
  --    WeekOfQuarterEndDate, WeekNumOfMonth,       WeekNumOfQuarter,    WeekNumOfYear,        MonthName,
  --    MonthNameAbbreviation,MonthBeginDate,       MonthEndDate,        MonthNumOfYear,       MonthFormatYYYYMM,
  --    QuarterNumOfYear,     QuarterBeginDate,     QuarterEndDate,      QuarterFormatYYYYQQ,  QuarterFormatQQ,
  --    FiscalMonthOfYear,    FiscalQuarter,        FiscalYear,          FiscalYearMonthYYYYMM,FiscalYearQuarterYYYYQQ )
  --  Values        
  --  ( -2,                   'UNASSIGNED',         '1/1/1900',          0,                    '1/1/1900',
  --    '1/1/1900',           0,                    0,                   0,                    0,
  --    'UNASSIGNED',         'NYA',                0,                   '-',                  0,
  --    '-',                  0,                    0,                   0,                    0,
  --    '1/1/1900',           '1/1/1900',           '1/1/1900',          '1/1/1900',           '1/1/1900',
  --    '1/1/1900',           0,                    0,                   0,                    '-',
  --    '-',                  '1/1/1900',           '1/1/1900',          0,                    '-',
  --    0,                    '1/1/1900',           '1/1/1900',          '-',                  '-',
  --    0,                    0,                    0,                   '-',                  '-' );

  --Insert #tblDimDate
  --  ( DateKey,            DateType,             FullDate,            YearNum,              YearBeginDate,
  --    YearEndDate,          DayNumOfWeek,         DayNumOfMonth,       DayNumOfQuarter,      DayNumOfYear,
  --    DayOfWeekName,        DayOfWeekAbbreviation,JulianDayNumOfYear,  IsWeekDay,            IsFederalUSHoliday, 
  --    HolidayDescription,   IsLastDayOfWeek,      IsLastDayOfMonth,    IsLastDayOfQuarter,   IsLastDayOfYear,
  --    WeekOfYearBeginDate,  WeekOfYearEndDate,    WeekOfMonthBeginDate,WeekOfMonthEndDate,   WeekOfQuarterBeginDate,
  --    WeekOfQuarterEndDate, WeekNumOfMonth,       WeekNumOfQuarter,    WeekNumOfYear,        MonthName,
  --    MonthNameAbbreviation,MonthBeginDate,       MonthEndDate,        MonthNumOfYear,       MonthFormatYYYYMM,
  --    QuarterNumOfYear,     QuarterBeginDate,     QuarterEndDate,      QuarterFormatYYYYQQ,  QuarterFormatQQ,
  --    FiscalMonthOfYear,    FiscalQuarter,        FiscalYear,          FiscalYearMonthYYYYMM,FiscalYearQuarterYYYYQQ )
  --  Values        
  --  ( -3,                   'INVALID',           '1/1/1900',          0,                    '1/1/1900',
  --    '1/1/1900',           0,                    0,                   0,                    0,
  --    'INVALID',            'INV',                0,                   '-',                  0,
  --    '-',                  0,                    0,                   0,                    0,
  --    '1/1/1900',           '1/1/1900',           '1/1/1900',          '1/1/1900',           '1/1/1900',
  --    '1/1/1900',           0,                    0,                   0,                    '-',
  --    '-',                  '1/1/1900',           '1/1/1900',          0,                    '-',
  --    0,                    '1/1/1900',           '1/1/1900',          '-',                  '-',
  --    0,                    0,                    0,                   '-',                  '-' );
--***********************************************************************************************************************
--19. Set Federal Holidays
--***********************************************************************************************************************
--  SET LANGUAGE N'us_english'
  SET DATEFIRST 7

  -- Set up the year.
  Begin Try Drop Table #year End Try Begin Catch End Catch
  Create Table #year                        (year_str VARCHAR(4))
  Begin Try Drop Table #day End Try Begin Catch End Catch
  Create Table #day                         (day_int SMALLINT)
  DECLARE @i SMALLINT

  Insert #year
    Select Cast(YearNum as varchar(4))
      From #tblDimDate;

  -- Set up a table of day-of-month values.
  Set @i                                    = 1;
  WHILE @i                                  < 32
	BEGIN
		INSERT #day VALUES(@i)
		Set @i                                  = @i + 1;
	END

  -- Union all the holidays together.
  Insert Into #tblHolidays (HolidayDesc, HolidayYear, HolidayDate)
    SELECT
    'New Years'                                                                   AS Holiday,
    year_str                                                                      AS [Year],
    CASE WHEN DATEPART(dw,CONVERT(Date,'01/01/'+year_str))
                                            = 1 THEN 
          DATEADD(dd,1,CONVERT(Date,'01/01/'+year_str))
         WHEN DATEPART(dw,CONVERT(Date,'01/01/'+year_str))
                                            = 7 THEN 
          DATEADD(dd,-1,CONVERT(Date,'01/01/'+year_str))
         ELSE CONVERT(Date,'01/01/'+year_str)
    END                                                                           AS [Date]
    FROM #year
  UNION
  -- Lee-Jackson-King Day: Third Monday in January:
  -- (MAX) WHERE dw = 2 and day_int < 22
  SELECT 'Lee-Jackson-King', 
         year_str,
         MAX(CONVERT(Date,'01/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str))
    FROM #day,#year
    WHERE DATEPART(dw,CONVERT(Date,'01/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str)) 
                                            = 2
      AND day_int                           < 22
    GROUP BY year_str
  UNION
  -- Memorial Day: Last Monday in May: (MAX) WHERE dw = 2
  SELECT 'Memorial Day', 
         year_str,
         MAX(CONVERT(Date,'05/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str))
    FROM #day,#year
    WHERE DATEPART(dw,CONVERT(Date,'05/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str)) 
                                            = 2
    GROUP BY year_str
  UNION
  --
  SELECT 'Fourth Of July',
         year_str,
         CASE  WHEN DATEPART(dw,CONVERT(Date,'07/04/'+year_str))
                                            = 1 THEN 
                 CONVERT(Date,'07/05/'+year_str)
               WHEN DATEPART(dw,CONVERT(Date,'07/04/'+year_str))
                                            = 7 THEN 
                 CONVERT(Date,'07/03/'+year_str)
               ELSE 
                 CONVERT(Date,'07/04/'+year_str)
               END
    FROM #year
  UNION
  -- Labor Day: First Monday in September: MIN WHERE dw = 2
  -- Keep day_int less than 31 because 9/31 is an out-of-range Date value.
  SELECT 'Labor Day', 
         year_str,
         MIN(CONVERT(Date,'09/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str))
    FROM #day,#year
    WHERE   DATEPART(dw,CONVERT(Date,'09/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str)) 
                                            = 2
      AND day_int                           < 31
  GROUP BY year_str
  UNION

  -- Thanksgiving: Fourth Thursday in November: MAX WHERE dw = 5 and day_int < 29
  SELECT 'Thanksgiving', 
         year_str,
         MAX(CONVERT(Date,'11/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str))
    FROM #day,#year
    WHERE DATEPART(dw,CONVERT(Date,'11/'+CONVERT(VARCHAR(2),day_int)+'/'+year_str)) 
                                            = 5
      AND day_int                           < 29
    GROUP BY year_str

  UNION
  SELECT 'Christmas',
         year_str,
    CASE WHEN DATEPART(dw,CONVERT(Date,'12/25/'+year_str))
                                            = 1 THEN 
           CONVERT(Date,'12/26/'+year_str)
         WHEN DATEPART(dw,CONVERT(Date,'12/25/'+year_str))
                                            = 7 THEN 
           CONVERT(Date,'12/24/'+year_str)
         ELSE 
           CONVERT(Date,'12/25/'+year_str)
         END
    FROM #year
  --Take the Holidays just created and updated the temporary data structure with the dates
  Update #tblDimDate
    Set IsFederalUSHoliday                  = 'Y',
        HolidayDescription                  = HolidayDesc
    From #tblHolidays H 
    Where #tblDimDate.FullDate              = H.HolidayDate
--***********************************************************************************************************************
--20. Return the data in temporary Date structure
--***********************************************************************************************************************
  If @pi_tiResultsType                      = 1 --Regular Result Set 
  Begin
    Set @nvcSQL                             = 'SELECT ' +  @pi_vcColumnList + ' FROM #tblDimDate order by DateKey;';
    Execute sp_executesql @nvcSQL
  End
  Else If @pi_tiResultsType                 = 3  --Create an flat file for data import. the data is returned to the consumer
                                                 --where the dataset is saved to a file.
  Begin
    Select 
    '"' + Cast( DateKey                  as varchar(100) ) + '"' +
            Case When CHARINDEX( ',DateType,',                  @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( DateType                   as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',FullDate,',                  @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( FullDate                   as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',YearNum,',                   @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( YearNum                    as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',YearBeginDate,',             @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( YearBeginDate              as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',YearEndDate,',               @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( YearEndDate                as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',DayNumOfWeek,',              @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( DayNumOfWeek               as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',DayNumOfMonth,',             @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( DayNumOfMonth              as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',DayNumOfQuarter,',           @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( DayNumOfQuarter            as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',DayNumOfYear,',              @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( DayNumOfYear               as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',DayOfWeekName,',             @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( DayOfWeekName              as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',DayOfWeekAbbreviation,',     @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( DayOfWeekAbbreviation      as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',JulianDayNumOfYear,',        @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( JulianDayNumOfYear         as varchar(100) ) + '"' Else '' End +

	 Case When CHARINDEX( ',JulianJDEDate,',        @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( JulianJDEDate         as varchar(100) ) + '"' Else '' End +


            Case When CHARINDEX( ',IsWeekDay,',                 @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( IsWeekDay                  as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',IsFederalUSHoliday,',        @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( IsFederalUSHoliday         as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',HolidayDescription,',        @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( HolidayDescription         as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',IsLastDayOfWeek,',           @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( IsLastDayOfWeek            as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',IsLastDayOfMonth,',          @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( IsLastDayOfMonth           as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',IsLastDayOfQuarter,',        @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( IsLastDayOfQuarter         as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',IsLastDayOfYear,',           @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( IsLastDayOfYear            as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekOfYearBeginDate,',       @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekOfYearBeginDate        as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekOfYearEndDate,',         @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekOfYearEndDate          as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekOfMonthBeginDate,',      @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekOfMonthBeginDate       as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekOfMonthEndDate,',        @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekOfMonthEndDate         as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekOfQuarterBeginDate,',    @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekOfQuarterBeginDate     as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekOfQuarterEndDate,',      @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekOfQuarterEndDate       as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekNumOfMonth,',            @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekNumOfMonth             as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekNumOfQuarter,',          @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekNumOfQuarter           as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',WeekNumOfYear,',             @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( WeekNumOfYear              as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',MonthName,',                 @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( MonthName                  as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',MonthNameAbbreviation,',     @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( MonthNameAbbreviation      as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',MonthBeginDate,',            @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( MonthBeginDate             as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',MonthEndDate,',              @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( MonthEndDate               as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',MonthNumOfYear,',            @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( MonthNumOfYear             as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',MonthFormatYYYYMM,',         @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( MonthFormatYYYYMM          as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',QuarterNumOfYear,',          @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( QuarterNumOfYear           as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',QuarterBeginDate,',          @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( QuarterBeginDate           as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',QuarterEndDate,',            @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( QuarterEndDate             as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',QuarterFormatYYYYQQ,',       @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( QuarterFormatYYYYQQ        as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',QuarterFormatQQ,',           @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( QuarterFormatQQ            as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',FiscalMonthOfYear,',         @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( FiscalMonthOfYear          as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',FiscalQuarter,',             @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( FiscalQuarter              as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',FiscalYear,',                @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( FiscalYear                 as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',FiscalYearMonthYYYYMM,',     @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( FiscalYearMonthYYYYMM      as varchar(100) ) + '"' Else '' End +
            Case When CHARINDEX( ',FiscalYearQuarterYYYYQQ,',   @vcColumnListForComparison,1 ) > 0 Then 
    ',"' + Cast( FiscalYearQuarterYYYYQQ    as varchar(100) ) + '"' Else '' End 
    FROM #tblDimDate Order By DateKey;
  End
  Else If @pi_tiResultsType                 = 2 --Create Insert Statements
  Begin
    Select
    'Insert Into harsco.DimDate (' + Replace( Replace( Replace( @pi_vcColumnList,' ','' ), CHAR(10),'' ), CHAR(13),'' ) + ') ' +
    '  Values (''' + Cast( DateKey                   as varchar(100) ) + '''' +
        Case When CHARINDEX( ',DateType,',                      @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( DateType                   as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',FullDate,',                      @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( FullDate                   as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',YearNum,',                       @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( YearNum                    as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',YearBeginDate,',                 @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( YearBeginDate              as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',YearEndDate,',                   @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( YearEndDate                as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',DayNumOfWeek,',                  @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( DayNumOfWeek               as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',DayNumOfMonth,',                 @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( DayNumOfMonth              as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',DayNumOfQuarter,',               @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( DayNumOfQuarter            as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',DayNumOfYear,',                  @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( DayNumOfYear               as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',DayOfWeekName,',                 @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( DayOfWeekName              as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',DayOfWeekAbbreviation,',         @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( DayOfWeekAbbreviation      as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',JulianDayNumOfYear,',            @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( JulianDayNumOfYear         as varchar(100) ) + '''' Else '' End +


			Case When CHARINDEX( ',JulianJDEDate,',            @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( JulianJDEDate        as varchar(100) ) + '''' Else '' End +


        Case When CHARINDEX( ',IsWeekDay,',                     @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( IsWeekDay                  as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',IsFederalUSHoliday,',            @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( IsFederalUSHoliday         as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',HolidayDescription,',            @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( HolidayDescription         as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',IsLastDayOfWeek,',               @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( IsLastDayOfWeek            as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',IsLastDayOfMonth,',              @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( IsLastDayOfMonth           as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',IsLastDayOfQuarter,',            @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( IsLastDayOfQuarter         as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',IsLastDayOfYear,',               @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( IsLastDayOfYear            as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekOfYearBeginDate,',           @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekOfYearBeginDate        as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekOfYearEndDate,',             @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekOfYearEndDate          as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekOfMonthBeginDate,',          @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekOfMonthBeginDate       as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekOfMonthEndDate,',            @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekOfMonthEndDate         as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekOfQuarterBeginDate,',        @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekOfQuarterBeginDate     as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekOfQuarterEndDate,',          @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekOfQuarterEndDate       as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekNumOfMonth,',                @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekNumOfMonth             as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekNumOfQuarter,',              @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekNumOfQuarter           as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',WeekNumOfYear,',                 @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( WeekNumOfYear              as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',MonthName,',                     @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( MonthName                  as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',MonthNameAbbreviation,',         @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( MonthNameAbbreviation      as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',MonthBeginDate,',                @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( MonthBeginDate             as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',MonthEndDate,',                  @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( MonthEndDate               as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',MonthNumOfYear,',                @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( MonthNumOfYear             as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',MonthFormatYYYYMM,',             @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( MonthFormatYYYYMM          as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',QuarterNumOfYear,',              @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( QuarterNumOfYear           as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',QuarterBeginDate,',              @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( QuarterBeginDate           as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',QuarterEndDate,',                @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( QuarterEndDate             as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',QuarterFormatYYYYQQ,',           @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( QuarterFormatYYYYQQ        as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',QuarterFormatQQ,',               @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( QuarterFormatQQ            as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',FiscalMonthOfYear,',             @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( FiscalMonthOfYear          as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',FiscalQuarter,',                 @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( FiscalQuarter              as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',FiscalYear,',                    @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( FiscalYear                 as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',FiscalYearMonthYYYYMM,',         @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( FiscalYearMonthYYYYMM      as varchar(100) ) + '''' Else '' End +
        Case When CHARINDEX( ',FiscalYearQuarterYYYYQQ,',       @vcColumnListForComparison,1 ) > 0 Then 
            ',''' + Cast( FiscalYearQuarterYYYYQQ    as varchar(100) ) + '''' Else '' End +
            '); 
GO'
    FROM #tblDimDate Order By DateKey;
  End