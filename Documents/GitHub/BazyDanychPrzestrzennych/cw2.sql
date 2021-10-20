--3. Dodaj funkcjonalności PostGIS’a do bazy poleceniem CREATE EXTENSION postgis;
CREATE EXTENSION postgis;
--4. Na podstawie poniższej mapy utwórz trzy tabele: buildings (id, geometry, name), roads (id, geometry, name), poi (id, geometry, name).
CREATE TABLE buildings 
(
id VARCHAR(8) PRIMARY KEY NOT NULL,
geometry geometry,
name VARCHAR(32)
);
CREATE TABLE roads
(
id VARCHAR(8) PRIMARY KEY NOT NULL,
geometry geometry,
name VARCHAR(32)
);
CREATE TABLE poi
(
id VARCHAR(8) PRIMARY KEY NOT NULL,
geometry geometry,
name VARCHAR(32)
);
--5. Współrzędne obiektów oraz nazwy (np. BuildingA) należy odczytać z mapki umieszczonej poniżej. Układ współrzędnych ustaw jako niezdefiniowany.
INSERT INTO buildings VALUES
	('B1','POLYGON((8 4, 10 5.4, 10.5 1.5, 8 1.5, 8 4))','BuildingA'),
	('B2','POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))','BuildingB'),
	('B3','POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))','BuildingC'),
	('B4','POLYGON((9 9, 10 9, 10 8, 9 8, 9 9))','BuildingD'),
	('B5','POLYGON((1 2, 2 2, 2 1, 1 1, 1 2))','BuildingF');
INSERT INTO roads VALUES 
	('R1','LINESTRING(0 4.5, 12 4.5)','RoadX'),
	('R2','LINESTRING(7.5 0, 7.5 10.5)','RoadY');
INSERT INTO poi VALUES
	('P1','POINT(1 3.5)','G'),
	('P2','POINT(5.5 1.5)','H'),
	('P3','POINT(9.5 6)','I'),
	('P4','POINT(6.5 6)','J'),
	('P5','POINT(6 9.5)','K');
	
--ZADANIE 6
--a)Wyznacz całkowitą długość dróg w analizowanym mieście.  
SELECT SUM(ST_Length(geometry)) FROM roads;
--b)Wypisz geometrię (WKT), pole powierzchni oraz obwód poligonu reprezentującego budynek o nazwie BuildingA. 
SELECT name, ST_AsText(geometry) AS geometria_WKT, ST_Area(geometry) AS PolePowierzchni, ST_Perimeter(geometry) AS Obwod FROM buildings WHERE id='B1';
--c)Wypisz nazwy i pola powierzchni wszystkich poligonów w warstwie budynki. Wyniki posortuj alfabetycznie.
SELECT name, ST_Area(geometry) AS polepowierzchni FROM buildings ORDER BY name;
--d)Wypisz nazwy i obwody 2 budynków o największej powierzchni.
SELECT name, ST_Perimeter(geometry) AS obwod FROM buildings ORDER BY ST_Perimeter(geometry) DESC LIMIT 2;
--e)Wyznacz najkrótszą odległość między budynkiem BuildingC a punktem G.  
SELECT ST_Distance(buildings.geometry,poi.geometry) FROM buildings, poi WHERE buildings.id = 'B3' AND poi.id = 'P1';
--f)Wypisz pole powierzchni tej części budynku BuildingC, która znajduje się w odległości większej niż 0.5 od budynku BuildingB
SELECT ST_Area(ST_Difference('POLYGON((3 8, 5 8, 5 6, 3 6, 3 8))',ST_Buffer('POLYGON((4 7, 6 7, 6 5, 4 5, 4 7))', 0.5, 'join=mitre mitre_limit=5'))) AS polepowierzchni;
--g)Wybierz te budynki, których centroid (ST_Centroid) znajduje się powyżej drogi o nazwie RoadX.  
SELECT buildings.name, ST_Centroid(buildings.geometry) FROM buildings, roads WHERE ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_Centroid(roads.geometry)) AND roads.name = 'RoadX';
--8. Oblicz pole powierzchni tych części budynku BuildingC i poligonu o współrzędnych (4 7, 6 7, 6 8, 4 8, 4 7), które nie są wspólne dla tych dwóch obiektów.
SELECT ST_Area(ST_Difference((St_Union(geometry,ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))'))),ST_Intersection(geometry,ST_GeomFromText('POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')))) 
FROM buildings WHERE id='B3';


