
 --SQL Code to Data Warehouse Dimension and Fact Tables
--( Quellen DB_DEMO_1 und AdwentureWorksDW)
CREATE Database [DEMODWH_1]
GO

USE [DEMODWH_1]
 --CustomerDimension
 SELECT PERSON.Per_ID
 , ACCOUNT.Acct_ID
 , SS_WEBSITE_USER.User_ID
 , PERSON.Cust_FName
 , PERSON.Cust_LName
 , SS_WEBSITE_USER.Email_Addr
 , ACCOUNT.House_Num
 , ACCOUNT.Street_Nm
 , ACCOUNT.State
 , ACCOUNT.ZIP 
 INTO CustomerDimension 
 FROM DEMO_1.dbo.PERSON 
 left join DEMO_1.dbo.SS_WEBSITE_USER ON PERSON.Per_ID = SS_WEBSITE_USER.Per_ID
 left join DEMO_1.dbo.ACCOUNT ON PERSON.Per_ID = ACCOUNT.Per_ID


 --BillDimension 
 SELECT BILL.Bill_ID
       , ACCOUNT.Bill_Type
 INTO BillDimension 
 FROM DEMO_1.dbo.BILL 
 left join DEMO_1.dbo.ACCOUNT ON BILL.Acct_ID = ACCOUNT.Acct_ID  

 --CalendarDimension

 SELECT [FullDateAlternateKey] as [FullDate]
      ,[DayNumberOfWeek] as [Day_of_Week] 
      ,[EnglishDayNameOfWeek] as [Weekday]
       ,[DayNumberOfMonth] as [Day_of_Month]
       ,[EnglishMonthName] as  [MonthNm]
      ,[MonthNumberOfYear] as [Month]
       ,[FiscalQuarter]   as	[Quarter]
      ,[FiscalYear] as [Year] 
     INTO [CalendarDimension]
  FROM [AdventureWorksDW2019].[dbo].[DimDate]


 --PayDimension  
 
 SELECT PAYMENT.Pay_ID
       , PAYMENT.Pay_Method 
 INTO PaymentDimension 
 FROM DEMO_1.dbo.PAYMENT  

 
 --BillFacts  
 SELECT CustomerDimension.Per_ID
       , CustomerDimension.Acct_id
	   , BILL.Bill_ID
	   , CalendarDimension.FullDate
	   , BILL.Current_Balance
	   , BILL.Current_Amt_Due
	   , BILL.Past_Due_Amt 
INTO BillFacts 
FROM DEMO_1.dbo.BILL 
left join DEMO_1.dbo.CustomerDimension ON BILL.Acct_ID = CustomerDimension.Acct_ID 
left join DEMO_1.dbo.CalendarDimension ON BILL.Due_Date = CalendarDimension.FullDate


 --PaymentFacts  
 SELECT CustomerDimension.Acct_ID
       , PAYMENT.Pay_ID as [Pay_ID]
	   , CalendarDimension.FullDate
	   , Pay_Amt 
INTO PaymentFacts 
FROM DEMO_1.dbo.PAYMENT
left join DEMO_1.dbo.BILL ON PAYMENT.Bill_ID = BILL.BIll_ID 
left join DEMO_1.dbo.CustomerDimension ON BILL.Acct_ID = CustomerDimension.Acct_ID 
left join DEMO_1.dbo.CalendarDimension ON PAYMENT.Pay_Date = CalendarDimension.FullDate


