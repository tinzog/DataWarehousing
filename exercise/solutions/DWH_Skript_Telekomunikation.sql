----******************************************************
--
--          Data Warehouse Dimensional Model
--
--SQL Code to Create Data Warehouse Dimension and Fact Tables from QUELLE Database on base  Logical Model
--***************************************************************

USE master;

IF DB_ID('Ziel_DWH') IS NOT NULL

  DROP DATABASE [Ziel_DWH];

--GO

CREATE DATABASE [Ziel_DWH]



use Ziel_DWH
 --CustomerDimension


 CREATE TABLE [dbo].[CustomerDimension](
	[Per_ID] [char](10) NOT NULL,
	[Acct_ID] [char](10) NOT NULL,
	[User_ID] [varchar](25) NULL,
	[Cust_FName] [varchar](25) NOT NULL,
	[Cust_LName] [varchar](25) NOT NULL,
	[Email_Addr] [varchar](50) NULL,
	[House_Num] [varchar](25) NULL,
	[Street_Nm] [varchar](50) NULL,
	[State] [char](2) NULL,
	[ZIP] [int] NULL
	)
-- Load the dimensions
 insert into Ziel_DWH.dbo.CustomerDimension (Per_ID
 , Acct_ID
 , User_ID
 , Cust_FName
 , Cust_LName
 ,  Email_Addr
 , House_Num
 , Street_Nm
 , State
 , ZIP )
 SELECT PERSON.Per_ID
 , ACCOUNT.Acct_ID
 , SS_WEBSITE_USER.User_ID
 , PERSON.Cust_FName
 , PERSON.Cust_LName
 ,  SS_WEBSITE_USER.Email_Addr
 , ACCOUNT.House_Num
 , ACCOUNT.Street_Nm
 , ACCOUNT.State
 , ACCOUNT.ZIP 
 FROM Quelle_OLTP_System.dbo.PERSON 
 left join Quelle_OLTP_System.dbo.SS_WEBSITE_USER ON PERSON.Per_ID = SS_WEBSITE_USER.Per_ID
 left join Quelle_OLTP_System.dbo.ACCOUNT ON PERSON.Per_ID = ACCOUNT.Per_ID  


ALTER TABLE CustomerDimension ADD PRIMARY KEY (Per_ID,Acct_ID);


 --BillDimension 

 CREATE TABLE [dbo].[BillDimension](
	[Bill_ID] [char](12) NOT NULL,
	[Current_Balance] [numeric](7, 2) NOT NULL,
	[Current_Amt_Due] [numeric](7, 2) NOT NULL,
	[Past_Due_Amt] [numeric](7, 2) NOT NULL,
	[Bill_Type] [varchar](10) NULL,
	[Acct_ID] [char](10) NOT NULL,
	[Due_Date] [date] NOT NULL
)

-- Load the dimensions
 insert  INTO Ziel_DWH.dbo.BillDimension (
Bill_ID
       , Current_Balance
	   , Current_Amt_Due
	   , Past_Due_Amt 
       , Bill_Type
	   ,Acct_ID
	   ,Due_Date
 )
 SELECT BILL.Bill_ID
       , BILL.Current_Balance
	   , BILL.Current_Amt_Due
	   , BILL.Past_Due_Amt 
       , ACCOUNT.Bill_Type
	   ,BILL.Acct_ID
	   ,BILL.Due_Date
 FROM Quelle_OLTP_System.dbo.BILL 
 left join Quelle_OLTP_System.dbo.ACCOUNT ON BILL.Acct_ID = ACCOUNT.Acct_ID  


 ALTER TABLE BillDimension ADD PRIMARY KEY (Bill_ID);

 --CalendarDimension

 CREATE TABLE [dbo].[CalendarDimension](
	[FullDate] [date] NOT NULL,
	[Day_of_Week] [tinyint] NOT NULL,
	[Weekday] [nvarchar](10) NOT NULL,
	[Day_of_Month] [tinyint] NOT NULL,
	[MonthNm] [nvarchar](10) NOT NULL,
	[Month] [tinyint] NOT NULL,
	[Quarter] [tinyint] NOT NULL,
	[Year] [smallint] NOT NULL
) 
-- Load the dimensions
INSERT  INTO Ziel_DWH.dbo.CalendarDimension
( [FullDate]
      ,[Day_of_Week] 
      , [Weekday]
       ,[Day_of_Month]
       ,[MonthNm]
       ,[Month]
       ,[Quarter]
      , [Year]
)
 SELECT [FullDateAlternateKey] as [FullDate]
      ,[DayNumberOfWeek] as [Day_of_Week] 
      ,[EnglishDayNameOfWeek] as [Weekday]
       ,[DayNumberOfMonth] as [Day_of_Month]
       ,[EnglishMonthName] as  [MonthNm]
      ,[MonthNumberOfYear] as [Month]
       ,[FiscalQuarter]   as	[Quarter]
      ,[FiscalYear] as [Year] 
