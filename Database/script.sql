USE [master]
GO
/****** Object:  Database [bera_a]    Script Date: 25.01.2019 12:48:48 ******/
CREATE DATABASE [bera_a]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'bera_a', FILENAME = N'/var/opt/mssql/data/bera_a.mdf' , SIZE = 10240KB , MAXSIZE = 30720KB , FILEGROWTH = 2048KB )
 LOG ON 
( NAME = N'bera_a_log', FILENAME = N'/var/opt/mssql/data/bera_a.ldf' , SIZE = 10240KB , MAXSIZE = 30720KB , FILEGROWTH = 2048KB )
GO
ALTER DATABASE [bera_a] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [bera_a].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [bera_a] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [bera_a] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [bera_a] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [bera_a] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [bera_a] SET ARITHABORT OFF 
GO
ALTER DATABASE [bera_a] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [bera_a] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [bera_a] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [bera_a] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [bera_a] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [bera_a] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [bera_a] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [bera_a] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [bera_a] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [bera_a] SET  ENABLE_BROKER 
GO
ALTER DATABASE [bera_a] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [bera_a] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [bera_a] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [bera_a] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [bera_a] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [bera_a] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [bera_a] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [bera_a] SET RECOVERY FULL 
GO
ALTER DATABASE [bera_a] SET  MULTI_USER 
GO
ALTER DATABASE [bera_a] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [bera_a] SET DB_CHAINING OFF 
GO
ALTER DATABASE [bera_a] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [bera_a] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [bera_a] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'bera_a', N'ON'
GO
ALTER DATABASE [bera_a] SET QUERY_STORE = OFF
GO
USE [bera_a]
GO
/****** Object:  UserDefinedFunction [dbo].[funcConfDayFreePlaces]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcConfDayFreePlaces]
( @ConferenceID int ,@ConfDayNumber int)
RETURNS int
AS
BEGIN
DECLARE @NumberOfPlaces int= dbo.funcConferenceNumberOfPlaces(@ConferenceID);

DECLARE @UsedPlaces int = dbo.funcConferenceDayTakenPlaces(@ConferenceID,@ConfDayNumber);

RETURN @NumberOfPlaces -@UsedPlaces
END


GO
/****** Object:  UserDefinedFunction [dbo].[funcConferenceDayTakenPlaces]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcConferenceDayTakenPlaces]
( @ConferenceID int, @ConfDayNumber int )
RETURNS INT
AS 
BEGIN
RETURN ( ISNULL( (SELECT sum(NormalQuantity + StudentQuantity)
				FROM DayReservation
				WHERE ConferenceID = @ConferenceID 
				AND ConfDayNumber = @ConfDayNumber  ),0))
END	
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferenceIDbyReservation]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[funcConferenceIDbyReservation]
(@ReservationID int)
returns int
as
begin
return ( ISNULL( (SELECT DR.ConferenceID
				FROM Reservations as R
				join DayReservation as DR on R.ReservationID=DR.ReservationID 
				WHERE R.ReservationID= @ReservationID  ),0))
end
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferenceNumberOfPlaces]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcConferenceNumberOfPlaces]
( @ConferenceID int )
RETURNS INT
AS 
BEGIN
RETURN ( ISNULL( (SELECT NumberOfPlaces 
				FROM Conferences
				WHERE ConferenceID =@ConferenceID),0) )
END	
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferenceParticipants]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcConferenceParticipants](@ConferenceID int)
RETURNS int
AS 
begin
RETURN
(SELECT COUNT(p.ParticipantID)
FROM dbo.DayReservation AS dr
JOIN dbo.Participants AS p ON p.DayReservationID=dr.DayReservationID
WHERE dr.ConferenceID=@ConferenceID)
end
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferencePrice]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[funcConferencePrice]
(@ConferenceID int)
returns money
as
begin
return (isnull((select price
				from Conferences
				where ConferenceID=@ConferenceID),0))
end
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferencePriceDiscount]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[funcConferencePriceDiscount]
(
@ConferenceID int,
@PaymentDate date
)
returns numeric(5,2)
as
begin
return (isnull((select a.discount
				from (  select TOP 1 discount, PaymentDate as minimal
						from ConferencePriceList
						where ConferenceID=@ConferenceID and @PaymentDate<=PaymentDate
						ORDER BY PaymentDate) as a),0))

end
GO
/****** Object:  UserDefinedFunction [dbo].[funcNormalQuantity]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[funcNormalQuantity]
(@ReservationID int)
returns int
as
begin
return (isnull((select SUM(normalquantity)
				from DayReservation
				where ReservationID=@ReservationID),0))
end
GO
/****** Object:  UserDefinedFunction [dbo].[funcParticipantCompanyName]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcParticipantCompanyName](@ParticipantID int)
RETURNS varchar(30)
AS
BEGIN
RETURN
ISNULL((SELECT c.CompanyName
FROM dbo.Companies AS c
JOIN dbo.Customers AS cu ON cu.CustomerID=c.CustomerID
JOIN dbo.Reservations AS r ON c.CustomerID=r.CustomerID
JOIN dbo.DayReservation AS dr ON r.ReservationID=dr.ReservationID
JOIN dbo.Participants AS p ON dr.DayReservationID=p.DayReservationID
WHERE p.ParticipantID=@ParticipantID)
,NULL)
END
GO
/****** Object:  UserDefinedFunction [dbo].[funcPayment]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcPayment]
( @ReservationID int )
returns money
as
begin
declare @normalprice money = 
(SELECT dbo.funcConferencePrice(C.ConferenceID) *
(1 - dbo.funcConferencePriceDiscount(C.ConferenceID, R.PaymentDate))
FROM Reservations as R
JOIN Conferences as C
ON C.ConferenceID = dbo.funcConferenceIDbyReservation(@ReservationID)
WHERE R.ReservationID = @reservationID)

declare @studentDiscount numeric(5,2) =
(select studentdiscount
from Conferences as c
where dbo.funcConferenceIDbyReservation(@ReservationID)=c.ConferenceID)

DECLARE @conferenceCost MONEY =
(Select dbo.funcNormalQuantity(@ReservationID) * @normalprice +
dbo.funcStudentQuantity(@ReservationID) * @normalprice * (1 - @studentDiscount)
From [DayReservation]
WHERE ReservationID = @reservationID)DECLARE @workshopCost MONEY =
(Select SUM(quantity * wd.price) 
FROM WorkshopReservation as WR
join DayReservation as DR on DR.DayReservationID = WR.DayReservationID
JOIN Workshops as W ON W.WorkshopID = WR.WorkshopID
join WorkshopDict as WD on WD.WorkshopTypeID=W.WorkshopType
join Reservations as r on r.ReservationID=DR.ReservationID
where r.ReservationID=@ReservationID)
return (isnull(@conferenceCost,0) + isnull(@workshopCost,0))
end
GO
/****** Object:  UserDefinedFunction [dbo].[funcStudentQuantity]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[funcStudentQuantity]
(@ReservationID int)
returns int
as
begin
return (isnull((select SUM(studentquantity)
				from DayReservation
				where ReservationID=@ReservationID),0))
end
GO
/****** Object:  UserDefinedFunction [dbo].[funcWorkshopFreePlaces]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcWorkshopFreePlaces]
( @WorkshopID int)
RETURNS int
AS
BEGIN
DECLARE @NumberOfPlaces int= dbo.funcWorkshopNumberOfPlaces(@WorkshopID);

DECLARE @UsedPlaces int = dbo.funcWorkshopTakenPlaces(@WorkshopID);

RETURN @NumberOfPlaces -@UsedPlaces
END
GO
/****** Object:  UserDefinedFunction [dbo].[funcWorkshopNumberOfPlaces]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[funcWorkshopNumberOfPlaces]
( @WorkshopID int )
RETURNS INT
AS 
BEGIN
RETURN ( ISNULL( (SELECT NumberOfPlaces 
				FROM Workshops
				WHERE WorkshopID =@WorkshopID),0) )
END
GO
/****** Object:  UserDefinedFunction [dbo].[funcWorkshopTakenPlaces]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcWorkshopTakenPlaces]
( @WorkshopID int )
RETURNS INT
AS 
BEGIN
RETURN ( ISNULL( (SELECT sum(Quantity)
				FROM WorkshopReservation
				WHERE WorkshopID= @WorkshopID  ),0))
END	
GO
/****** Object:  Table [dbo].[City]    Script Date: 25.01.2019 12:48:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City](
	[CityID] [int] IDENTITY(1,1) NOT NULL,
	[CountryCountryID] [int] NOT NULL,
	[CityName] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Companies]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Companies](
	[CustomerID] [int] NOT NULL,
	[CompanyName] [varchar](30) NOT NULL,
	[NIP] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[NIP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[NIP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Conferences]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Conferences](
	[ConferenceID] [int] IDENTITY(1,1) NOT NULL,
	[ConferenceName] [varchar](30) NOT NULL,
	[BeginDate] [date] NOT NULL,
	[EndDate] [date] NOT NULL,
	[StudentDiscount] [numeric](5, 2) NULL,
	[Price] [money] NOT NULL,
	[Description] [varchar](255) NULL,
	[NumberOfPlaces] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ConferenceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Country]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[CountryID] [int] IDENTITY(1,1) NOT NULL,
	[CountryName] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CountryName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CityID] [int] NOT NULL,
	[Address] [varchar](30) NOT NULL,
	[PostalCode] [varchar](30) NOT NULL,
	[Phone] [varchar](30) NOT NULL,
	[Email] [varchar](30) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Phone] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DayReservation]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DayReservation](
	[DayReservationID] [int] IDENTITY(1,1) NOT NULL,
	[ReservationID] [int] NOT NULL,
	[ConferenceID] [int] NOT NULL,
	[ConfDayNumber] [int] NOT NULL,
	[NormalQuantity] [int] NOT NULL,
	[StudentQuantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DayReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndividualClient]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndividualClient](
	[CustomerID] [int] NOT NULL,
	[PersonID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Person]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Person](
	[PersonID] [int] IDENTITY(1,1) NOT NULL,
	[Firstname] [varchar](30) NULL,
	[Lastname] [varchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[PersonID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reservations]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reservations](
	[ReservationID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[PaymentDate] [date] NULL,
	[ReservationDate] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkshopDict]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkshopDict](
	[WorkshopTypeID] [int] IDENTITY(1,1) NOT NULL,
	[WorkshopName] [varchar](30) NOT NULL,
	[Description] [varchar](255) NULL,
	[Price] [money] NULL,
	[NumberOfPlaces] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkshopTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WorkshopReservation]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkshopReservation](
	[WorkshopReservationID] [int] IDENTITY(1,1) NOT NULL,
	[DayReservationID] [int] NOT NULL,
	[WorkshopID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkshopReservationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Workshops]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Workshops](
	[WorkshopID] [int] IDENTITY(1,1) NOT NULL,
	[WorkshopType] [int] NOT NULL,
	[ConferenceID] [int] NOT NULL,
	[ConfDayNumber] [int] NOT NULL,
	[BeginHour] [time](7) NOT NULL,
	[EndHour] [time](7) NOT NULL,
	[Price] [money] NULL,
	[NumberOfPlaces] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkshopID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[funcInvoice]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[funcInvoice](@ReservationID int)
returns table
as 
return
(select 'Faktura' as Faktura
union all
select 'Dane klienta' as Dane
union all
select 'Company Name:'+CompanyName+'| NIP: '+NIP+'| Telefon: '+
Phone+'| E-mail: '+Email+'| Adres: '+CountryName+', '+CityName+', '+
Address+', '+PostalCode
from Companies as co
join Customers as c on co.CustomerID=c.CustomerID
join City on c.CityID=City.CityID
join Country on City.CountryCountryID=Country.CountryID
join Reservations as r on r.CustomerID=c.CustomerID
where ReservationID=@ReservationID
union all
select 'Imie:'+p.Firstname+'| Nazwisko: '+p.Lastname+'| Telefon: '+
Phone+'| E-mail: '+Email+'| Adres: '+CountryName+', '+CityName+', '+
Address+', '+PostalCode
from Person as p
join IndividualClient as ic on ic.PersonID=p.PersonID
join Customers as c on ic.CustomerID=c.CustomerID
join City on c.CityID=City.CityID
join Country on City.CountryCountryID=Country.CountryID
join Reservations as r on r.CustomerID=c.CustomerID
where ReservationID=@ReservationID
union all
select 'Rezerwacja dni konferencji, bilety normalne'
union all
select 'Nazwa konferencji: '+ConferenceName+'| Dzień: '+STR(dr.ConfDayNumber)+
'| Ilość biletów normalnych: '+str(dr.NormalQuantity)+'| Cena za bilet: '+
STR(Price)+'| Suma: '+
STR((dr.NormalQuantity*Price*(1-dbo.funcConferencePriceDiscount(c.ConferenceID, r.PaymentDate))))
from Conferences as c
join DayReservation as dr on dr.ConferenceID=c.ConferenceID
JOIN dbo.Reservations AS r ON r.ReservationID=dr.ReservationID
where dr.ReservationID=@ReservationID
GROUP BY c.ConferenceID, c.ConferenceName, dr.ConfDayNumber, dr.NormalQuantity, c.Price, r.PaymentDate
union all
select 'Rezerwacja dni konferencji, bilety studenckie'
union all
select 'Nazwa konferencji: '+ConferenceName+'| Dzień: '+str(dr.ConfDayNumber)+
'| Ilość biletów studenckich: '+STR(dr.StudentQuantity)+'| Cena za bilet: '+STR(Price)+
'| Zniżka studencka: '+convert(VARCHAR(10),c.StudentDiscount)+'| Suma: '+
STR((dr.StudentQuantity*Price*(1-c.StudentDiscount)*(1-dbo.funcConferencePriceDiscount(c.ConferenceID, r.PaymentDate))))
from Conferences as c
join DayReservation as dr on dr.ConferenceID=c.ConferenceID
JOIN dbo.Reservations AS r ON r.ReservationID=dr.ReservationID
where dr.ReservationID=@ReservationID
GROUP BY c.ConferenceID, c.ConferenceName, dr.ConfDayNumber, dr.StudentQuantity, c.Price, c.StudentDiscount, r.PaymentDate
union all
select 'Rezerwacja warsztatów'
union all
select 'Nazwa warsztatu: '+WorkshopName+'| Dzień: '+STR(dr.ConfDayNumber)+
'| Ilość biletów: '+STR(wr.Quantity)+'| Cena za bilet: '+
STR(wd.Price)+'| Suma: '+STR((wr.Quantity*wd.Price))
from WorkshopDict as wd
join Workshops as w on wd.WorkshopTypeID=w.WorkshopType
join WorkshopReservation as wr on wr.WorkshopID=w.WorkshopID
join DayReservation as dr on dr.DayReservationID=wr.DayReservationID
where dr.ReservationID=@ReservationID
GROUP BY workshopname, dr.ConfDayNumber, wd.price, wr.Quantity
union all
select 'Podsumowanie'
union all
select 'Kwota do zapłaty: '+STR(dbo.funcPayment(@ReservationID))
union all
select 'Data zapłaty: '+cast(PaymentDate AS VARCHAR(30))
from Reservations
where ReservationID=@ReservationID)
GO
/****** Object:  Table [dbo].[Participants]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Participants](
	[ParticipantID] [int] IDENTITY(1,1) NOT NULL,
	[DayReservationID] [int] NOT NULL,
	[PersonID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParticipantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[funcIDforParticipant]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcIDforParticipant]( @ParticipantID int )
RETURNS TABLE
AS 
RETURN
(SELECT p.Firstname, p.Lastname, co.CompanyName 
FROM dbo.Participants AS pa
JOIN dbo.Person AS p ON p.PersonID=pa.PersonID
JOIN dbo.DayReservation AS dr ON dr.DayReservationID=pa.DayReservationID
JOIN dbo.Reservations AS r ON r.ReservationID=dr.ReservationID
JOIN dbo.Customers AS c ON c.CustomerID=r.CustomerID
LEFT JOIN dbo.Companies AS co ON c.CustomerID=co.CustomerID
WHERE pa.ParticipantID=@ParticipantID)
GO
/****** Object:  View [dbo].[upcomingConferences]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[upcomingConferences]
AS
SELECT        ConferenceID, ConferenceName, Description, BeginDate, EndDate, Price, NumberOfPlaces, StudentDiscount
FROM            dbo.Conferences
WHERE        (BeginDate > GETDATE())
GO
/****** Object:  Table [dbo].[ConferenceDays]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConferenceDays](
	[ConferenceID] [int] NOT NULL,
	[DayNumber] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ConferenceID] ASC,
	[DayNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[upcomingWorkshops]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[upcomingWorkshops]
AS
SELECT        dbo.Workshops.WorkshopID, dbo.WorkshopDict.WorkshopName, dbo.WorkshopDict.Description, dbo.Conferences.ConferenceName, dbo.Workshops.ConfDayNumber, dbo.Workshops.BeginHour, dbo.Workshops.EndHour, 
                         dbo.Workshops.Price, dbo.Workshops.NumberOfPlaces, dbo.Workshops.NumberOfPlaces - SUM(dbo.WorkshopReservation.Quantity) AS [Places Left]
FROM            dbo.ConferenceDays INNER JOIN
                         dbo.Conferences ON dbo.ConferenceDays.ConferenceID = dbo.Conferences.ConferenceID INNER JOIN
                         dbo.Workshops ON dbo.ConferenceDays.ConferenceID = dbo.Workshops.ConferenceID AND dbo.ConferenceDays.DayNumber = dbo.Workshops.ConfDayNumber INNER JOIN
                         dbo.WorkshopDict ON dbo.Workshops.WorkshopType = dbo.WorkshopDict.WorkshopTypeID INNER JOIN
                         dbo.WorkshopReservation ON dbo.Workshops.WorkshopID = dbo.WorkshopReservation.WorkshopID
WHERE        (dbo.Conferences.BeginDate > GETDATE())
GROUP BY dbo.Workshops.WorkshopID, dbo.WorkshopDict.WorkshopName, dbo.WorkshopDict.Description, dbo.Conferences.ConferenceName, dbo.Workshops.ConfDayNumber, dbo.Workshops.BeginHour, dbo.Workshops.EndHour, 
                         dbo.Workshops.Price, dbo.Workshops.NumberOfPlaces
GO
/****** Object:  Table [dbo].[ConferencePriceList]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ConferencePriceList](
	[ConferenceID] [int] NOT NULL,
	[PaymentDate] [date] NOT NULL,
	[Discount] [numeric](5, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[ConferenceID] ASC,
	[PaymentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[conferencePrices]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[conferencePrices]
AS
SELECT        TOP (100) PERCENT dbo.Conferences.ConferenceID, dbo.Conferences.ConferenceName, dbo.ConferencePriceList.PaymentDate AS [Pay Before], dbo.Conferences.Price * (1 - dbo.ConferencePriceList.Discount) AS Price
FROM            dbo.ConferencePriceList INNER JOIN
                         dbo.Conferences ON dbo.ConferencePriceList.ConferenceID = dbo.Conferences.ConferenceID
ORDER BY dbo.Conferences.ConferenceID
GO
/****** Object:  View [dbo].[mostPopularWorkshops]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mostPopularWorkshops]
AS
SELECT        TOP (100) PERCENT dbo.WorkshopDict.WorkshopTypeID, dbo.WorkshopDict.WorkshopName, dbo.WorkshopDict.Description, SUM(dbo.WorkshopReservation.Quantity) AS PlacesSum
FROM            dbo.WorkshopDict INNER JOIN
                         dbo.Workshops ON dbo.WorkshopDict.WorkshopTypeID = dbo.Workshops.WorkshopType INNER JOIN
                         dbo.WorkshopReservation ON dbo.Workshops.WorkshopID = dbo.WorkshopReservation.WorkshopID
GROUP BY dbo.WorkshopDict.WorkshopTypeID, dbo.WorkshopDict.WorkshopName, dbo.WorkshopDict.Description
ORDER BY PlacesSum DESC
GO
/****** Object:  View [dbo].[mostPopularConferences]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[mostPopularConferences]
AS
SELECT        TOP (100) PERCENT dbo.Conferences.ConferenceID, dbo.Conferences.ConferenceName, dbo.Conferences.Description, SUM(dbo.DayReservation.NormalQuantity) + SUM(dbo.DayReservation.StudentQuantity) 
                         AS PlacesSum
FROM            dbo.ConferenceDays INNER JOIN
                         dbo.Conferences ON dbo.ConferenceDays.ConferenceID = dbo.Conferences.ConferenceID INNER JOIN
                         dbo.DayReservation ON dbo.ConferenceDays.ConferenceID = dbo.DayReservation.ConferenceID AND dbo.ConferenceDays.DayNumber = dbo.DayReservation.ConfDayNumber
GROUP BY dbo.Conferences.ConferenceID, dbo.Conferences.ConferenceName, dbo.Conferences.Description
ORDER BY PlacesSum DESC
GO
/****** Object:  View [dbo].[topCompanyClients]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[topCompanyClients]
AS
SELECT        TOP (100) PERCENT dbo.Companies.CustomerID, dbo.Companies.CompanyName, SUM(dbo.DayReservation.NormalQuantity) + SUM(dbo.DayReservation.StudentQuantity) AS [Reserved And Paid Places]
FROM            dbo.Companies INNER JOIN
                         dbo.Customers ON dbo.Companies.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.Reservations ON dbo.Customers.CustomerID = dbo.Reservations.CustomerID INNER JOIN
                         dbo.DayReservation ON dbo.Reservations.ReservationID = dbo.DayReservation.ReservationID
WHERE        (dbo.Reservations.PaymentDate IS NOT NULL)
GROUP BY dbo.Companies.CustomerID, dbo.Companies.CompanyName
ORDER BY [Reserved And Paid Places] DESC
GO
/****** Object:  View [dbo].[topIndividualClients]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[topIndividualClients]
AS
SELECT        TOP (100) PERCENT dbo.Customers.CustomerID, dbo.Person.Firstname + ' ' + dbo.Person.Lastname AS [Client Name], COUNT(dbo.Reservations.ReservationID) AS [Reserved And Paid Places]
FROM            dbo.Customers INNER JOIN
                         dbo.IndividualClient ON dbo.Customers.CustomerID = dbo.IndividualClient.CustomerID INNER JOIN
                         dbo.Person ON dbo.IndividualClient.PersonID = dbo.Person.PersonID INNER JOIN
                         dbo.Reservations ON dbo.Customers.CustomerID = dbo.Reservations.CustomerID
WHERE        (dbo.Reservations.PaymentDate IS NOT NULL)
GROUP BY dbo.Customers.CustomerID, dbo.Person.Firstname + ' ' + dbo.Person.Lastname
ORDER BY [Reserved And Paid Places] DESC
GO
/****** Object:  View [dbo].[unpaidCompanyReservations]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[unpaidCompanyReservations]
AS
SELECT        dbo.Companies.CustomerID, dbo.Companies.CompanyName, dbo.Reservations.ReservationID, dbo.Reservations.ReservationDate, dbo.Customers.Phone, dbo.Customers.Email
FROM            dbo.Companies INNER JOIN
                         dbo.Customers ON dbo.Companies.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.Reservations ON dbo.Customers.CustomerID = dbo.Reservations.CustomerID
WHERE        (dbo.Reservations.PaymentDate IS NULL)
GO
/****** Object:  View [dbo].[unpaidIndividualReservations]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[unpaidIndividualReservations]
AS
SELECT        dbo.Customers.CustomerID, dbo.Person.Firstname + ' ' + dbo.Person.Lastname AS ClientName, dbo.Reservations.ReservationID, dbo.Reservations.ReservationDate, dbo.Customers.Phone, dbo.Customers.Email
FROM            dbo.Customers INNER JOIN
                         dbo.IndividualClient ON dbo.Customers.CustomerID = dbo.IndividualClient.CustomerID INNER JOIN
                         dbo.Person ON dbo.IndividualClient.PersonID = dbo.Person.PersonID INNER JOIN
                         dbo.Reservations ON dbo.Customers.CustomerID = dbo.Reservations.CustomerID
WHERE        (dbo.Reservations.PaymentDate IS NULL)
GO
/****** Object:  View [dbo].[unfilledCompanyReservations]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[unfilledCompanyReservations]
AS
SELECT        dbo.Reservations.ReservationID, dbo.Customers.CustomerID, dbo.Companies.CompanyName, dbo.Customers.Phone, dbo.Customers.Email
FROM            dbo.Reservations INNER JOIN
                         dbo.Customers ON dbo.Reservations.CustomerID = dbo.Customers.CustomerID INNER JOIN
                         dbo.Companies ON dbo.Customers.CustomerID = dbo.Companies.CustomerID
WHERE        (dbo.Reservations.ReservationID IN
                             (SELECT        Reservations_1.ReservationID
                               FROM            dbo.Reservations AS Reservations_1 INNER JOIN
                                                         dbo.DayReservation AS DayReservation_1 ON Reservations_1.ReservationID = DayReservation_1.ReservationID INNER JOIN
                                                         dbo.Participants AS Participants_1 ON DayReservation_1.DayReservationID = Participants_1.DayReservationID INNER JOIN
                                                         dbo.Person AS Person_1 ON Person_1.PersonID = Participants_1.PersonID
                               WHERE        (Person_1.Firstname IS NULL) AND (Person_1.Lastname IS NULL)))
GO
/****** Object:  View [dbo].[placesLeftPerConferenceDay]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[placesLeftPerConferenceDay]
AS
SELECT        dbo.Conferences.ConferenceID, dbo.Conferences.ConferenceName, dbo.ConferenceDays.DayNumber, dbo.Conferences.NumberOfPlaces - SUM(dbo.DayReservation.NormalQuantity) - SUM(dbo.DayReservation.StudentQuantity) 
                         AS [Places Left]
FROM            dbo.ConferenceDays INNER JOIN
                         dbo.Conferences ON dbo.ConferenceDays.ConferenceID = dbo.Conferences.ConferenceID INNER JOIN
                         dbo.DayReservation ON dbo.ConferenceDays.ConferenceID = dbo.DayReservation.ConferenceID AND dbo.ConferenceDays.DayNumber = dbo.DayReservation.ConfDayNumber
GROUP BY dbo.Conferences.ConferenceID, dbo.Conferences.ConferenceName, dbo.ConferenceDays.DayNumber, dbo.Conferences.NumberOfPlaces
GO
/****** Object:  UserDefinedFunction [dbo].[fp_NotPaidReservationsForCustomer]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fp_NotPaidReservationsForCustomer]
(
@CustomerID int
)
RETURNS TABLE
AS
RETURN
(
SELECT ReservationID, ConferenceName, BeginDate, EndDate
FROM dbo.Reservations
INNER JOIN dbo.Conferences
ON Conferences.ConferenceID = dbo.funcConferenceIDbyReservation(ReservationID)
INNER JOIN dbo.Customers
ON customers.CustomerID = Reservations.CustomerID
WHERE customers.CustomerID = @CustomerID AND PaymentDate IS NULL
)
GO
/****** Object:  Table [dbo].[WorkshopParticipant]    Script Date: 25.01.2019 12:48:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WorkshopParticipant](
	[WorkshopReservationID] [int] NOT NULL,
	[ParticipantID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[WorkshopReservationID] ASC,
	[ParticipantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[funcParticipantsInWorkshop]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcParticipantsInWorkshop]
(
@WorkshopID int
)
RETURNS TABLE
AS
RETURN
(
SELECT Firstname, Lastname
from Workshops
inner join WorkshopReservation
on workshops.WorkshopID=WorkshopReservation.WorkshopID
inner join WorkshopParticipant
on WorkshopParticipant.WorkshopReservationID=WorkshopReservation.WorkshopReservationID
INNER JOIN Participants
ON Participants.ParticipantID = WorkshopParticipant.ParticipantID
INNER JOIN Person
ON Person.PersonID = Participants.PersonID
where Workshops.WorkshopID=@WorkshopID
)
GO
/****** Object:  UserDefinedFunction [dbo].[funcParticipantsInConference]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcParticipantsInConference]
(
@ConferenceID int
)
RETURNS TABLE
AS
RETURN
(
SELECT Firstname, Lastname, dbo.funcParticipantCompanyName(p.ParticipantID) AS Company
FROM Conferences as c
join DayReservation as dr on c.ConferenceID=dr.ConferenceID
join Participants as p on p.DayReservationID=dr.DayReservationID
join Person as pe on pe.PersonID=p.PersonID
where c.ConferenceID=@ConferenceID
)
GO
/****** Object:  UserDefinedFunction [dbo].[funcActualReservationsForCustomer]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcActualReservationsForCustomer]
(
@CustomerID int
)
RETURNS TABLE
AS
RETURN
(
SELECT ReservationDate, PaymentDate, ConferenceName, BeginDate
FROM Reservations as r
INNER JOIN customers as c
ON C.CustomerID = R.CustomerID
INNER JOIN Conferences as co
ON Co.ConferenceID = dbo.funcConferenceIDbyReservation(r.ReservationID)
WHERE (DATEDIFF(day, BeginDate, R.ReservationDate) > 0)
AND (DATEDIFF(DAY, BeginDate, GETDATE()) > 0) and c.CustomerID=@CustomerID
)
GO
/****** Object:  UserDefinedFunction [dbo].[funcActualConferencesForPerson]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcActualConferencesForPerson]
(
@PersonID int
)
RETURNS TABLE
AS
RETURN
(
SELECT ConferenceName,BeginDate,EndDate
FROM dbo.Conferences
INNER JOIN Reservations
ON dbo.funcConferenceIDbyReservation(Reservations.ReservationID) = Conferences.ConferenceID
INNER JOIN DayReservation
ON DayReservation.ReservationID = Reservations.ReservationID
INNER JOIN Participants
ON Participants.DayReservationID =DayReservation.DayReservationID
INNER JOIN Person
ON Person.PersonID = Participants.PersonID
AND Person.PersonID = @PersonID
WHERE (DATEDIFF(day, BeginDate, Reservations.ReservationDate) > 0)
AND (DATEDIFF(DAY, BeginDate, GETDATE()) > 0) 
)
GO
/****** Object:  UserDefinedFunction [dbo].[fp_ActualWorkshopsForPerson]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fp_ActualWorkshopsForPerson]
(
@PersonID int
)
RETURNS TABLE
AS
RETURN
(
SELECT WorkshopName,workshopdict.Description,BeginDate,BeginHour,EndHour
FROM WorkshopDict
INNER JOIN Workshops
ON Workshops.WorkshopType = WorkshopDict.WorkshopTypeID
INNER JOIN Conferences
ON Conferences.ConferenceID = Workshops.ConferenceID
INNER JOIN WorkshopReservation
ON WorkshopReservation.WorkshopID =Workshops.WorkshopID
INNER JOIN DayReservation
ON DayReservation.DayReservationID =DayReservation.DayReservationID
INNER JOIN Participants
ON Participants.DayReservationID =DayReservation.DayReservationID
INNER JOIN Person
ON Person.PersonID = Participants.PersonID
AND Participants.PersonID = @PersonID
)
GO
/****** Object:  UserDefinedFunction [dbo].[funcParticipantsInConferenceDay]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcParticipantsInConferenceDay]
(
@ConferenceDayID int
)
RETURNS TABLE
AS
RETURN
(
SELECT Firstname, Lastname
FROM Person
INNER JOIN Participants
ON Person.PersonID = Participants.PersonID
INNER JOIN DayReservation
on DayReservation.DayReservationID=Participants.DayReservationID 
AND DayReservation.DayReservationID = @ConferenceDayID
)
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferencesPerDay]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcConferencesPerDay]( @Date date )
RETURNS TABLE
AS
RETURN
(SELECT * FROM Conferences
WHERE BeginDate <= @Date AND EndDate >= @Date )
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferencesPerTimeFrame]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcConferencesPerTimeFrame]( @BeginDate date, @EndDate date )
RETURNS TABLE
AS
RETURN
(SELECT * FROM Conferences
WHERE BeginDate >= @BeginDate AND EndDate <= @EndDate )
GO
/****** Object:  UserDefinedFunction [dbo].[funcActualConferenceDaysForPerson]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcActualConferenceDaysForPerson]
(
@PersonID int
)
RETURNS TABLE
AS
RETURN
(
SELECT distinct c.ConferenceID, ConferenceName,BeginDate, EndDate, Description, DayNumber
FROM Conferences as c
join ConferenceDays as cd on c.ConferenceID=cd.ConferenceID 
join DayReservation as dr on dr.ConferenceID=cd.ConferenceID and dr.ConfDayNumber=cd.DayNumber
join Participants as p on p.DayReservationID=dr.DayReservationID
join Person as pe on pe.PersonID=p.PersonID
where pe.PersonID=@PersonID
)
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferenceDaysForReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[funcConferenceDaysForReservation](@ReservationID int)
returns table
as
return
(select c.ConferenceName, cd.DayNumber, dr.NormalQuantity as 'liczba biletów normalnych',
dr.StudentQuantity as 'liczba biletów studenckich'
from Conferences as c
join ConferenceDays as cd on cd.ConferenceID=c.ConferenceID
join DayReservation as dr on dr.ConferenceID=cd.ConferenceID and dr.ConfDayNumber=cd.DayNumber
where dr.ReservationID=@ReservationID)
GO
/****** Object:  UserDefinedFunction [dbo].[funcWorkshopsForReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [dbo].[funcWorkshopsForReservation](@ReservationID int)
returns table
as 
return
(select wd.WorkshopName, w.ConfDayNumber, wr.Quantity as 'liczba zarezerwowanych miejsc'
from WorkshopDict as wd
join Workshops as w on w.WorkshopType=wd.WorkshopTypeID
join WorkshopReservation as wr on wr.WorkshopID=w.WorkshopID
join DayReservation as dr on dr.DayReservationID=wr.DayReservationID
where dr.ReservationID=@ReservationID)
GO
/****** Object:  UserDefinedFunction [dbo].[funcConferenceDaysOfConference]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcConferenceDaysOfConference](@ConferenceID int)
RETURNS TABLE
AS
RETURN
(SELECT * FROM ConferenceDays WHERE ConferenceID = @ConferenceID)
GO
/****** Object:  UserDefinedFunction [dbo].[funcWorkshopOfConferenceDay]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[funcWorkshopOfConferenceDay](@ConferenceID int, @ConferenceDayNumber int)
RETURNS TABLE
AS
RETURN
(SELECT w.ConferenceID, w.ConfDayNumber as 'Dzień konferencji', w.WorkshopID,
wd.WorkshopName, w.BeginHour, w.EndHour, wd.Description,w.NumberOfPlaces 
from Workshops as w
join WorkshopDict as wd on wd.WorkshopTypeID=w.WorkshopType
where w.ConferenceID=@ConferenceID and w.ConfDayNumber=@ConferenceDayNumber)
GO
/****** Object:  Table [dbo].[Student]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Student](
	[ParticipantID] [int] NOT NULL,
	[StudentIDCard] [varchar](10) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParticipantID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ConferencePriceList] ADD  DEFAULT ((0)) FOR [Discount]
GO
ALTER TABLE [dbo].[Conferences] ADD  DEFAULT ((0)) FOR [StudentDiscount]
GO
ALTER TABLE [dbo].[WorkshopDict] ADD  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[Workshops] ADD  DEFAULT ((0)) FOR [Price]
GO
ALTER TABLE [dbo].[City]  WITH CHECK ADD  CONSTRAINT [FKCity] FOREIGN KEY([CountryCountryID])
REFERENCES [dbo].[Country] ([CountryID])
GO
ALTER TABLE [dbo].[City] CHECK CONSTRAINT [FKCity]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD  CONSTRAINT [FKCompanies1] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Companies] CHECK CONSTRAINT [FKCompanies1]
GO
ALTER TABLE [dbo].[ConferenceDays]  WITH CHECK ADD  CONSTRAINT [FKConference2] FOREIGN KEY([ConferenceID])
REFERENCES [dbo].[Conferences] ([ConferenceID])
GO
ALTER TABLE [dbo].[ConferenceDays] CHECK CONSTRAINT [FKConference2]
GO
ALTER TABLE [dbo].[ConferencePriceList]  WITH CHECK ADD  CONSTRAINT [FKConference1] FOREIGN KEY([ConferenceID])
REFERENCES [dbo].[Conferences] ([ConferenceID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ConferencePriceList] CHECK CONSTRAINT [FKConference1]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [FKCustomers] FOREIGN KEY([CityID])
REFERENCES [dbo].[City] ([CityID])
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [FKCustomers]
GO
ALTER TABLE [dbo].[DayReservation]  WITH CHECK ADD  CONSTRAINT [FKDayReserva] FOREIGN KEY([ConferenceID], [ConfDayNumber])
REFERENCES [dbo].[ConferenceDays] ([ConferenceID], [DayNumber])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DayReservation] CHECK CONSTRAINT [FKDayReserva]
GO
ALTER TABLE [dbo].[DayReservation]  WITH CHECK ADD  CONSTRAINT [FKDayReserva1] FOREIGN KEY([ReservationID])
REFERENCES [dbo].[Reservations] ([ReservationID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DayReservation] CHECK CONSTRAINT [FKDayReserva1]
GO
ALTER TABLE [dbo].[IndividualClient]  WITH CHECK ADD  CONSTRAINT [FKIndividual1] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[IndividualClient] CHECK CONSTRAINT [FKIndividual1]
GO
ALTER TABLE [dbo].[IndividualClient]  WITH CHECK ADD  CONSTRAINT [FKIndividual2] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[IndividualClient] CHECK CONSTRAINT [FKIndividual2]
GO
ALTER TABLE [dbo].[Participants]  WITH CHECK ADD  CONSTRAINT [FKParticipantDay] FOREIGN KEY([DayReservationID])
REFERENCES [dbo].[DayReservation] ([DayReservationID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Participants] CHECK CONSTRAINT [FKParticipantDay]
GO
ALTER TABLE [dbo].[Participants]  WITH CHECK ADD  CONSTRAINT [FKParticipantPerson] FOREIGN KEY([PersonID])
REFERENCES [dbo].[Person] ([PersonID])
GO
ALTER TABLE [dbo].[Participants] CHECK CONSTRAINT [FKParticipantPerson]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [FKReservatio] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [FKReservatio]
GO
ALTER TABLE [dbo].[Student]  WITH CHECK ADD  CONSTRAINT [FKStudent] FOREIGN KEY([ParticipantID])
REFERENCES [dbo].[Participants] ([ParticipantID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Student] CHECK CONSTRAINT [FKStudent]
GO
ALTER TABLE [dbo].[WorkshopParticipant]  WITH CHECK ADD  CONSTRAINT [FKWorkshopPaPart] FOREIGN KEY([ParticipantID])
REFERENCES [dbo].[Participants] ([ParticipantID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WorkshopParticipant] CHECK CONSTRAINT [FKWorkshopPaPart]
GO
ALTER TABLE [dbo].[WorkshopParticipant]  WITH CHECK ADD  CONSTRAINT [FKWorkshopPaWorksh] FOREIGN KEY([WorkshopReservationID])
REFERENCES [dbo].[WorkshopReservation] ([WorkshopReservationID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WorkshopParticipant] CHECK CONSTRAINT [FKWorkshopPaWorksh]
GO
ALTER TABLE [dbo].[WorkshopReservation]  WITH CHECK ADD  CONSTRAINT [FKWorkshopRe1] FOREIGN KEY([WorkshopID])
REFERENCES [dbo].[Workshops] ([WorkshopID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[WorkshopReservation] CHECK CONSTRAINT [FKWorkshopRe1]
GO
ALTER TABLE [dbo].[WorkshopReservation]  WITH CHECK ADD  CONSTRAINT [FKWorkshopRe2] FOREIGN KEY([DayReservationID])
REFERENCES [dbo].[DayReservation] ([DayReservationID])
GO
ALTER TABLE [dbo].[WorkshopReservation] CHECK CONSTRAINT [FKWorkshopRe2]
GO
ALTER TABLE [dbo].[Workshops]  WITH CHECK ADD  CONSTRAINT [FKWorkshops1] FOREIGN KEY([WorkshopType])
REFERENCES [dbo].[WorkshopDict] ([WorkshopTypeID])
GO
ALTER TABLE [dbo].[Workshops] CHECK CONSTRAINT [FKWorkshops1]
GO
ALTER TABLE [dbo].[Workshops]  WITH CHECK ADD  CONSTRAINT [FKWorkshops2] FOREIGN KEY([ConferenceID], [ConfDayNumber])
REFERENCES [dbo].[ConferenceDays] ([ConferenceID], [DayNumber])
GO
ALTER TABLE [dbo].[Workshops] CHECK CONSTRAINT [FKWorkshops2]
GO
ALTER TABLE [dbo].[Companies]  WITH CHECK ADD  CONSTRAINT [NIPnumeric] CHECK  ((isnumeric([NIP])=(1) AND len([NIP])=(10)))
GO
ALTER TABLE [dbo].[Companies] CHECK CONSTRAINT [NIPnumeric]
GO
ALTER TABLE [dbo].[ConferenceDays]  WITH CHECK ADD  CONSTRAINT [positiveDayNumb] CHECK  (([DayNumber]>(0)))
GO
ALTER TABLE [dbo].[ConferenceDays] CHECK CONSTRAINT [positiveDayNumb]
GO
ALTER TABLE [dbo].[ConferencePriceList]  WITH CHECK ADD  CONSTRAINT [discountBetween] CHECK  (([Discount]<=(1) AND [Discount]>=(0)))
GO
ALTER TABLE [dbo].[ConferencePriceList] CHECK CONSTRAINT [discountBetween]
GO
ALTER TABLE [dbo].[Conferences]  WITH CHECK ADD  CONSTRAINT [dateCorrectness] CHECK  (([BeginDate]<=[EndDate]))
GO
ALTER TABLE [dbo].[Conferences] CHECK CONSTRAINT [dateCorrectness]
GO
ALTER TABLE [dbo].[Conferences]  WITH CHECK ADD  CONSTRAINT [numberOfPlacesPositive] CHECK  (([NumberOfPlaces]>(0)))
GO
ALTER TABLE [dbo].[Conferences] CHECK CONSTRAINT [numberOfPlacesPositive]
GO
ALTER TABLE [dbo].[Conferences]  WITH CHECK ADD  CONSTRAINT [studentDiscountBetween] CHECK  (([StudentDiscount]<=(1) AND [StudentDiscount]>=(0)))
GO
ALTER TABLE [dbo].[Conferences] CHECK CONSTRAINT [studentDiscountBetween]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [customerEmail] CHECK  (([Email] like '%@%.%'))
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [customerEmail]
GO
ALTER TABLE [dbo].[Customers]  WITH CHECK ADD  CONSTRAINT [customerPhone] CHECK  (([Phone] like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'))
GO
ALTER TABLE [dbo].[Customers] CHECK CONSTRAINT [customerPhone]
GO
ALTER TABLE [dbo].[DayReservation]  WITH CHECK ADD  CONSTRAINT [normalQuantityPositive] CHECK  (([NormalQuantity]>=(0)))
GO
ALTER TABLE [dbo].[DayReservation] CHECK CONSTRAINT [normalQuantityPositive]
GO
ALTER TABLE [dbo].[DayReservation]  WITH CHECK ADD  CONSTRAINT [reservationPositiveDayNumber] CHECK  (([ConfDayNumber]>(0)))
GO
ALTER TABLE [dbo].[DayReservation] CHECK CONSTRAINT [reservationPositiveDayNumber]
GO
ALTER TABLE [dbo].[DayReservation]  WITH CHECK ADD  CONSTRAINT [studentQuantityPositive] CHECK  (([StudentQuantity]>=(0)))
GO
ALTER TABLE [dbo].[DayReservation] CHECK CONSTRAINT [studentQuantityPositive]
GO
ALTER TABLE [dbo].[Reservations]  WITH CHECK ADD  CONSTRAINT [paymentReservationDateCorrectness] CHECK  (([PaymentDate]>=[ReservationDate]))
GO
ALTER TABLE [dbo].[Reservations] CHECK CONSTRAINT [paymentReservationDateCorrectness]
GO
ALTER TABLE [dbo].[WorkshopDict]  WITH CHECK ADD  CONSTRAINT [workshopPlacesPositive] CHECK  (([NumberOfPlaces]>(0)))
GO
ALTER TABLE [dbo].[WorkshopDict] CHECK CONSTRAINT [workshopPlacesPositive]
GO
ALTER TABLE [dbo].[WorkshopReservation]  WITH CHECK ADD  CONSTRAINT [workshopReservationQuantityPositive] CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[WorkshopReservation] CHECK CONSTRAINT [workshopReservationQuantityPositive]
GO
ALTER TABLE [dbo].[Workshops]  WITH CHECK ADD  CONSTRAINT [workshopInstancePlacesPositive] CHECK  (([NumberOfPlaces]>(0)))
GO
ALTER TABLE [dbo].[Workshops] CHECK CONSTRAINT [workshopInstancePlacesPositive]
GO
/****** Object:  StoredProcedure [dbo].[procCreateBlankStudent]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateBlankStudent]
	@DayReservationID int,
	@StudentIDCard varchar(10),
	@ParticipantID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			EXEC procCreateUpdateParticipantCompany
			@DayReservationID,null,null,@StudentIDCard,
			@ParticipantID = @ParticipantID OUT 
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu blank studenta' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateCity]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateCity]
	@CityName varchar(30),
	@CountryName varchar(30),
	@CityID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
			BEGIN TRANSACTION 
				SET @CityID = NULL
				BEGIN
					DECLARE @CountryID int 
					EXEC procCreateCountry
						@CountryName,
						@CountryID = @CountryID OUT
					SET @CityID = (SELECT CityID 
										FROM City
										WHERE City.CityName= @CityName and City.CountryCountryID= @CountryID)
					IF(@CityID IS NULL)
					BEGIN 
						INSERT INTO City(CityName,CountryCountryID)
						VALUES(@CityName,@CountryID);
						SET @CityID = @@IDENTITY;
					END
				END
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH 
			ROLLBACK TRANSACTION
			DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu miasta' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
			THROW 52000,@msg,1;
		END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[procCreateCompany]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateCompany]
	@CompanyName varchar(30),
	@NIP varchar(10),
	@Email varchar(30),
	@Phone varchar(30),
	@PostalCode varchar(30),
	@Address varchar(30),
	@CityName varchar(30),
	@CountryName varchar(30),
	@CustomerID int OUTPUT
AS	
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			EXEC procCreateCustomer
				@Email,
				@Phone,
				@PostalCode,
				@Address,
				@CityName,
				@CountryName,
				@CustomerID=@CustomerID OUTPUT

			INSERT INTO Companies(CustomerID,CompanyName,NIP)
			VALUES (@CustomerID,@CompanyName,@NIP);
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu firmy ' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateConference]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateConference]
	@ConferenceName varchar(30),
	@BegDate varchar(10),
	@EnDate varchar(10),
	@StudentDiscount numeric(5,2),
	@Price money,
	@Description varchar(255),
	@NumberOfPlaces int,
	@ConferenceID int OUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION

		BEGIN TRY
			DECLARE @BeginDate date = convert (date, @BegDate)
			DECLARE @EndDate date = convert (date, @EnDate)
		END TRY
		BEGIN CATCH
		;THROW 52000,
				'Niepoprawny format daty wprowadzonej konferencji',1;
		END CATCH

		DECLARE @Length int = DATEDIFF(day,@BeginDate,@EndDate) +1;

			IF(@BeginDate < GETDATE())
			BEGIN
				;THROW 52000,
				'Niepoprawna Data konferencji, jej początek jest przed dniem dzisiejszym',1;
			END

			INSERT INTO Conferences(ConferenceName,BeginDate,EndDate,StudentDiscount,Price,Description,NumberOfPlaces)
			VALUES (@ConferenceName,@BeginDate,@EndDate,@StudentDiscount,@Price,@Description,@NumberOfPlaces);
			SET @ConferenceID = @@IDENTITY;

			DECLARE @DayNumber int = 1
			WHILE @DayNumber <= @Length
			BEGIN 
				INSERT INTO ConferenceDays (ConferenceID,DayNumber)
				VALUES (@ConferenceID,@DayNumber);
				SET @DayNumber =@DayNumber +1;
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu konferencji ' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateConferencePrice]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateConferencePrice]
	@ConferenceID int,
	@PayDate varchar(10),
	@Discount numeric(5,2)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

		BEGIN TRY
			DECLARE @PaymentDate date = convert (date, @PayDate)
		END TRY
		BEGIN CATCH
		;THROW 52000,
				'Niepoprawny format daty wprowadzonej konferencji',1;
		END CATCH

		BEGIN TRANSACTION
			IF(day(@PaymentDate) <day( GETDate()))
			BEGIN
				;THROW 52000,
				'Niepoprawna data, wcześniejsza niż dzień dzisiejszy',1;
			END

			IF(@PaymentDate >( SELECT BeginDate 
								FROM  Conferences
								WHERE Conferences.ConferenceID =@ConferenceID))
			BEGIN
				;THROW 52000,
				'Niepoprawna data, późniejsza niż dzień rozpoczęcia konferencji',1;
			END

			IF(@PaymentDate IN ( SELECT PaymentDate
								FROM ConferencePriceList
								WHERE ConferenceID=@ConferenceID AND PaymentDate= @PaymentDate))
			BEGIN 
				;THROW 52000,
				'Niepoprawna data, istnieje już próg dla tej daty',1;
			END
			INSERT INTO ConferencePriceList(ConferenceID,PaymentDate,Discount)
			VALUES (@ConferenceID,@PaymentDate,@Discount);

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu progu cenowego ' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateCountry]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateCountry]
	@CountryName varchar(30),
	@CountryID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
			BEGIN TRANSACTION 
				SET	@CountryID = ( SELECT CountryID
									FROM Country
									WHERE Country.CountryName = @CountryName)
				IF(@CountryID IS NULL) 
				BEGIN 
					INSERT INTO Country(CountryName)
					VAlUES (@CountryName);
					SET @CountryID =@@IDENTITY;
				END
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH 
			ROLLBACK TRANSACTION
			DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu kraju' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
			THROW 52000,@msg,1;
		END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[procCreateCustomer]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateCustomer]
	@Email varchar(30),
	@Phone varchar(30),
	@PostalCode varchar(30),
	@Address varchar(30),
	@CityName varchar(30),
	@CountryName varchar(30),
	@CustomerID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		DECLARE @CityID int
		Exec procCreateCity 
			@CityName,
			@CountryName,
			@CityID= @CityID OUTPUT
		INSERT INTO Customers(Email,Phone,PostalCode,Address,CityID)
		VALUES (@Email,@Phone,@PostalCode,@Address,@CityID);
		SET @CustomerID =@@IDENTITY
		END TRY
		BEGIN CATCH 
			DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu klienta' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
			THROW 52000,@msg,1;
		END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[procCreateDayReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateDayReservation]
	@ReservationID int,
	@ConferenceID int,
	@ConfDayNumber int,
	@NormalQuantity int =0,
	@StudentQuantity int =0,
	@DayReservationID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			IF( (SELECT count(*) 
				FROM DayReservation
				WHERE ReservationID = @ReservationID 
				AND ConferenceID = @ConferenceID 
				AND ConfDayNumber = @ConfDayNumber) >0 )
			BEGIN
				;THROW 52000,
				'Na ten dzień dokonano już rezerwacji w ramach rezerwacji konferencji',1;
			END

			IF( @NormalQuantity  + @StudentQuantity =0 )
			BEGIN
				;THROW 52000,
				'Nie można rezerwować 0 miejsc',1;
			END

			IF( dbo.funcConfDayFreePlaces(@ConferenceID, @ConfDayNumber) < @StudentQuantity + @NormalQuantity)
			BEGIN
				;THROW 52000,
				'Za mało miejsc na konferencji',1;
			END
			INSERT INTO DayReservation (ReservationID,ConferenceID,ConfDayNumber,NormalQuantity,StudentQuantity)
			VALUES (@ReservationID,@ConferenceID,@ConfDayNumber,@NormalQuantity,@StudentQuantity);
			SET @DayReservationID = @@IDENTITY;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu rezerwacji dnia' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateDayReservationIndiv]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateDayReservationIndiv]
	@ReservationID int,
	@ConferenceID int,
	@ConfDayNumber int,
	@StudentIDCard varchar(10)=null,
	@DayReservationID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			
			DECLARE @StudentQuantity int =0
			DECLARE @NormalQuantity int =1
			IF(@StudentIDCard IS NOT NULL)
			BEGIN
				SET @StudentQuantity = 1
				SET @NormalQuantity =0
			END
			DECLARE @PersonID int = ( SELECT top 1 Person.PersonID
										FROM Reservations INNER JOIN IndividualClient
										ON IndividualClient.CustomerID = Reservations.CustomerID
										INNER JOIN  Person ON Person.PersonID = IndividualClient.PersonID)

			EXEC procCreateDayReservation
			@ReservationID, @ConferenceID,@ConfDayNumber,@NormalQuantity,@StudentQuantity,
			@DayReservationID= @DayReservationID OUT

			INSERT INTO Participants(DayReservationID,PersonID)
			VALUES (@DayReservationID,@PersonID)
			DECLARE @ParticipantID int = @@IDENTITY

			IF(@StudentIDCard IS NOT NULL)
			BEGIN
				INSERT INTO Student(ParticipantID,StudentIDCard)
				VALUES (@ParticipantID,@StudentIDCard) 
			END
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu rezerwacji dnia' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateIndividual]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateIndividual]
	@Firstname varchar(30),
	@Lastname varchar(10),
	@Email varchar(30),
	@Phone varchar(30),
	@PostalCode varchar(30),
	@Address varchar(30),
	@CityName varchar(30),
	@CountryName varchar(30),
	@CustomerID int OUTPUT
AS	
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		BEGIN TRANSACTION
			DECLARE @PersonID int

			EXEC procCreateCustomer
				@Email,
				@Phone,
				@PostalCode,
				@Address,
				@CityName,
				@CountryName,
				@CustomerID=@CustomerID OUTPUT

			EXEC procCreatePerson
				@Firstname,
				@Lastname,
				@PersonID = @PersonId OUTPUT

			INSERT INTO IndividualClient(CustomerID,PersonID)
			VALUES (@CustomerID,@PersonID);
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu klienta indywidualnego ' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreatePerson]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreatePerson]
	@Firstname varchar(30),
	@Lastname varchar(30),
	@PersonID int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		INSERT INTO Person(Firstname,Lastname)
		VALUES (@Firstname,@Lastname);
		SET @PersonID= @@IDENTITY
	END TRY
	BEGIN CATCH 
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu danych osobowych' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateReservation]
	@CustomerID int,
	@ReservationID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION 
			DECLARE @Date date = GETDATE()
			INSERT INTO Reservations (CustomerID,ReservationDate)
			VALUES (@CustomerID,@Date);

			SET @ReservationID = @@IDENTITY
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu rezerwacji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateUpdateParticipantCompany]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateUpdateParticipantCompany]
	@DayReservationID int,
	@Firstname varchar(30),
	@Lastname varchar(30),
	@StudentIDCard varchar(10),
	@ParticipantID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @PersonID int
			IF(@FirstName IS NOT NULL AND @Lastname IS NOT NULL 
			AND @StudentIDCard IS NOT NULL) -- uzupelniam dane dla studenta
			BEGIN
				
				SET @ParticipantID = (SELECT Student.ParticipantID 
										FROM Student INNER JOIN Participants
										ON Student.ParticipantId = Participants.ParticipantID
										WHERE Student.StudentIDCard = @StudentIDCard
										AND DayReservationID= @DayReservationID)
				IF (@ParticipantID IS NULL)
				BEGIN
					;THROW 52000,
					'W podanej rezerwacji dnia konferencji nie ma studenta o takiej legitymacji',1;
				END
				SET @PersonID = (SELECT PersonID 
								FROM Participants
								WHERE ParticipantID=@ParticipantID)
				UPDATE Person SET 
					Firstname= @Firstname,
					Lastname = @Lastname
				WHERE Person.PersonID = @PersonID

			END
			
			IF(@Firstname IS NULL AND @Lastname IS NULL 
			AND @StudentIDCard IS NOT NULL) -- tworze blank studenta 
			BEGIN
				
				EXEC procCreatePerson
					@Firstname,@Lastname,
					@PersonId= @PersonID OUT 

				INSERT INTO Participants(DayReservationID,PersonID)
				VALUES (@DayReservationID,@PersonID)
				SET @ParticipantID = @@IDENTITY
				
				INSERT INTO Student(ParticipantID,StudentIDCard)
				VALUES (@ParticipantID,@StudentIDCard)
			END

			IF (@Firstname IS NOT NULL AND @Lastname IS NOT NULL
			AND @StudentIDCard IS NULL) -- tworze zwyklego uczestnika 
			BEGIN
			
				EXEC procCreatePerson
					@Firstname,@Lastname,
					@PersonID= @PersonID OUT 

				INSERT INTO Participants(DayReservationID,PersonID)
				VALUES (@DayReservationID,@PersonID)
				SET @ParticipantID = @@IDENTITY
			END
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu uczestnika dnia konferencji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateWorkshop]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateWorkshop]
	@WorkshopType int,
	@ConferenceID int,
	@ConfDayNumber int,
	@BeginHr varchar(5),
	@EndHr varchar (5),
	@WorkshopID int out
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY

	BEGIN TRY
		DECLARE @BeginHour time(7) = convert(time,@BeginHr)
		DECLARE @EndHour time(7) = convert(time,@EndHr)
	END TRY
	BEGIN CATCH
	;THROW 52000,
				'Podano godzinę w złym formacie, format to HH:MM',1;
	END CATCH

		BEGIN TRANSACTION
			IF( (SELECT  NumberOfPlaces 
				FROM WorkshopDict
				WHERE WorkshopDict.WorkshopTypeID = @WorkshopType) >
				(SELECT NumberOfPlaces 
				FROM Conferences 
				WHERE Conferences.ConferenceID = @ConferenceID))
			BEGIN 
				;THROW 52000,
				'Warsztat nie może mieć więcej miejsc niż pojedynczy dzień konferencji',1;
			END
			DECLARE @Price  money = (SELECT Price FROM WorkshopDict WHERE WorkshopTypeID = @WorkshopType);
			DECLARE @NumberOfPlaces int = (SELECT NumberOfPlaces FROM WorkshopDict WHERE WorkshopTypeID= @WorkshopType);
			INSERT INTO Workshops(WorkshopType,ConferenceID,ConfDayNumber,BeginHour,EndHour,Price,NumberOfPlaces)
			VALUES (@WorkshopType,@ConferenceID,@ConfDayNumber,@BeginHour,@EndHour,@Price,@NumberOfPlaces)
			SET @WorkshopID = @@IDENTITY;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy wstawianiu Warszatu ' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateWorkshopDict]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateWorkshopDict]
	@WorkshopName varchar(30),
	@Description varchar(255),
	@Price money,
	@NumberOfPlaces int,
	@WorkshopTypeID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	INSERT INTO WorkshopDict(WorkshopName,Description,Price,NumberOfPlaces)
	VALUES (@WorkshopName,@Description,@Price,@NumberOfPlaces);
	SET @WorkshopTypeID= @@IDENTITY;
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateWorkshopParticipant]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateWorkshopParticipant]
	@ParticipantID int,
	@WorkshopReservationID int
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			INSERT INTO WorkshopParticipant(WorkshopReservationID,ParticipantID)
			VALUES (@WorkshopReservationID,@ParticipantID)
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu dodawania uczestnika przy rejestracji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateWorkshopReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateWorkshopReservation]
	@DayReservationID int,
	@WorkshopID int,
	@Quantity int =0,
	@WorkshopReservationID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			IF( (SELECT count(*) 
				FROM WorkshopReservation
				WHERE DayReservationID = @DayReservationID 
				AND WorkshopId = @WorkshopID) >0 )
			BEGIN
				;THROW 52000,
				'Na ten warsztat dokonano już rezerwacji w ramach rezerwacji',1;
			END

			IF( @Quantity =0 )
			BEGIN
				;THROW 52000,
				'Nie można rezerwować 0 miejsc',1;
			END

			IF( dbo.funcWorkshopFreePlaces(@WorkshopID) < @Quantity)
			BEGIN
				;THROW 52000,
				'Za mało miejsc na warsztacie',1;
			END

			INSERT INTO WorkshopReservation (DayReservationID,WorkshopID,Quantity)
			VALUES (@DayReservationID,@WorkshopID,@Quantity);
			SET @WorkshopReservationID = @@IDENTITY;
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu rezerwacji warsztatu' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procCreateWorkshopReservationIndiv]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procCreateWorkshopReservationIndiv]
	@DayReservationID int,
	@WorkshopID int,
	@WorkshopReservationID int OUT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			DECLARE @ParticipantID int = 
			(SELECT ParticipantID 
			FROM Participants
			WHERE Participants.DayReservationID = @DayReservationID)

			EXEC procCreateWorkshopReservation
			@DayReservationId,@WorkshopID,1,
			@WorkshopReservationID = @WorkshopReservationID OuT

			EXEC procCreateWorkshopParticipant
			@ParticipantID,
			@WorkshopReservationID

		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy tworzeniu dodawania uczestnika przy rejestracji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procPayForReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procPayForReservation]
	@ReservationID int
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION

		IF( (SELECT PaymentDate 
			FROM Reservations
			WHERE ReservationID = @ReservationID) IS NOT NULL)
		BEGIN
			;THROW 52000,
			'Rezerwacja juz jest oplacona',1;
		END

		UPDATE Reservations
		SET PaymentDate=GETDATE()
		WHERE ReservationID = @ReservationID
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy opłacaniu rezerwacji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procRemoveDayReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRemoveDayReservation]
	@DayReservationID int
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
		
			DECLARE @ReservationID int = ( SELECT ReservationID
											FROM DayReservation
											WHERE DayReservationID= @DayReservationID)

			IF ( @ReservationID IS NOT NULL AND ( SELECT PaymentDate
					FROM Reservations
					WHERE ReservationID = @ReservationID) IS NOT NULL)
			BEGIN
				;THROW 52000,
				'Nie mozna usunac rezerwacji oplaconego dnia',1;
			END

			IF ( @ReservationID IS NULL)
			BEGIN
				;THROW 52000,
				'Nie mozna odnalezc dniia rezerwacji o podanym ID',1;
			END

			DELETE FROM  DayReservation
			WHERE DayReservationID= @DayReservationID
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy usuwaniu nieopłaconych rezerwacji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procRemoveParticipant]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRemoveParticipant]
	@ParticipantID int
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			IF( (SELECT ParticipantID 
				FROM Participants
				WHERE ParticipantID = @ParticipantID) IS NULL)
			BEGIN
				;THROW 52000,
				'Nie znaleziono takiego Participanta',1;
			END
			DELETE Participants
			WHERE Participants.ParticipantID = @ParticipantID
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy usuwaniu nieopłaconych rezerwacji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procRemoveReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRemoveReservation]
	@ReservationID int
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			

			IF ( @ReservationID IS NOT NULL AND ( SELECT PaymentDate
					FROM Reservations
					WHERE ReservationID = @ReservationID) IS NOT NULL)
			BEGIN
				;THROW 52000,
				'Nie mozna usunac oplaconej rezerwacji',1;
			END

			IF ( ( SELECT ReservationID 
					FROM Reservations
					WHERE ReservationID = @ReservationID) IS NULL)
			BEGIN
				;THROW 52000,
				'Nie mozna odnalezc rezerwacji o podanym ID',1;
			END

			DELETE FROM  Reservations
			WHERE ReservationID= @ReservationID

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy usuwaniu  rezerwacji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procRemoveUnpaidReservations]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRemoveUnpaidReservations]
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION

		DELETE FROM Reservations
		WHERE PaymentDate IS NULL AND DATEDIFF(day,ReservationDate,GETDATE()) >=7
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy usuwaniu nieopłaconych rezerwacji' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procRemoveWorkshopParticipant]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRemoveWorkshopParticipant]
	@ParticipantID int,
	@WorkshopReservationID int
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			IF( (SELECT ParticipantID 
				FROM WorkshopParticipant
				WHERE ParticipantID = @ParticipantID 
				AND WorkshopReservationID = @WorkshopReservationID) IS NULL)
			BEGIN
				;THROW 52000,
				'Nie znaleziono takiego uczestnika warsztatu',1;
			END
	
			DELETE WorkshopParticipant 
			WHERE ParticipantID = @ParticipantID AND WorkshopReservationID = @WorkshopReservationID
			
			
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy usuwaniu uczestnika warsztatu' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procRemoveWorkshopReservation]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procRemoveWorkshopReservation]
	@WorkshopReservationID int
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION

			DECLARE @DayReservationID  int = ( SELECT DayReservationID
											FROM WorkshopReservation
											WHERE WorkshopReservationID= @WorkshopReservationID)

			DECLARE @ReservationID int = ( SELECT ReservationID
											FROM DayReservation
											WHERE DayReservationID= @DayReservationID)

			IF ( @ReservationID IS NOT NULL AND ( SELECT PaymentDate
					FROM Reservations
					WHERE ReservationID = @ReservationID) IS NOT NULL)
			BEGIN
				;THROW 52000,
				'Nie mozna usunac warsztatu oplaconej rezerwacji',1;
			END


			IF ( ( SELECT WorkshopReservationID
					FROM WorkshopReservation
					WHERE WorkshopReservationID = @WorkshopReservationID) IS NULL)
			BEGIN
				;THROW 52000,
				'Nie mozna odnalezc warsztatu o podanym ID',1;
			END

			DELETE FROM  WorkshopReservation
			WHERE WorkshopReservationID= @WorkshopReservationID
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy usuwaniu rezerwacji warsztatu' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateCompanyCustomer]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procUpdateCompanyCustomer]
	@CustomerID int,
	@CityName varchar(30),
	@CountryName varchar(30),
	@Address varchar(30),
	@PostalCode varchar(30),
	@Phone varchar(30),
	@Email varchar(30),
	@CompanyName varchar(30),
	@NIP varchar(30)
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			IF( (SELECt CustomerID
				FROM Customers 
				WHERE CustomerID = @CustomerID) IS NULL 
				OR (SELECT CustomerID
					FROM Companies 
					WHERE CustomerID = @CustomerID) IS NULL)
			BEGIN
				;THROW 52000,
				'Nie znaleziono klienta o podanym ID',1;
			END
			EXEC procUpdateCustomer
			@CustomerID,@CityName,@CountryName,@Address,@PostalCode,@Phone,@Email

			UPDATE Companies 
			SET CompanyName=@CompanyName,
			NiP=@NIP
			WHERE CustomerID = @CustomerID

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy uaktualnianiu klienta firmowego' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateCustomer]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procUpdateCustomer]
	@CustomerID int,
	@CityName varchar(30),
	@CountryName varchar(30),
	@Address varchar(30),
	@PostalCode varchar(30),
	@Phone varchar(30),
	@Email varchar(30)
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			IF( (SELECt CustomerID
				FROM Customers 
				WHERE CustomerID = @CustomerID) IS NULL)
			BEGIN
				;THROW 52000,
				'Nie znaleziono klienta o podanym ID',1;
			END
	
		DECLARE @CityID int 
		EXEC procCreateCity
		@CityName,@CountryName,
		@CityID=@CityID 

			UPDATE Customers 
			SET CityID= @CityID,
			Address= @Address,
			PostalCode = @PostalCode,
			Phone = @Phone,
			Email = @Email
			WHERE CustomerID = @CustomerID
		
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy uaktualnianiu klienta' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[procUpdateIndivCustomer]    Script Date: 25.01.2019 12:48:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[procUpdateIndivCustomer]
	@CustomerID int,
	@CityName varchar(30),
	@CountryName varchar(30),
	@Address varchar(30),
	@PostalCode varchar(30),
	@Phone varchar(30),
	@Email varchar(30),
	@Firstname varchar(30),
	@Lastname varchar(30)
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION
			IF( (SELECt CustomerID
				FROM Customers 
				WHERE CustomerID = @CustomerID) IS NULL 
				OR (SELECT CustomerID
					FROM IndividualClient 
					WHERE CustomerID = @CustomerID) IS NULL)
			BEGIN
				;THROW 52000,
				'Nie znaleziono klienta o podanym ID',1;
			END
			DECLARE @PersonID int = (SELECT PersonID 
									FROM IndividualClient
									WHERE CustomerID= @CustomerID)
			EXEC procUpdateCustomer
			@CustomerID,@CityName,@CountryName,@Address,@PostalCode,@Phone,@Email


			UPDATE Person 
			SET Firstname=@Firstname,
			Lastname=@Lastname
			WHERE PersonID= @PersonID

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @msg NVARCHAR(2048)= 'Błąd przy uaktualnianiu klienta indywidualnego' + CHAR(13) + CHAR(10) + ERROR_MESSAGE();
		THROW 52000,@msg,1;
	END CATCH
END
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ConferenceDays"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Conferences"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 3
         End
         Begin Table = "DayReservation"
            Begin Extent = 
               Top = 6
               Left = 466
               Bottom = 136
               Right = 647
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mostPopularConferences'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'mostPopularConferences'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ConferenceDays"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Conferences"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "DayReservation"
            Begin Extent = 
               Top = 6
               Left = 466
               Bottom = 136
               Right = 647
            End
            DisplayFlags = 280
            TopColumn = 2
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'placesLeftPerConferenceDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'placesLeftPerConferenceDay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Companies"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customers"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 136
               Right = 419
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DayReservation"
            Begin Extent = 
               Top = 6
               Left = 457
               Bottom = 136
               Right = 638
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 6
               Left = 676
               Bottom = 136
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'topCompanyClients'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'topCompanyClients'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Customers"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IndividualClient"
            Begin Extent = 
               Top = 6
               Left = 465
               Bottom = 102
               Right = 635
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Person"
            Begin Extent = 
               Top = 6
               Left = 673
               Bottom = 119
               Right = 843
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 131
               Left = 252
               Bottom = 261
               Right = 426
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'topIndividualClients'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'topIndividualClients'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 120
               Left = 676
               Bottom = 250
               Right = 850
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customers"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 136
               Right = 419
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Companies"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'unfilledCompanyReservations'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'unfilledCompanyReservations'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Companies"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 119
               Right = 211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Customers"
            Begin Extent = 
               Top = 6
               Left = 249
               Bottom = 136
               Right = 419
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 6
               Left = 457
               Bottom = 136
               Right = 631
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 2280
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'unpaidCompanyReservations'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'unpaidCompanyReservations'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Customers"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "IndividualClient"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 102
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Person"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 119
               Right = 624
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Reservations"
            Begin Extent = 
               Top = 6
               Left = 662
               Bottom = 136
               Right = 836
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'unpaidIndividualReservations'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'unpaidIndividualReservations'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "ConferenceDays"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 102
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Conferences"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 428
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Workshops"
            Begin Extent = 
               Top = 102
               Left = 38
               Bottom = 232
               Right = 217
            End
            DisplayFlags = 280
            TopColumn = 4
         End
         Begin Table = "WorkshopDict"
            Begin Extent = 
               Top = 138
               Left = 255
               Bottom = 268
               Right = 435
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "WorkshopReservation"
            Begin Extent = 
               Top = 6
               Left = 466
               Bottom = 136
               Right = 681
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'upcomingWorkshops'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'upcomingWorkshops'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'upcomingWorkshops'
GO
USE [master]
GO
ALTER DATABASE [bera_a] SET  READ_WRITE 
GO
