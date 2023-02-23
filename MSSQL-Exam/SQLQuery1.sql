CREATE DATABASE Boardgames

USE Boardgames

--1 

CREATE TABLE Categories (
Id INT IDENTITY PRIMARY KEY ,
[Name] VARCHAR (50) NOT NULL
)

CREATE TABLE Addresses (
Id INT IDENTITY PRIMARY KEY ,
StreetName NVARCHAR (100) NOT NULL,
StreetNumber INT NOT NULL,
Town VARCHAR (30) NOT NULL,
Country VARCHAR (50) NOT NULL,
ZIP INT not null
)

CREATE TABLE Publishers (
Id INT IDENTITY PRIMARY KEY ,
[Name] VARCHAR (30) NOT NULL UNIQUE,
AddressId INT NOT NULL FOREIGN KEY REFERENCES Addresses(Id),
Website NVARCHAR (40) ,
Phone NVARCHAR (20)

)

CREATE TABLE PlayersRanges (
Id INT IDENTITY PRIMARY KEY ,
PlayersMin INT NOT NULL,
PlayersMax INT NOT NULL 

)

CREATE TABLE Boardgames (
Id INT IDENTITY PRIMARY KEY ,
[Name] NVARCHAR (30) NOT NULL,
YearPublished INT NOT NULL,
Rating  DECIMAL (8,2) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
PublisherId INT NOT NULL FOREIGN KEY REFERENCES Publishers (Id),
PlayersRangeId INT NOT NULL FOREIGN KEY REFERENCES PlayersRanges (Id)
)

CREATE TABLE Creators (
Id INT IDENTITY PRIMARY KEY ,
FirstName NVARCHAR (30) NOT NULL,
LastName NVARCHAR (30) NOT NULL,
Email NVARCHAR (30) NOT NULL
)

CREATE TABLE CreatorsBoardgames (
CreatorId INT NOT NULL FOREIGN KEY REFERENCES Creators (Id),
BoardgameId INT NOT NULL FOREIGN KEY REFERENCES Boardgames (Id),
PRIMARY KEY (CreatorId,BoardgameId)

)

--2

INSERT INTO Boardgames (Name, YearPublished,Rating,CategoryId,PublisherId,PlayersRangeId) VALUES
('Deep Blue'	,'2019',	5.67,	1,	15	,7),
('Paris'	,'2016',	9.78,	7,	1	,5),
('Catan: Starfarers'	,'2021'	,9.87	,7	,13	,6),
('Bleeding Kansas',	'2020',	3.25,	3,	7,	4),
('One Small Step',	'2019'	,5.75,	5,	9	,2)


INSERT INTO Publishers (Name,AddressId,Website,Phone) VALUES
('Agman Games',	5,	'www.agmangames.com'	,'+16546135542'),
('Amethyst Games'	,7	,'www.amethystgames.com',	'+15558889992'),
('BattleBooks'	,13,	'www.battlebooks.com'	,'+12345678907')

--3

UPDATE PlayersRanges 
SET PlayersMax = PlayersMax+1
WHERE PlayersMax=2 AND PlayersMin=2

SELECT*FROM PlayersRanges

UPDATE Boardgames
SET Name = CONCAT ([Name],'V2')
WHERE YearPublished>=2020
SELECT * FROM Boardgames

--4



DELETE  FROM Addresses
WHERE LEFT(Town,1)='L'


--5 

SELECT [Name], Rating 
FROM  Boardgames
ORDER BY YearPublished, [Name] desc

--6

SELECT b.Id,b.Name,b.YearPublished,c.Name 
FROM Boardgames AS b
JOIN Categories as c ON b.CategoryId =c.Id
WHERE c.Name IN ('Strategy Games','Wargames')
ORDER BY YearPublished DESC 

--7

SELECT c.Id, CONCAT (c.FirstName, ' ',c.LastName), c.Email
FROM Creators AS c
LEFT JOIN CreatorsBoardgames As cb
ON c.Id=cb.CreatorId
LEFT JOIN Boardgames AS b
ON cb.BoardgameId = b.Id
WHERE b.Id IS NULL 
ORDER BY CONCAT (c.FirstName, ' ',c.LastName) 

--8

SELECT TOP (5) b.Name,b.Rating,c.Name
FROM Boardgames AS b
JOIN Categories AS c
ON b.CategoryId = c.Id
JOIN PlayersRanges as pr
on b.PlayersRangeId = pr.Id
WHERE (b.Rating>7.00 AND b.Name LIKE '%a%') 
OR (b.Rating>7.50 AND pr.PlayersMin=2 AND pr.PlayersMax=5)
ORDER BY b.Name, b.Rating DESC 

--9

SELECT CONCAT(c.FirstName, ' ',c.LastName) AS FullName, c.Email,MAX(b.Rating)
FROM Creators AS c
JOIN CreatorsBoardgames AS cb
ON c.Id=cb.CreatorId
JOIN Boardgames AS b
ON cb.BoardgameId=b.Id
Where Email LIKE '%.com'
GROUP BY CONCAT(c.FirstName, ' ',c.LastName) ,Email
Order BY FullName


--10

SELECT c.LastName,CEILING(AVG(b.Rating)) AS AverageRating ,p.Name
FROM Creators AS c
JOIN CreatorsBoardgames AS cb
ON c.Id=cb.CreatorId
JOIN Boardgames AS b
ON cb.BoardgameId = b.Id
JOin Publishers AS p
ON b.PublisherId =p.Id
WHERE p.Name = 'Stonemaier Games'
GROUP BY c.LastName,p.Name
ORDER BY AVG(b.Rating) DESC

GO
--11

CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR (30)) 
RETURNS INT 
AS 
BEGIN 

DECLARE @gamesCount INT;
SET @gamesCount =(
					SELECT COUNT(cb.BoardgameId) 
					FROM Creators AS c
					LEFT JOIN CreatorsBoardgames AS cb
					ON c.Id=cb.CreatorId
					LEFT JOIN Boardgames AS b
					ON b.Id=cb.BoardgameId
					WHERE c.FirstName=@name
					Group by c.FirstName
				)
RETURN  @gamesCount


END
GO
SELECT dbo.udf_CreatorWithBoardgames('Bruno')

SELECT *
FROM Creators

GO
--12

CREATE PROCEDURE usp_SearchByCategory(@category VARCHAR (50)) 
AS 
BEGIN

SELECT b.Name
,YearPublished,
Rating,
c.Name AS CategoryName
,p.Name AS PublisherName,
CONCAT(pr.PlayersMin, ' people')AS MinPlayers,
CONCAT(pr.PlayersMax, ' people')AS MaxPlayers
FROM Boardgames AS b
LEFT JOIN Categories AS c
ON b.CategoryId=c.Id
LEFT JOIN Publishers AS p
ON b.PublisherId=p.Id
LEFT JOIN PlayersRanges AS pr
ON b.PlayersRangeId=pr.Id
WHERE c.Name =@category
Order BY p.Name ,YearPublished DESC

END

EXEC usp_SearchByCategory 'Wargames'