FROM Quelle_OLTP_System.[dbo].[Date]


  
  ALTER TABLE CalendarDimension ADD PRIMARY KEY (FullDate);


 --PayDimension  
 CREATE TABLE [dbo].[PaymentDimension](
	[Pay_ID] [char](15) NOT NULL,
	[Pay_Method] [varchar](15) NOT NULL,
	[Pay_Amt] [numeric](7, 2) NOT NULL,
	[Bill_ID] [char](12) NOT NULL,
	[Pay_Date] [date] NOT NULL
)
-- Load the dimensions
INSERT INTO Ziel_DWH.dbo.PaymentDimension (
 Pay_ID
,Pay_Method 
,Pay_Amt
, Bill_ID
,PAYMENT.Pay_Date
)
 SELECT PAYMENT.Pay_ID
       , PAYMENT.Pay_Method 
	   ,PAYMENT.Pay_Amt
	   ,PAYMENT.Bill_ID
	    ,PAYMENT.Pay_Date
 
 FROM Quelle_OLTP_System.dbo.PAYMENT  

 ALTER TABLE PaymentDimension ADD PRIMARY KEY (Pay_ID);

 
 --BillFacts  

 CREATE TABLE [dbo].[BillFacts](
	[Per_ID] [char](10) NOT NULL,
	[Acct_ID] [char](10) NOT NULL,
	[Bill_ID] [char](12) NOT NULL,
	[FullDate] [date] NOT NULL,
	[Current_Balance] [numeric](7, 2) NOT NULL,
	[Current_Amt_Due] [numeric](7, 2) NOT NULL,
	[Past_Due_Amt] [numeric](7, 2) NOT NULL
)
-- Load the dimensions
iNSERT INTO Ziel_DWH.dbo.BillFacts 
(
Per_ID
, Acct_ID
, Bill_ID
, FullDate
	   , Current_Balance
	   ,Current_Amt_Due
	   , Bill.Past_Due_Amt 


)
 SELECT CustomerDimension.Per_ID
       , CustomerDimension.Acct_ID
	   , Bill.Bill_ID
	   , CalendarDimension.FullDate
	   , Bill.Current_Balance
	   ,Bill.Current_Amt_Due
	   , Bill.Past_Due_Amt 

FROM Quelle_OLTP_System.dbo.Bill
left join Ziel_DWH.dbo.CustomerDimension ON Bill.Acct_ID = CustomerDimension.Acct_ID 
left join Ziel_DWH.dbo.CalendarDimension ON Bill.Due_Date = CalendarDimension.FullDate




 --PaymentFacts  
 CREATE TABLE [dbo].[PaymentFacts](
	[Acct_ID] [char](10) NOT NULL,
	[Pay_ID] [char](15) NOT NULL,
	[FullDate] [date] NOT NULL,
	[Pay_Amt] [numeric](7, 2) NOT NULL
	,[Per_ID] [char](10) NOT NULL
)
-- Load the dimensions
INSERT INTO Ziel_DWH.dbo.PaymentFacts (
		Acct_ID
       , Pay_ID
	   , FullDate
	   , Payment.Pay_Amt 
	   , Per_ID
)
 SELECT CustomerDimension.Acct_ID
       , Payment.Pay_ID
	   , CalendarDimension.FullDate
	   , Payment.Pay_Amt 
	    ,CustomerDimension.Per_ID

