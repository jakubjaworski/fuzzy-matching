-- PRE-REQUISUITES:		Create an empty database named [FuzzyMatching] 
--						(or amend references to [FuzzyMatching] in this script)


USE [FuzzyMatching]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAgeAtDate]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	returns age at a given date (specified in @EffectiveDate parameter)
-- ================================================================================
CREATE FUNCTION [dbo].[GetAgeAtDate] 
(
	-- Add the parameters for the function here
	@DateOfBirth date,
	@EffectiveDate date
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = DATEDIFF(yy,@DateOfBirth,@EffectiveDate) - CASE when DATEPART(mm,@EffectiveDate) > DATEPART(mm,@DateOfBirth) or (DATEPART(mm,@EffectiveDate) = DATEPART(mm,@DateOfBirth) and DATEPART(dd,@EffectiveDate) >= DATEPART(dd,@DateOfBirth)) then 0 else 1 end
	-- Return the result of the function
	RETURN @Result

END




GO
/****** Object:  UserDefinedFunction [dbo].[GetAgeRange]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	returns an age range category as at the specified @EffectiveDate
-- =============================================================================
CREATE FUNCTION [dbo].[GetAgeRange] 
(
	-- Add the parameters for the function here
	@DateOfBirth date,
	@EffectiveDate date
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = CASE 
	  when [dbo].[GetAgeAtDate](@DateOfBirth,@EffectiveDate) > 19 then 'over 19'
	  when [dbo].[GetAgeAtDate](@DateOfBirth,@EffectiveDate) > 15 then '16-19'
	  when [dbo].[GetAgeAtDate](@DateOfBirth,@EffectiveDate) > 10 then '11-15'
	  when [dbo].[GetAgeAtDate](@DateOfBirth,@EffectiveDate) > 4 then '05-10'
	  when [dbo].[GetAgeAtDate](@DateOfBirth,@EffectiveDate) >= 0 then '0-4'
	  
	  
	  
	  
	end
	  	-- Return the result of the function
	RETURN @Result

END




GO
/****** Object:  UserDefinedFunction [dbo].[GetFirstLetter]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	returns first letter in a string
-- =============================================
CREATE FUNCTION [dbo].[GetFirstLetter] 
(
	-- Add the parameters for the function here
	@p1 varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = LEFT(@p1,1)
	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  UserDefinedFunction [dbo].[GetFirstTwoWords]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- ===================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	returns first word in a string (all characters up to the second space)
-- ===================================================================================
CREATE FUNCTION [dbo].[GetFirstTwoWords] 
(
	-- Add the parameters for the function here
	@p1 varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result =

	case when  CHARINDEX(' ', @p1,  CHARINDEX(' ', @p1)+1) = 0
 then
     @p1
 else
     SUBSTRING(@p1,1,CHARINDEX(' ', @p1,  CHARINDEX(' ', @p1)+1)-1)
 end

	-- Return the result of the function
	RETURN @Result

END




GO
/****** Object:  UserDefinedFunction [dbo].[GetFirstWord]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	returns first word in a string (all characters up to the first space)
-- ==================================================================================
CREATE FUNCTION [dbo].[GetFirstWord] 
(
	-- Add the parameters for the function here
	@p1 varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result =

	case when CHARINDEX(' ', @p1) = 0
 then
     @p1
 else
     SUBSTRING(@p1,1,CHARINDEX(' ', @p1)-1)
 end

	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  UserDefinedFunction [dbo].[HarmoniseAddressLine]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==========================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	harmonises first part of address for fuzzy matching
-- Note:		From previous work I believe 'APARTMENT','FLAT','THE','UNIT' are the most
--				common first words within the national land and property gazetteer (NLPG) 
--				for Cambridgeshire.  These are expanded to include the second word to 
--				increase uniqueness.  Further analysis of Cambridgeshire addresses could 
--				be used to improve this function.
-- ==========================================================================================
CREATE FUNCTION [dbo].[HarmoniseAddressLine] 
(
	-- Add the parameters for the function here
	@addressLine1 varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = 
      case when UPPER([dbo].[GetFirstWord](@addressLine1)) IN ('APARTMENT','FLAT','THE','UNIT')
        then 
          REPLACE(UPPER([dbo].[GetFirstTwoWords](@addressLine1)),',','')
        else
           REPLACE(UPPER([dbo].[GetFirstWord](@addressLine1)),',','')
        end

	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  UserDefinedFunction [dbo].[HarmonisePostcode]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ===================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	extracts and harmonises postcodes into a consistent for fuzzy matching
-- adapted from http://www.hexcentral.com/articles/sql-postcodes.htm
-- ===================================================================================
CREATE FUNCTION [dbo].[HarmonisePostcode] 
(
	-- Add the parameters for the function here
	@postcode varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = UPPER(
      case
        when patindex('%[A-Z][A-Z][0-9][0-9] [0-9][A-Z][A-Z]%', @postcode) > 0
        then substring(@postcode, patindex('%[A-Z][A-Z][0-9][0-9] [0-9][A-Z][A-Z]%',@postcode),8)
        when patindex('%[A-Z][0-9][0-9] [0-9][A-Z][A-Z]%', @postcode) > 0
        then substring(@postcode, patindex('%[A-Z][0-9][0-9] [0-9][A-Z][A-Z]%',@postcode),7)
        when patindex('%[A-Z][A-Z][0-9] [0-9][A-Z][A-Z]%', @postcode) > 0
        then substring(@postcode, patindex('%[A-Z][A-Z][0-9] [0-9][A-Z][A-Z]%',@postcode),7)
        when patindex('%[A-Z][0-9] [0-9][A-Z][A-Z]%', @postcode) > 0
        then substring(@postcode, patindex('%[A-Z][0-9] [0-9][A-Z][A-Z]%',@postcode),6)
        when patindex('%[A-Z][A-Z][0-9][A-Z] [0-9][A-Z][A-Z]%', @postcode) > 0
        then substring(@postcode, patindex('%[A-Z][A-Z][0-9][A-Z] [0-9][A-Z][A-Z]%',@postcode),8)
        when patindex('%[A-Z][0-9][A-Z] [0-9][A-Z][A-Z]%', @postcode) > 0
        then substring(@postcode, patindex('%[A-Z][0-9][A-Z] [0-9][A-Z][A-Z]%',@postcode),7)

		when patindex('%[A-Z][A-Z][0-9][0-9][0-9][A-Z][A-Z]%', @postcode) > 0
        then LEFT(substring(@postcode, patindex('%[A-Z][A-Z][0-9][0-9][0-9][A-Z][A-Z]%',@postcode),7),4) + ' ' + RIGHT(substring(@postcode, patindex('%[A-Z][A-Z][0-9][0-9][0-9][A-Z][A-Z]%',@postcode),7),3)
        when patindex('%[A-Z][0-9][0-9][0-9][A-Z][A-Z]%', @postcode) > 0
        then LEFT(substring(@postcode, patindex('%[A-Z][0-9][0-9][0-9][A-Z][A-Z]%',@postcode),6),3)+ ' ' + RIGHT(substring(@postcode, patindex('%[A-Z][0-9][0-9][0-9][A-Z][A-Z]%',@postcode),6),3)
        when patindex('%[A-Z][A-Z][0-9][0-9][A-Z][A-Z]%', @postcode) > 0
        then LEFT(substring(@postcode, patindex('%[A-Z][A-Z][0-9][0-9][A-Z][A-Z]%',@postcode),6),3)+ ' ' + RIGHT(substring(@postcode, patindex('%[A-Z][A-Z][0-9][0-9][A-Z][A-Z]%',@postcode),6),3)
        when patindex('%[A-Z][0-9][0-9][A-Z][A-Z]%', @postcode) > 0
        then LEFT(substring(@postcode, patindex('%[A-Z][0-9][0-9][A-Z][A-Z]%',@postcode),5),2)+ ' ' + RIGHT(substring(@postcode, patindex('%[A-Z][0-9][0-9][A-Z][A-Z]%',@postcode),5),3)
        when patindex('%[A-Z][A-Z][0-9][A-Z][0-9][A-Z][A-Z]%', @postcode) > 0
        then LEFT(substring(@postcode, patindex('%[A-Z][A-Z][0-9][A-Z][0-9][A-Z][A-Z]%',@postcode),7),4)+ ' ' + RIGHT(substring(@postcode, patindex('%[A-Z][A-Z][0-9][A-Z][0-9][A-Z][A-Z]%',@postcode),7),3)
        when patindex('%[A-Z][0-9][A-Z][0-9][A-Z][A-Z]%', @postcode) > 0
        then LEFT(substring(@postcode, patindex('%[A-Z][0-9][A-Z][0-9][A-Z][A-Z]%',@postcode),6),3) + ' ' + RIGHT(substring(@postcode, patindex('%[A-Z][0-9][A-Z][0-9][A-Z][A-Z]%',@postcode),6),3)
      end )


	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  UserDefinedFunction [dbo].[IntToBinary]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ===========================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	used to convert the match score back to a binary representation (making it
--              easier to identify which parts matched
-- Copied from: https://www.codeproject.com/Articles/210406/INT-to-BINARY-string-in-SQL-Server
-- ===========================================================================================
CREATE FUNCTION [dbo].[IntToBinary]
(
 @value INT,
 @fixedSize INT = 10
)
RETURNS VARCHAR(1000)
AS
BEGIN
 DECLARE @result VARCHAR(1000) = '';

 WHILE (@value != 0)
 BEGIN
  IF(@value%2 = 0) 
   SET @Result = '0' + @Result;
  ELSE
   SET @Result = '1' + @Result;
   
  SET @value = @value / 2;
 END;

 IF(@FixedSize > 0 AND LEN(@Result) < @FixedSize)
  SET @result = RIGHT('00000000000000000000' + @Result, @FixedSize);

 RETURN @Result;
END


GO
/****** Object:  UserDefinedFunction [dbo].[Match]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	match two strings, first converting each to UPPERCASE
--              then trimming any white space from the start and end
-- ==================================================================
CREATE FUNCTION [dbo].[Match] 
(
	-- Add the parameters for the function here
	@p1 varchar(255),
	@p2 varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = 
	  case when LTRIM(RTRIM(UPPER(@p1))) = LTRIM(RTRIM(UPPER(@p2))) then 1 else 0 end


	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  UserDefinedFunction [dbo].[SoundexMatch]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ==============================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	match two strings phonetically using the soundex algorithm
-- Reference:   https://docs.microsoft.com/en-us/sql/t-sql/functions/soundex-transact-sql
-- ==============================================================================
CREATE FUNCTION [dbo].[SoundexMatch] 
(
	-- Add the parameters for the function here
	@p1 varchar(255),
	@p2 varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result varchar(255)

	-- Add the T-SQL statements to compute the return value here
	SELECT @Result = 
	  case when soundex(LTRIM(RTRIM(UPPER(@p1)))) = soundex(LTRIM(RTRIM(UPPER(@p2)))) then 1 else 0 end


	-- Return the result of the function
	RETURN @Result

END



GO
/****** Object:  Table [dbo].[Cambs_postcodes]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cambs_postcodes](
	[Postcode] [varchar](50) NOT NULL,
	[Positional_quality_indicator] [varchar](50) NULL,
	[Eastings] [varchar](50) NULL,
	[Northings] [varchar](50) NULL,
	[Country_code] [varchar](50) NULL,
	[NHS_regional_HA_code] [varchar](50) NULL,
	[NHS_HA_code] [varchar](50) NULL,
	[Admin_county_code] [varchar](50) NULL,
	[Admin_district_code] [varchar](50) NULL,
	[Admin_ward_code] [varchar](50) NULL,
 CONSTRAINT [PK_Cambs_postcodes] PRIMARY KEY CLUSTERED 
(
	[Postcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Dataset_A]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_A](
	[id] [int] NOT NULL,
	[first_name] [varchar](255) NULL,
	[surname] [varchar](255) NULL,
	[gender] [nchar](1) NULL,
	[date_of_birth] [date] NULL,
	[postcode] [varchar](50) NULL,
	[address_line_1] [varchar](255) NULL,
	[in_county] [bit] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Dataset_B]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dataset_B](
	[id] [int] NOT NULL,
	[first_name] [varchar](255) NULL,
	[surname] [varchar](255) NULL,
	[gender] [nchar](1) NULL,
	[date_of_birth] [date] NULL,
	[postcode] [varchar](50) NULL,
	[address_line_1] [varchar](255) NULL,
	[in_county] [bit] NULL
) ON [PRIMARY]

GO
/****** Object:  StoredProcedure [dbo].[MatchingOverview]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	produce summary stats for venn diagram
-- =============================================
CREATE PROCEDURE [dbo].[MatchingOverview] 
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
select 
count(a.id) as [total_in_A], 
count(b.id) as [total_in_B], 
count(distinct a.id) as [distinct_total_in_A], 
count(distinct b.id) as [distinct_total_in_B], 
count(case when a.id is null then b.id end) as [B_not_in_A], 
count(case when b.id is null then a.id end) as [A_not_in_B], 
count(case when a.id is not null and b.id is not null then  a.id end) as [A_in_both],
count(case when a.id is not null and b.id is not null then  b.id end) as [B_in_both],
count(distinct case when a.id is not null and b.id is not null then  a.id end) as [distinct_A_in_both],
count(distinct case when a.id is not null and b.id is not null then  b.id end) as [distinct_B_in_both]
from [dbo].[Dataset_A] a full outer join 
[dbo].[Dataset_B] b on a.date_of_birth = b.date_of_birth
END


GO
/****** Object:  StoredProcedure [dbo].[PerformFuzzyMatching]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-04
-- Description:	Performs fuzzy matching between Dataset_A and Dataset_B based on demographic data
--				Requires an exact match on date of birth.  Then scores match based on following:
--				SOUNDEX(Surname): 		128
--				Surname:				64
--				Postcode:				32
--				First part of address:	16
--				Gender:					8
--				First Initial:			4
--				SOUNDEX(First name):	2
--				First name:				1
--				The score can be converted to a bit pattern to indicate which items were matched
--				The order is intended to be based on the most unique identifiers.  However, this
--				can always be refined based on testing.
-- ==============================================================================================
CREATE PROCEDURE [dbo].[PerformFuzzyMatching] 
	  @EffectiveDate date = '2017-04-01' 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	;WITH rankedMatches AS (
select
a.id as a_id,
b.id as b_id,
a.in_county as A_in_county,
b.in_county as B_in_county,
[dbo].[GetAgeRange](a.date_of_birth,@EffectiveDate) as [A_age_range],
[dbo].[GetAgeRange](b.date_of_birth,@EffectiveDate) as [B_age_range],
a.gender as A_gender,
b.gender as B_gender,
[dbo].[Match]([dbo].[GetFirstWord](a.first_name),[dbo].[GetFirstWord](b.first_name)) * 1 +
[dbo].[SoundexMatch]([dbo].[GetFirstWord](a.first_name),[dbo].[GetFirstWord](b.first_name)) * 2 +
[dbo].[Match]([dbo].[GetFirstLetter](a.first_name),[dbo].[GetFirstLetter](b.first_name)) * 4 +
[dbo].[Match](a.gender,b.gender) * 8 +
[dbo].[Match]([dbo].[HarmoniseAddressLine](a.address_line_1),[dbo].[HarmoniseAddressLine](b.address_line_1)) * 16 +
[dbo].[Match]([dbo].[HarmonisePostcode](a.postcode),[dbo].[HarmonisePostcode](b.postcode)) * 32 +
[dbo].[Match](a.surname,b.surname) * 64 +
[dbo].[SoundexMatch](a.surname,b.surname) * 128 as matching_score,
ROW_NUMBER() OVER (PARTITION BY 
a.id
ORDER BY 
[dbo].[Match]([dbo].[GetFirstWord](a.first_name),[dbo].[GetFirstWord](b.first_name)) * 1 +
[dbo].[SoundexMatch]([dbo].[GetFirstWord](a.first_name),[dbo].[GetFirstWord](b.first_name)) * 2 +
[dbo].[Match]([dbo].[GetFirstLetter](a.first_name),[dbo].[GetFirstLetter](b.first_name)) * 4 +
[dbo].[Match](a.gender,b.gender) * 8 +
[dbo].[Match]([dbo].[HarmoniseAddressLine](a.address_line_1),[dbo].[HarmoniseAddressLine](b.address_line_1)) * 16 +
[dbo].[Match]([dbo].[HarmonisePostcode](a.postcode),[dbo].[HarmonisePostcode](b.postcode)) * 32 +
[dbo].[Match](a.surname,b.surname) * 64 +
[dbo].[SoundexMatch](a.surname,b.surname) * 128 DESC
--,a.in_county,
--b.in_county,
--[dbo].[GetAgeRange](a.[DoB],'2017-04-01'),
--[dbo].[GetAgeRange](b.[DoB],'2017-04-01'),
--a.gender,
--b.gender
) AS rn,
ROW_NUMBER() OVER (PARTITION BY 
b.id
ORDER BY 
[dbo].[Match]([dbo].[GetFirstWord](a.first_name),[dbo].[GetFirstWord](b.first_name)) * 1 +
[dbo].[SoundexMatch]([dbo].[GetFirstWord](a.first_name),[dbo].[GetFirstWord](b.first_name)) * 2 +
[dbo].[Match]([dbo].[GetFirstLetter](a.first_name),[dbo].[GetFirstLetter](b.first_name)) * 4 +
[dbo].[Match](a.gender,b.gender) * 8 +
[dbo].[Match]([dbo].[HarmoniseAddressLine](a.address_line_1),[dbo].[HarmoniseAddressLine](b.address_line_1)) * 16 +
[dbo].[Match]([dbo].[HarmonisePostcode](a.postcode),[dbo].[HarmonisePostcode](b.postcode)) * 32 +
[dbo].[Match](a.surname,b.surname) * 64 +
[dbo].[SoundexMatch](a.surname,b.surname) * 128 DESC
) AS rn2
from
[dbo].[Dataset_A] a full outer join
[dbo].[Dataset_B] b
on
a.date_of_birth = b.date_of_birth
)




SELECT 
count(a_id) as Dataset_A_count,
count(b_id) as Dataset_B_count,
--a_id,b_id,
A_in_county as A_in_county,
B_in_county as B_in_county,
ISNULL(a_Age_range,b_Age_range) as age_range,
A_gender,
B_gender,
matching_score,
[dbo].[IntToBinary](Matching_score,8) as bit_score,
--rn,rn2,
CASE 
when a_id IS NULL then 'unmatched (B)'
when b_id IS NULL then 'unmatched (A)'
when rn = 1 and rn2 = 1 then 'AB'
when rn = 1 and rn2 != 1 then 'A'
when rn != 1 and rn2 = 1 then 'B'
when rn != 1 and rn2 != 1 then 'AB - rejected'
end as match_type
FROM rankedMatches
  --WHERE rn = 1 or rn2 = 1
GROUP BY matching_score,A_in_county,B_in_county,A_age_range,B_age_range,A_gender,B_gender, CASE 
when a_id IS NULL then 'unmatched (B)'
when b_id IS NULL then 'unmatched (A)'
when rn = 1 and rn2 = 1 then 'AB'
when rn = 1 and rn2 != 1 then 'A'
when rn != 1 and rn2 = 1 then 'B'
when rn != 1 and rn2 != 1 then 'AB - rejected'
end
 ORDER BY Matching_score DESC

 



END

GO
/****** Object:  StoredProcedure [dbo].[UpdateDataset_A_in_county]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-06
-- Description:	left joins Dataset_A to Cambs_postcodes and updates the in_county field
--				based on match.  The [dbo].[HarmonisePostcode] function is used to convert both
--				postcode fields into a consistent format for matching.
-- ====================================================================================

CREATE PROCEDURE [dbo].[UpdateDataset_A_in_county]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update [dbo].[Dataset_A]
	set [in_county] = case when cpo.[Postcode] IS NULL then 0 else 1 end  from [dbo].[Dataset_A] a left join [dbo].[Cambs_postcodes] cpo on [dbo].[HarmonisePostcode](a.postcode) = [dbo].[HarmonisePostcode](cpo.[Postcode])

	RETURN @@ROWCOUNT
END

GO
/****** Object:  StoredProcedure [dbo].[UpdateDataset_B_in_county]    Script Date: 4/9/2017 2:14:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================================================
-- Author:		Richard Hall
-- Create date: 2017-04-06
-- Description:	left joins Dataset_B to Cambs_postcodes and updates the in_county field
--				based on match.  The HarmonisePostcode function is used to convert both
--				postcode fields into a consistent format for matching.
-- ====================================================================================
CREATE PROCEDURE [dbo].[UpdateDataset_B_in_county]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update [dbo].[Dataset_B]
	set [in_county] = case when cpo.[Postcode] IS NULL then 0 else 1 end  from [dbo].[Dataset_B] b left join [dbo].[Cambs_postcodes] cpo on [dbo].[HarmonisePostcode](b.postcode) = [dbo].[HarmonisePostcode](cpo.[Postcode])

	RETURN @@ROWCOUNT
END

GO