FROM Quelle_OLTP_System.dbo.Payment
left join Quelle_OLTP_System.dbo.Bill ON Payment.Bill_ID = Bill.BIll_ID 
left join Ziel_DWH.dbo.CustomerDimension ON Bill.Acct_ID = CustomerDimension.Acct_ID 
left join Ziel_DWH.dbo.CalendarDimension ON Payment.Pay_Date = CalendarDimension.FullDate




-- Add foreign keys

ALTER TABLE BillFacts
ADD CONSTRAINT FK_BillD_BillFacts
FOREIGN KEY (Bill_ID) REFERENCES BillDimension(Bill_ID);

ALTER TABLE BillFacts
ADD CONSTRAINT FK_CustomerD_BillFacts
FOREIGN KEY (Per_ID, Acct_ID) REFERENCES CustomerDimension(Per_ID, Acct_ID);

ALTER TABLE BillFacts
ADD CONSTRAINT FK_CalenderD_BillFacts
FOREIGN KEY (FullDate) REFERENCES CalendarDimension(FullDate);

ALTER TABLE PaymentFacts
ADD CONSTRAINT FK_CustomerD_PaymentFacts
FOREIGN KEY (Per_ID, Acct_ID) REFERENCES CustomerDimension(Per_ID, Acct_ID);

ALTER TABLE PaymentFacts
ADD CONSTRAINT FK_CalenderD_PaymentFacts
FOREIGN KEY (FullDate) REFERENCES CalendarDimension(FullDate);

ALTER TABLE PaymentFacts
ADD CONSTRAINT FK_PaymentsD_PaymentFacts
FOREIGN KEY (Pay_ID) REFERENCES PaymentDimension(Pay_ID);



--------------------------------------------------
---  DWH Abfrage  
--------------------------------------------------

--What is the sum of bill amounts due in October?

SELECT sum(BillFacts.Current_Amt_Due) as "Total Due In October"
FROM dbo.BillFacts inner join dbo.CalendarDimension
ON BillFacts.FullDate = CalendarDimension.FullDate WHERE CalendarDimension.MonthNm = 'October'


--What is the sum of payments received in October, by type?  

SELECT sum(PaymentFacts.Pay_Amt) as "Total Paid In October", PaymentDimension.Pay_Method as "Payment Method" 
FROM dbo.PaymentFacts 
inner join dbo.CalendarDimension ON PaymentFacts.FullDate = CalendarDimension.FullDate 
inner join dbo.PaymentDimension ON PaymentFacts.Pay_ID = PaymentDimension.Pay_ID
WHERE CalendarDimension.MonthNm = 'October' GROUP BY PaymentDimension.Pay_Method 

--What are the first and last names of customers that have past due balances sometime in October? 

SELECT dbo.CustomerDimension.Cust_FName as "First Name", dbo.CustomerDimension.Cust_LName 
FROM dbo.CustomerDimension 
INNER JOIN dbo.BillFacts ON dbo.CustomerDimension.Per_ID = dbo.BillFacts.Per_ID 
                                                AND dbo.CustomerDimension.Acct_ID = dbo.BillFacts.Acct_id 
INNER JOIN dbo.CalendarDimension ON dbo.BillFacts.FullDate = dbo.CalendarDimension.FullDate 
WHERE dbo.CalendarDimension.MonthNm = 'October' AND dbo.BillFacts.Past_Due_Amt > '0.00'