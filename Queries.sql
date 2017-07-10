----------------
-- LIST 1 -----
----------------
SELECT imie_wroga "WROG", opis_incydentu "PRZEWINA"
FROM Wrogowie_Kocurow
WHERE TO_CHAR (data_incydentu, 'YYYY') = '2009';

SELECT imie, funkcja, w_stadku_od "Z NAMI OD"
FROM Kocury
WHERE plec = 'D' AND w_stadku_od BETWEEN '2005-09-01' AND '2007-07-31';

SELECT imie_wroga "WROG", gatunek, stopien_wrogosci "STOPIEN WROGOSCI" 
FROM Wrogowie
WHERE lapowka IS NULL
ORDER BY stopien_wrogosci;

SELECT imie || ' zwany ' || pseudo || ' (fun. ' || funkcja || ') lowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od
FROM Kocury
WHERE plec = 'M'
ORDER BY w_stadku_od DESC, pseudo ;

SELECT pseudo, REGEXP_REPLACE(REGEXP_REPLACE(pseudo, 'A', '#', 1, 1), 'L', '%', 1, 1) "Po wymianie A na # oraz L na %"
FROM Kocury
WHERE pseudo LIKE '%A%' AND pseudo LIKE '%L%';

SELECT imie, w_stadku_od "W stadku", przydzial_myszy "Zjadal", ADD_MONTHS(w_stadku_od, 6) "Podwyzka", (1.1*przydzial_myszy) "Zjada"
FROM Kocury
WHERE MONTHS_BETWEEN(CURRENT_DATE, w_stadku_od) > 72 AND TO_CHAR(w_stadku_od, 'MM') BETWEEN 03 AND 09;

SELECT imie, 3*przydzial_myszy "Myszy kwartalnie", NVL(3*myszy_extra, 0) "Kwartalne dodatki"
FROM Kocury
WHERE przydzial_myszy > NVL(3*myszy_extra, 0) AND przydzial_myszy >= 55;

SELECT imie, DECODE(SIGN((przydzial_myszy*12) + NVL(myszy_extra*12, 0) - 660), 0, 'Limit', -1, 'Ponizej 660', ((przydzial_myszy*12) + NVL(myszy_extra*12, 0))) "Zjada rocznie"
FROM Kocury;

SELECT pseudo, w_stadku_od "W stadku", CASE 
				WHEN ((TO_CHAR(w_stadku_od, 'DD') > 15) 
					OR (TO_CHAR(NEXT_DAY(TO_DATE('24-11-2015', 'DD-MM-YYYY'), 4), 'MM') != TO_CHAR(TO_DATE('24-11-2015', 'DD-MM-YYYY'), 'MM')))
				THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('24-11-2015', 'DD-MM-YYYY'), 1)) - 7, 4) 
				ELSE NEXT_DAY(LAST_DAY(TO_DATE('24-11-2015', 'DD-MM-YYYY')) - 7, 4)
				END"Wyplata"
FROM Kocury;

SELECT pseudo, w_stadku_od "W stadku", CASE 
				WHEN ((TO_CHAR(w_stadku_od, 'DD') > 15) 
					OR (TO_CHAR(NEXT_DAY(TO_DATE('27-11-2015', 'DD-MM-YYYY'), 4), 'MM') != TO_CHAR(TO_DATE('27-11-2015', 'DD-MM-YYYY'), 'MM')))
				THEN NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('27-11-2015', 'DD-MM-YYYY'), 1)) - 7, 4) 
				ELSE NEXT_DAY(LAST_DAY(TO_DATE('27-11-2015', 'DD-MM-YYYY')) - 7, 4)
				END"Wyplata"
FROM Kocury;

SELECT pseudo || ' - ' || (DECODE(COUNT(pseudo), 1, 'Unikalny', 'nieunikalny')) "Unikalnosc atr. PSEUDO"
FROM Kocury
GROUP BY pseudo;

SELECT szef || ' - ' || (DECODE(COUNT(pseudo), 1, 'Unikalny', 'nieunikalny')) "Unikalnosc atr. SZEF"
FROM Kocury
WHERE szef IS NOT NULL
GROUP BY szef;

SELECT pseudo "Pseudonim", COUNT(*) "Liczba wrogow"
FROM Wrogowie_Kocurow
GROUP BY pseudo
HAVING COUNT(*) > 1;

SELECT 'Liczba kotow = ' " ", COUNT(*) " ", ' lowi jako ' " ", funkcja " ", 'i zjada max. ' " ", MAX(przydzial_myszy + NVL(myszy_extra, 0)) " ", ' myszy miesiecznie' " "
FROM Kocury
WHERE plec = 'D' AND funkcja != 'SZEFUNIO'
GROUP BY funkcja
HAVING MAX(przydzial_myszy + NVL(myszy_extra, 0)) > 50;

SELECT nr_bandy "Nr bandy", plec, MIN(przydzial_myszy) "Minimalny przydzial"
FROM Kocury
GROUP BY nr_bandy, plec;

SELECT LEVEL "Poziom", pseudo "Pseudonim", funkcja, nr_bandy "Nr bandy"
FROM Kocury
WHERE plec = 'M'
CONNECT BY PRIOR pseudo = szef
START WITH funkcja = 'BANDZIOR';

SELECT (LPAD(LEVEL - 1, 4*(LEVEL - 1) + 1, '===>') || '           ' ||imie)  "Hierarchia", NVL(szef, 'Sam sobie panem') "Pseudo szefa", funkcja
FROM Kocury
WHERE NVL(myszy_extra, 0) > 0
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

SELECT LPAD(' ', 4 * (LEVEL - 1)) ||pseudo "Droga sluzbowa"
FROM Kocury
CONNECT BY PRIOR szef = pseudo
START WITH PLEC = 'M' AND myszy_extra IS NULL AND MONTHS_BETWEEN(SYSDATE, w_stadku_od) > 72;

----------------
-- LIST 2 -----
----------------

--17--
SELECT 
	K.pseudo "POLUJE W POLU", 
	NVL(K.przydzial_myszy, 0) "PRZYDZIAL MYSZY", 
	B.nazwa "BANDA"
FROM Kocury K 
	JOIN Bandy B ON K.nr_bandy = B.nr_bandy
WHERE NVL(przydzial_myszy, 0) > 50 
	AND teren IN ('POLE', 'CALOSC');

--18--
SELECT 
	K1.imie, 
	K1.w_stadku_od "POLUJE OD"
FROM 
	Kocury K1, 
	Kocury K2
WHERE k2.imie = 'JACEK' 
	AND K1.w_stadku_od < K2.w_stadku_od
ORDER BY k1.w_stadku_od DESC;

--19--
SELECT 
	K.imie "IMIE",
	K.funkcja "FUNKCJA",
	NVL(S1.imie, ' ') "SZEF 1",
	NVL(S2.imie, ' ') "SZEF 2",
	NVL(S3.imie, ' ') "SZEF 3"
FROM Kocury K
	LEFT JOIN Kocury S1 ON K.szef = S1.pseudo
	LEFT JOIN Kocury S2 ON S1.szef = S2.pseudo
	LEFT JOIN Kocury S3 ON S2.szef = S3.pseudo
WHERE K.funkcja IN ('KOT', 'MILUSIA');

--20--
SELECT 
	K.imie "IMIE KOTKI", 
	B.nazwa "NAZWA BANDY", 
	W.imie_wroga "IMIE WROGA", 
	W.stopien_wrogosci "OCENA WROGA", 
	WK.data_incydentu "DATA INC."
FROM Kocury K
	JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo
	JOIN Bandy B ON K.nr_bandy = B.nr_bandy
	JOIN Wrogowie W ON WK.imie_wroga = W.imie_wroga
WHERE K.plec = 'D'
	AND WK.data_incydentu > '2007-01-01';

--21--
SELECT 
	B.nazwa "NAZWA BANDY",
	COUNT(DISTINCT K.pseudo) "KOTY Z WROGAMI"
FROM Bandy B
	JOIN Kocury K ON B.nr_bandy = K.nr_bandy
	JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo
GROUP BY B.nazwa;

--22--
SELECT 
	MIN(K.funkcja), 
	K.pseudo "PSEUDONIM KOTA", 
	COUNT(K.pseudo) "LICZBA WROGOW"
FROM Kocury K
	JOIN Wrogowie_Kocurow WK ON K.pseudo = WK.pseudo
GROUP BY K.pseudo
HAVING COUNT(K.pseudo) > 1;

--23--	
SELECT 
	imie,
	12 * (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) "DAWKA ROCZNA",
	DECODE(12 * (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)), 864, LPAD(' ', 7), 'powyzej')|| ' 864' "DAWKA"
FROM Kocury
WHERE myszy_extra IS NOT NULL 
  AND 12 * (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) > 863
UNION
SELECT
	imie,
	12 * (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) "DAWKA ROCZNA",
	'ponizej 864' "DAWKA"
FROM Kocury
WHERE myszy_extra IS NOT NULL
  AND 12 * (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)) < 864
ORDER BY 2 DESC;

--24--A--
SELECT 
	B.nr_bandy "NR BANDY",
	MIN(nazwa),
	MIN(teren)
FROM Bandy B
	LEFT JOIN Kocury K ON B.nr_bandy = K.nr_bandy
GROUP BY B.nr_bandy
HAVING COUNT(K.pseudo) = 0;

--24--B--
SELECT 
	B.nr_bandy "NR BANDY",
	nazwa,
	teren
FROM Bandy B
	LEFT JOIN Kocury K ON B.nr_bandy = K.nr_bandy
MINUS
SELECT 
	B.nr_bandy "NR BANDY",
	nazwa,
	teren
FROM Bandy B
	JOIN Kocury K ON B.nr_bandy = K.nr_bandy;

--25--
SELECT
	K1.imie,
	K1.funkcja,
	K1.przydzial_myszy "PRZYDZIAL MYSZY"
FROM Kocury K1
WHERE NVL(przydzial_myszy, 0)  >= ALL (SELECT 3*NVL(przydzial_myszy, 0)
								FROM Kocury K2 JOIN Bandy B ON K2.nr_bandy = B.nr_bandy
								WHERE funkcja = 'MILUSIA' AND (B.teren IN ('SAD', 'CALOSC')));

--26--													
SELECT
	K1.funkcja,
	ROUND(AVG(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)),0) "SREDNIO NAJW. I NAJM. MYSZY"
FROM Kocury K1
WHERE K1.funkcja <> 'SZEFUNIO'
GROUP BY K1.funkcja
HAVING 
	AVG(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) = (SELECT MAX(AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)))
                                                    FROM Kocury K2
                                                    WHERE K2.funkcja <> 'SZEFUNIO'
                                                    GROUP BY K2.funkcja)
	OR
	AVG(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) = (SELECT MIN(AVG(NVL(K3.przydzial_myszy, 0) + NVL(K3.myszy_extra, 0)))
                                                    FROM Kocury K3
                                                    WHERE K3.funkcja <> 'SZEFUNIO'
                                                    GROUP BY K3.funkcja);

--27--A--													
SELECT
	K1.pseudo,
	NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0) "ZJADA"
FROM Kocury K1
WHERE (
  SELECT COUNT(DISTINCT NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) 
  FROM Kocury K2 
  WHERE NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0) 
        < NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) < &n
ORDER BY 2 DESC;

--27--B--
SELECT
	pseudo,
	NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) "ZJADA"
FROM Kocury
WHERE NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) IN (
	SELECT *
	FROM(
		SELECT DISTINCT (NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
		FROM Kocury
    ORDER BY 1 DESC)
  WHERE ROWNUM <= &n)
ORDER BY 2 DESC;

--27--C--
SELECT
	K1.pseudo,
	MIN(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) "ZJADA"
FROM Kocury K1 JOIN Kocury K2 ON NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)
                                  <= NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)
GROUP BY K1.pseudo
HAVING COUNT(DISTINCT NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) <= &n
ORDER BY 2 DESC;

--28--

SELECT 
	TO_CHAR(w_stadku_od, 'YYYY') "ROK",
	COUNT(pseudo) "LICZBA WSTAPIEN"
FROM Kocury
GROUP BY TO_CHAR(w_stadku_od, 'YYYY')
HAVING COUNT(TO_CHAR(w_stadku_od, 'YYYY')) IN ( 
	SELECT MAX(COUNT(TO_CHAR(w_stadku_od, 'YYYY')))
	FROM Kocury
	GROUP BY TO_CHAR(w_stadku_od, 'YYYY')
	HAVING COUNT(TO_CHAR(w_stadku_od, 'YYYY')) < (
		SELECT AVG(COUNT(TO_CHAR(w_stadku_od, 'YYYY')))
		FROM Kocury
		GROUP BY TO_CHAR(w_stadku_od, 'YYYY')))
	OR COUNT(TO_CHAR(w_stadku_od, 'YYYY')) IN ( 
	SELECT MIN(COUNT(TO_CHAR(w_stadku_od, 'YYYY')))
	FROM Kocury
	GROUP BY TO_CHAR(w_stadku_od, 'YYYY')
	HAVING COUNT(TO_CHAR(w_stadku_od, 'YYYY')) > (
		SELECT AVG(COUNT(TO_CHAR(w_stadku_od, 'YYYY')))
		FROM Kocury
		GROUP BY TO_CHAR(w_stadku_od, 'YYYY')))
UNION ALL 
SELECT
	'srednia' "ROK",
	ROUND(AVG(COUNT(TO_CHAR(w_stadku_od, 'YYYY'))), 2)
FROM Kocury
GROUP BY TO_CHAR(w_stadku_od, 'YYYY')
ORDER BY 2;

--29--A--
SELECT
	K1.imie,
	MIN(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) "ZJADA",
	MIN(K1.nr_bandy) "NR BANDY",
	AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) "SREDNIA BANDY"
FROM Kocury K1 JOIN Kocury K2 ON K1.nr_bandy = K2.nr_bandy
WHERE K1.plec = 'M'
GROUP BY
	K1.imie
HAVING MIN(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) 
		< AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0));

--29--B--
SELECT
	K1.imie,
	MIN(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) "ZJADA",
	MIN(K1.nr_bandy) "NR BANDY",
	MIN(Sr.srednia) "SREDNIA BANDY"
FROM Kocury K1 JOIN (
	SELECT
		K2.nr_bandy,
		AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)) srednia
	FROM Kocury K2
	GROUP BY K2.nr_bandy) Sr ON K1.nr_bandy = Sr.nr_bandy
WHERE K1.plec = 'M' 
GROUP BY
	K1.imie
HAVING MIN(NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0)) 
		< MIN(Sr.srednia);

--29--C--
SELECT
	K1.imie,
	NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0) "ZJADA",
	K1.nr_bandy,
	(SELECT 
		MIN(AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)))
		FROM Kocury K2
		WHERE K1.nr_bandy = K2.nr_bandy
		GROUP BY k2.nr_bandy) "SREDNIA BANDY"
FROM Kocury K1
WHERE 
	plec = 'M' 
	AND NVL(K1.przydzial_myszy, 0) + NVL(K1.myszy_extra, 0) < ALL(
	SELECT 
		MIN(AVG(NVL(K2.przydzial_myszy, 0) + NVL(K2.myszy_extra, 0)))
		FROM Kocury K2
		WHERE K1.nr_bandy = K2.nr_bandy
		GROUP BY k2.nr_bandy);

--30--
SELECT
	K1.imie,
	K1.w_stadku_od || ' ' "WSTAPIL DO STADKA",
	' ' " "
FROM Kocury K1
WHERE K1.pseudo IN(
	SELECT K2.pseudo
	FROM Kocury K2 JOIN Kocury K3 ON K2.nr_bandy = K3.nr_bandy
	GROUP BY K2.pseudo
	HAVING MIN(K2.w_stadku_od) <> MAX(K3.w_stadku_od)
		AND MIN(K2.w_stadku_od) <> MIN(K3.w_stadku_od))
UNION ALL
SELECT
	K1.imie,
	K1.w_stadku_od || '<---' "WSTAPIL DO STADKA",
	'NAJSTARSZY STAZEM W BANDZIE ' || B.nazwa " "
FROM Kocury K1 JOIN Bandy B ON K1.nr_bandy = B.nr_bandy
WHERE K1.pseudo IN(
	SELECT K2.pseudo
	FROM Kocury K2 JOIN Kocury K3 ON K2.nr_bandy = K3.nr_bandy
	GROUP BY K2.pseudo
	HAVING MIN(K2.w_stadku_od) = MIN(K3.w_stadku_od))
UNION ALL
SELECT
	K1.imie,
	K1.w_stadku_od || '<---' "WSTAPIL DO STADKA",
	'NAJMLODSZY STAZEM W BANDZIE ' || B.nazwa " "
FROM Kocury K1 JOIN Bandy B ON K1.nr_bandy = B.nr_bandy
WHERE K1.pseudo IN(
	SELECT K2.pseudo
	FROM Kocury K2 JOIN Kocury K3 ON K2.nr_bandy = K3.nr_bandy
	GROUP BY K2.pseudo
	HAVING MIN(K2.w_stadku_od) = MAX(K3.w_stadku_od))
ORDER BY 1;
--31--
DROP VIEW BandyWidok;

CREATE VIEW BandyWidok
AS SELECT
	B.nazwa "NAZWA_BANDY",
	AVG(NVL(K.przydzial_myszy, 0))"SRE_SPOZ",
	MAX(NVL(K.przydzial_myszy, 0))"MAX_SPOZ",
	MIN(NVL(K.przydzial_myszy, 0))"MIN_SPOZ",
	COUNT(K.pseudo)"KOTY",
	COUNT(K.myszy_extra)"KOTY_Z_DOD"
FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
GROUP BY B.nazwa;

SELECT *
FROM BandyWidok;

SELECT
	K.pseudo "PSEUDONIM",
	K.imie,
	K.funkcja,
	NVL(K.przydzial_myszy, 0) "ZJADA",
	'OD ' || BW.min_spoz || ' DO ' || BW.max_spoz "GRANICE SPOZYCIA",
	K.w_stadku_od "LOWI OD"
FROM Kocury K
	JOIN Bandy B ON K.nr_bandy = B.nr_bandy
	JOIN BandyWidok BW ON B.nazwa = BW.nazwa_bandy
WHERE K.pseudo = '&pseudonim';

--32--
DROP VIEW NajstarszeKoty;

CREATE VIEW NajstarszeKoty
AS SELECT
	K1.pseudo "PSEUDONIM"
FROM Kocury K1 
	JOIN Kocury K2 ON K1.w_stadku_od >= K2.w_stadku_od
WHERE K1.nr_bandy IN (SELECT nr_bandy FROM Bandy WHERE nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI'))
	AND K2.nr_bandy IN (SELECT nr_bandy FROM Bandy WHERE nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI'))
	AND K1.plec = 'M'
	AND K2.plec = 'M'
GROUP BY K1.pseudo
HAVING COUNT(K2.pseudo) <= 3
UNION ALL
SELECT
  K1.pseudo "PSEUDONIM"
FROM Kocury K1 
	JOIN Kocury K2 ON K1.w_stadku_od >= K2.w_stadku_od
WHERE K1.nr_bandy IN (SELECT nr_bandy FROM Bandy WHERE nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI'))
	AND K2.nr_bandy IN (SELECT nr_bandy FROM Bandy WHERE nazwa IN ('CZARNI RYCERZE', 'LACIACI MYSLIWI'))
	AND K1.plec = 'D'
	AND K2.plec = 'D'
GROUP BY K1.pseudo
HAVING COUNT(K2.pseudo) <= 3;

SELECT
  K.pseudo "PSEUDONIM",
  K.plec "PLEC",
  NVL(K.przydzial_myszy, 0) "MYSZY PRZED PODW.",
  NVL(K.myszy_extra, 0) "EXTRA PRZED PODW."
FROM Kocury K JOIN NajstarszeKoty NK ON K.pseudo = NK.pseudonim;

UPDATE Kocury K1
SET
	K1.przydzial_myszy = NVL(K1.przydzial_myszy, 0) + 
		DECODE(K1.plec, 'M', 10, 'D', 0.1*(
			SELECT MIN(NVL(K2.przydzial_myszy, 0))
			FROM Kocury K2)),
	K1.myszy_extra = NVL(K1.myszy_extra, 0) + 0.15*(
		SELECT AVG(NVL(K2.myszy_extra, 0))
		FROM Kocury K2
		WHERE K2.nr_bandy = K1.nr_bandy)
WHERE pseudo IN (
    SELECT *
    FROM NajstarszeKoty);

SELECT
  K.pseudo "PSEUDONIM",
  K.plec "PLEC",
  NVL(K.przydzial_myszy, 0) "MYSZY PO PODW.",
  NVL(K.myszy_extra, 0) "EXTRA PO PODW."
FROM Kocury K JOIN NajstarszeKoty NK ON K.pseudo = NK.pseudonim;

ROLLBACK;

--33--
SELECT 
  DECODE(F.plec, 'M', ' ', F.nazwa) "NAZWA BANDY",
  DECODE(F.plec, 'D', 'Kotka', 'M', 'Kocor', ' ') "PLEC",
  TO_CHAR(F.ile) "ILE",
  TO_CHAR(F.szefunio) "SZEFUNIO",
  TO_CHAR(F.bandzior) "BANDZIOR",
  TO_CHAR(F.lowczy) "LOWCZY",
  TO_CHAR(F.lapacz) "LAPACZ",
  TO_CHAR(F.kot) "KOT",
  TO_CHAR(F.milusia) "MILUSIA",
  TO_CHAR(F.dzielczy) "DZIELCZY",
  TO_CHAR(F.suma) "SUMA"
FROM (
	SELECT 
		MIN(B.nazwa) nazwa,
		K.plec plec,
		COUNT(*) ile,
		SUM(DECODE(K.funkcja, 'SZEFUNIO', NVL(K.przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0)) szefunio,
		SUM(DECODE(K.funkcja, 'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0)) bandzior,
		SUM(DECODE(K.funkcja, 'LOWCZY', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0)) lowczy,
		SUM(DECODE(K.funkcja, 'LAPACZ', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0)) lapacz,
		SUM(DECODE(K.funkcja, 'KOT', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0)) kot,
		SUM(DECODE(K.funkcja, 'MILUSIA', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0)) milusia,
		SUM(DECODE(K.funkcja, 'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0)) dzielczy,
		SUM(NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0)) suma		
	FROM Kocury K JOIN Bandy B ON K.nr_bandy = B.nr_bandy
	GROUP BY K.plec, B.nazwa
	ORDER BY B.nazwa, K.plec) F
UNION ALL 
SELECT 
	'Z----------------' nazwa,
	'------' plec,
	'----' ile,
	'---------' szefunio,
	'---------' bandzior,
	'---------' lowczy,
	'---------' lapacz,
	'---------' kot,
	'---------' milusia,
	'---------' dzielczy,
	'---------' suma
FROM DUAL
UNION ALL 
SELECT 
	'ZJADA RAZEM' nazwa,
	' ' plec,
	' ' ile,
	TO_CHAR(SUM(DECODE(K.funkcja, 'SZEFUNIO', NVL(K.przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0))) szefunio,
	TO_CHAR(SUM(DECODE(K.funkcja, 'BANDZIOR', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0))) bandzior,
	TO_CHAR(SUM(DECODE(K.funkcja, 'LOWCZY', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0))) lowczy,
	TO_CHAR(SUM(DECODE(K.funkcja, 'LAPACZ', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0))) lapacz,
	TO_CHAR(SUM(DECODE(K.funkcja, 'KOT', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0))) kot,
	TO_CHAR(SUM(DECODE(K.funkcja, 'MILUSIA', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0))) milusia,
	TO_CHAR(SUM(DECODE(K.funkcja, 'DZIELCZY', NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0), 0))) dzielczy,
	TO_CHAR(SUM(NVL(przydzial_myszy, 0) + NVL(K.myszy_extra, 0))) suma		
FROM Kocury K;

----------------
-- LIST 3 -----
----------------

--34--
DECLARE
	s_funkcja Kocury.funkcja%TYPE := '&funkcja';
	liczba NUMBER(3);
BEGIN
	SELECT COUNT(pseudo)
	INTO liczba
	FROM Kocury
	WHERE funkcja = s_funkcja;
  
  IF liczba <> 0
	THEN DBMS_OUTPUT.PUT_LINE(s_funkcja);
	ELSE DBMS_OUTPUT.PUT_LINE('Nie znaleziono kota o podanej funkcji!');
  END IF;
END;

--35--
DECLARE
	in_pseudo Kocury.pseudo%TYPE := '&ps';
	calkowity_przydzial NUMBER(5);
	im Kocury.imie%TYPE;
	miesiac VARCHAR2(2);
BEGIN
	SELECT
		(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))*12,
		imie,
		TO_CHAR(w_stadku_od, 'MM')
	INTO
		calkowity_przydzial,
		im,
		miesiac
	FROM Kocury
	WHERE pseudo = in_pseudo;
	
	IF calkowity_przydzial > 700
	THEN DBMS_OUTPUT.PUT_LINE(im || ' - calkowity roczny przydzial myszy > 700');
	ELSIF REGEXP_LIKE(im, 'A')
	THEN DBMS_OUTPUT.PUT_LINE(im || ' - imie zawiera litere A');
	ELSIF miesiac = '01'
	THEN DBMS_OUTPUT.PUT_LINE(im || ' - styczen jest miesiacem przystapienia do stada');
	ELSE DBMS_OUTPUT.PUT_LINE(im || ' - nie odpowiada kryteriom');
	END IF;
END;

--36--
DECLARE
	podwyzka NUMBER(2);
	liczba_podwyzek NUMBER(4) := 0;
	calkowity_przydzial NUMBER(5);
	CURSOR koty IS
		SELECT NVL(K.przydzial_myszy, 0) przydzial, F.max_myszy
		FROM Kocury K JOIN Funkcje F ON K.funkcja = F.funkcja
		ORDER BY 2 ASC
		FOR UPDATE OF przydzial_myszy;
	kot koty%ROWTYPE;
BEGIN
	SELECT SUM(NVL(przydzial_myszy, 0))
	INTO calkowity_przydzial
	FROM Kocury;
	
	OPEN koty;
	LOOP
		EXIT WHEN calkowity_przydzial > 1050;
	
		FETCH koty INTO kot;
		IF koty%NOTFOUND
		THEN
			CLOSE koty;
			OPEN koty;
			FETCH koty INTO kot;
		END IF;
		
		podwyzka := ROUND(kot.przydzial * 1.1);
    
		IF podwyzka > kot.max_myszy
		THEN podwyzka := kot.max_myszy;
		END IF;
		
		podwyzka := podwyzka - kot.przydzial;
		
		IF podwyzka > 0
		THEN 
			liczba_podwyzek := liczba_podwyzek + 1;
			calkowity_przydzial := calkowity_przydzial + podwyzka;
      UPDATE Kocury
      SET przydzial_myszy = przydzial_myszy + podwyzka
      WHERE CURRENT OF koty;
		END IF;
	END LOOP;
  
  CLOSE koty;

	DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || TO_CHAR(calkowity_przydzial) || ' Zmian - ' || TO_CHAR(liczba_podwyzek));
	
	ROLLBACK;
END;

--37--
DECLARE
	licznik NUMBER(4) := 1;
BEGIN
	DBMS_OUTPUT.PUT_LINE(LPAD('Nr', 3, ' ') || LPAD('Pseudonim', 12, ' ') || LPAD('Zjada', 8, ' '));
	FOR kot IN (
		SELECT
			pseudo,
			NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) przydzial
		FROM Kocury
		ORDER BY 2 DESC)
	LOOP
	EXIT WHEN licznik > 5;
	
	DBMS_OUTPUT.PUT_LINE(LPAD(TO_CHAR(licznik), 3, ' ') || LPAD(kot.pseudo, 12, ' ') || LPAD(TO_CHAR(kot.przydzial), 8, ' '));
	
	licznik := licznik + 1;
	END LOOP;
END;

--38--
DECLARE
  max_l_szefow NUMBER(2) := &num;
  max_licznik NUMBER(2) := 0;
  licznik NUMBER(2);
  i NUMBER (2) := 1;
  TYPE tab IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;
  output_tab tab;
BEGIN
	FOR kot IN (
		SELECT
			pseudo,
			imie,
			szef
		FROM Kocury
		WHERE funkcja IN ('KOT', 'MILUSIA'))
	LOOP
		licznik := 0;
		
		output_tab(i) := RPAD(kot.imie, 20, ' ');
    
		LOOP
			EXIT WHEN kot.szef IS NULL OR licznik = max_l_szefow;
      	
			SELECT
				pseudo,
				imie,
				szef
			INTO kot
			FROM Kocury
			WHERE pseudo = kot.szef;
			
			output_tab(i) := output_tab(i) || RPAD('| ' || kot.imie, 20, ' ');
      
      licznik := licznik + 1;
      
      IF licznik > max_licznik
			THEN max_licznik := licznik;
      END IF;
		END LOOP;
		
		i := i + 1;
	END LOOP;
	
	DBMS_OUTPUT.PUT(RPAD('Imie', 20, ' '));
  
  FOR i IN 1 .. max_licznik
	LOOP
		DBMS_OUTPUT.PUT(RPAD('| Szef ' || TO_CHAR(i), 20, ' '));
	END LOOP;
	
  DBMS_OUTPUT.NEW_LINE;
  
	i := 1;
	LOOP
		EXIT WHEN NOT output_tab.EXISTS(i);
	
		DBMS_OUTPUT.PUT_LINE(output_tab(i));
    
    i := i + 1;
	END LOOP;
END;

--39--
DECLARE
	numer_bandy NUMBER(3) := &numer;
	nazwa_bandy VARCHAR2(20) := &nazwa;
	teren_bandy VARCHAR2(15) := &teren;
	exception_message VARCHAR2(50);
	data_collision_flag BOOLEAN;
	data_collision EXCEPTION;
	invalid_number EXCEPTION;
BEGIN
	IF numer_bandy < 0
	THEN RAISE invalid_number;
	END IF;
	FOR banda IN (
		SELECT
			nr_bandy,
			nazwa,
			teren
		FROM Bandy)
	LOOP
		IF numer_bandy = banda.nr_bandy
		THEN
			IF data_collision_flag
			THEN exception_message := exception_message || ', ';
			END IF;
			
			exception_message := exception_message || numer_bandy;
			data_collision_flag := TRUE;
		END IF;
		
		IF nazwa_bandy = banda.nazwa
		THEN
			IF data_collision_flag
			THEN exception_message := exception_message || ', ';
			END IF;
			
			exception_message := exception_message || nazwa_bandy;
			data_collision_flag := TRUE;
		END IF;
		
		IF teren_bandy = banda.teren
		THEN
			IF data_collision_flag
			THEN exception_message := exception_message || ', ';
			END IF;
			
			exception_message := exception_message || teren_bandy;
			data_collision_flag := TRUE;
		END IF;
	END LOOP;
	IF data_collision_flag
	THEN RAISE data_collision;
	END IF;
	
	INSERT INTO BANDY
	VALUES (numer_bandy, nazwa_bandy, teren_bandy);
EXCEPTION
	WHEN data_collision
		THEN DBMS_OUTPUT.PUT_LINE(exception_message || ': juz istnieje');
	WHEN invalid_number
		THEN DBMS_OUTPUT.PUT_LINE('Numer mniejszy od zera');
END;

ROLLBACK;

--40--
CREATE OR REPLACE PROCEDURE dodaj_bande (numer_bandy NUMBER, nazwa_bandy VARCHAR2, teren_bandy VARCHAR2)
AS
	exception_message VARCHAR2(50);
	data_collision_flag BOOLEAN;
	data_collision EXCEPTION;
	invalid_number EXCEPTION;
BEGIN
	IF numer_bandy < 0
	THEN RAISE invalid_number;
	END IF;
	FOR banda IN (
		SELECT
			nr_bandy,
			nazwa,
			teren
		FROM Bandy)
	LOOP
		IF numer_bandy = banda.nr_bandy
		THEN
			IF data_collision_flag
			THEN exception_message := exception_message || ', ';
			END IF;
			
			exception_message := exception_message || numer_bandy;
			data_collision_flag := TRUE;
		END IF;
		
		IF nazwa_bandy = banda.nazwa
		THEN
			IF data_collision_flag
			THEN exception_message := exception_message || ', ';
			END IF;
			
			exception_message := exception_message || nazwa_bandy;
			data_collision_flag := TRUE;
		END IF;
		
		IF teren_bandy = banda.teren
		THEN
			IF data_collision_flag
			THEN exception_message := exception_message || ', ';
			END IF;
			
			exception_message := exception_message || teren_bandy;
			data_collision_flag := TRUE;
		END IF;
	END LOOP;
	IF data_collision_flag
	THEN RAISE data_collision;
	END IF;
	
	INSERT INTO Bandy
	VALUES (numer_bandy, nazwa_bandy, teren_bandy);
EXCEPTION
	WHEN data_collision
		THEN DBMS_OUTPUT.PUT_LINE(exception_message || ': juz istnieje');
	WHEN invalid_number
		THEN DBMS_OUTPUT.PUT_LINE('Numer mniejszy od zera');
END;

EXECUTE dodaj_bande(2, 'CZARNI RYCERZE', 'POLE');

ROLLBACK;

--41--
CREATE OR REPLACE TRIGGER kolejna_banda
BEFORE INSERT
ON Bandy
FOR EACH ROW
DECLARE
	nastepny_numer Bandy.nr_bandy%TYPE;
BEGIN
	SELECT MAX(nr_bandy) + 1
	INTO nastepny_numer
	FROM Bandy;
	
	:NEW.nr_bandy := nastepny_numer;
END;

EXECUTE DODAJ_BANDE(10, 'ASD', 'ASD');

ROLLBACK;

--42--A--
CREATE OR REPLACE PACKAGE wirus_pamiec
AS
	TYPE Koty 
	IS TABLE OF Kocury.pseudo%TYPE
	INDEX BY BINARY_INTEGER;
	
	us NUMBER(4);
	nieus Koty;
	puste Koty;
	
	unikaj_rekursji BOOLEAN DEFAULT FALSE;
	
	przydzial_tygrysa Kocury.przydzial_myszy%TYPE;
END wirus_pamiec;


CREATE OR REPLACE TRIGGER wirus_inicjalizacja
BEFORE UPDATE OF przydzial_myszy
ON Kocury
BEGIN
  IF NOT wirus_pamiec.unikaj_rekursji
  THEN
	 wirus_pamiec.us := 0;
	 wirus_pamiec.nieus := wirus_pamiec.puste;
	 
	 SELECT przydzial_myszy
	 INTO wirus_pamiec.przydzial_tygrysa
	 FROM Kocury
	 WHERE pseudo = 'TYGRYS';
  END IF;
END;

CREATE OR REPLACE TRIGGER wirus_przygotowanie
BEFORE UPDATE OF przydzial_myszy
ON Kocury
FOR EACH ROW
DECLARE
	podwyzka Kocury.przydzial_myszy%TYPE;
BEGIN
	IF NOT wirus_pamiec.unikaj_rekursji
	THEN
    podwyzka := (:NEW.przydzial_myszy - :OLD.przydzial_myszy);
  
		IF podwyzka < 0.1 * wirus_pamiec.przydzial_tygrysa
		THEN
			wirus_pamiec.nieus(wirus_pamiec.nieus.COUNT + 1) := :NEW.pseudo;
		ELSE
			wirus_pamiec.us := wirus_pamiec.us + 1;
		END IF;
	END IF;
END;

CREATE OR REPLACE TRIGGER wirus
AFTER UPDATE OF przydzial_myszy
ON Kocury
BEGIN
	IF NOT wirus_pamiec.unikaj_rekursji
	THEN
		BEGIN
			wirus_pamiec.unikaj_rekursji := TRUE;
			
			SET myszy_extra = NVL(myszy_extra, 0) + 5 * wirus_pamiec.us;
			
			FOR i IN 1 .. wirus_pamiec.nieus.COUNT
			LOOP
				UPDATE Kocury
				SET myszy_extra = NVL(myszy_extra, 0) + 5
				WHERE pseudo = wirus_pamiec.nieus(i);
			
				UPDATE Kocury
				SET przydzial_myszy = 0.9 * przydzial_myszy
				WHERE pseudo = 'TYGRYS';
			END LOOP;
			
			wirus_pamiec.unikaj_rekursji := FALSE;
		EXCEPTION
			WHEN OTHERS 
			THEN
				wirus_pamiec.unikaj_rekursji := FALSE;
				RAISE;
		END;
	END IF;
END;

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 15
WHERE pseudo = 'LOLA';

ROLLBACK;

DROP PACKAGE wirus_pamiec;
DROP TRIGGER wirus_inicjalizacja;
DROP TRIGGER wirus_przygotowanie;
DROP TRIGGER wirus;

--42--B--
CREATE OR REPLACE PACKAGE rekursja
AS unikaj_rekursji BOOLEAN DEFAULT FALSE;
END rekursja;

CREATE OR REPLACE TRIGGER compound_wirus
FOR UPDATE OF przydzial_myszy
ON Kocury
COMPOUND TRIGGER
	TYPE Koty 
	IS TABLE OF Kocury.pseudo%TYPE
	INDEX BY BINARY_INTEGER;
	
	us NUMBER(4) := 0;
	nieus Koty;
	
	przydzial_tygrysa Kocury.przydzial_myszy%TYPE;
	
	BEFORE STATEMENT IS	
	BEGIN
		IF NOT rekursja.unikaj_rekursji
		THEN
			SELECT przydzial_myszy
			INTO przydzial_tygrysa
			FROM Kocury
			WHERE pseudo = 'TYGRYS';
		END IF;
	END BEFORE STATEMENT;
	
	BEFORE EACH ROW IS
		podwyzka Kocury.przydzial_myszy%TYPE;
	BEGIN
		IF NOT rekursja.unikaj_rekursji
		THEN
		podwyzka := (:NEW.przydzial_myszy - :OLD.przydzial_myszy);
    
			IF podwyzka < 0.1 * przydzial_tygrysa
			THEN
				nieus(nieus.COUNT + 1) := :NEW.pseudo;
			ELSE
				us := us + 1;
			END IF;
		END IF;
	END BEFORE EACH ROW;
	
	AFTER STATEMENT IS
	BEGIN 
		IF NOT rekursja.unikaj_rekursji
		THEN
			BEGIN
				rekursja.unikaj_rekursji := TRUE;
				
				UPDATE Kocury
				SET myszy_extra = NVL(myszy_extra, 0) + 5 * us
				WHERE pseudo = 'TYGRYS';
				
				FOR i IN 1 .. nieus.COUNT
				LOOP
					UPDATE Kocury
					SET myszy_extra = NVL(myszy_extra, 0) + 5
					WHERE pseudo = nieus(i);
				
					UPDATE Kocury
					SET przydzial_myszy = 0.9 * przydzial_myszy
					WHERE pseudo = 'TYGRYS';
				END LOOP;
				
				rekursja.unikaj_rekursji := FALSE;
			EXCEPTION
				WHEN OTHERS 
				THEN
					rekursja.unikaj_rekursji := FALSE;
					RAISE;
			END;
		END IF;
	END AFTER STATEMENT;
END compound_wirus;

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 5
WHERE pseudo = 'LOLA';

ROLLBACK;

DROP PACKAGE rekursja;
DROP TRIGGER compound_wirus;

--43--
DECLARE
	TYPE Tab 
	IS TABLE OF VARCHAR2(200)
	INDEX BY BINARY_INTEGER;
  
  CURSOR funk IS(
    SELECT funkcja
		FROM Funkcje);
	
	tabela Tab;
	liczba_kol NUMBER(2) := 0;
	wartosc NUMBER (5);
  pos NUMBER (5);
BEGIN
	tabela(1) := RPAD('NAZWA BANDY', 20, ' ') || ' ' || RPAD('PLEC', 6, ' ') || ' ' || LPAD('ILE', 4, ' ');
	FOR f IN funk
	LOOP
		liczba_kol := liczba_kol + 1;
		tabela(1) := tabela(1) || ' ' || LPAD(f.funkcja, 10, ' ');
	END LOOP;
	tabela(1) := tabela(1) || ' ' || LPAD('SUMA', 8, ' ');
	
	tabela(2) := RPAD('-', 20, '-') || ' ' || RPAD('-', 6, '-') || ' ' || LPAD('-', 4, '-');
	FOR i IN 1 .. liczba_kol
	LOOP
		tabela(2) := tabela(2) || ' ' || LPAD('-', 10, '-');
	END LOOP;
	tabela(2) := tabela(2) || ' ' || LPAD('-', 8, '-');
	
  pos := 3;
	FOR grupa IN (
		SELECT
			B.nazwa,
			K.plec,
			COUNT(pseudo) liczba,
			MIN(B.nr_bandy) nr_bandy,
			NVL(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)), 0) suma
		FROM Bandy B JOIN Kocury K ON B.nr_bandy = K.nr_bandy
		GROUP BY B.nazwa, K.plec
    ORDER BY B.nazwa, K.plec)
	LOOP
		IF grupa.plec = 'D'
		THEN
			tabela(pos) := RPAD(grupa.nazwa, 20, ' ') || ' ' || RPAD('Kotka', 6, ' ') || ' ' || LPAD(TO_CHAR(grupa.liczba), 4, ' ');
		ELSE
			tabela(pos) := RPAD(' ', 20, ' ') || ' ' || RPAD('Kocor', 6, ' ') || ' ' || LPAD(TO_CHAR(grupa.liczba), 4, ' ');
		END IF;
		
		FOR f IN funk
		LOOP
      SELECT NVL(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)),0)
      INTO wartosc
      FROM Kocury K2
      WHERE K2.nr_bandy = grupa.nr_bandy
        AND K2.plec = grupa.plec
        AND K2.funkcja = f.funkcja;
    
			tabela(pos) := tabela(pos) || ' ' || LPAD(TO_CHAR(wartosc), 10, ' ');
		END LOOP;
		
		tabela(pos) := tabela(pos) || ' ' || LPAD(TO_CHAR(grupa.suma), 8, ' ');
    
    pos := pos + 1;
	END LOOP;
	
	tabela(pos) := RPAD('Z', 20, '-') || ' ' || RPAD('-', 6, '-') || ' ' || LPAD('-', 4, '-');
	FOR i IN 1 .. liczba_kol
	LOOP
		tabela(pos) := tabela(pos) || ' ' || LPAD('-', 10, '-');
	END LOOP;
	tabela(pos) := tabela(pos) || ' ' || LPAD('-', 8, '-');
	
  pos := pos + 1;
  
	tabela(pos) := RPAD('ZJADA RAZEM', 20, ' ') || ' ' || RPAD(' ', 6, ' ') || ' ' || LPAD(' ', 4, ' ');
	FOR f IN funk
	LOOP
    SELECT NVL(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)),0)
      INTO wartosc
      FROM Kocury K3
      WHERE K3.funkcja = f.funkcja;
  
		tabela(pos) := tabela(pos) || ' ' || LPAD(wartosc, 10, ' ');
	END LOOP;
	
	SELECT NVL(SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)), 0)
	INTO wartosc
	FROM Kocury;
	
	tabela(pos) := tabela(pos) || ' ' || LPAD(wartosc, 8, ' ');
	
	FOR i IN 1 .. tabela.LAST
	LOOP
		DBMS_OUTPUT.PUT_LINE(tabela(i));
	END LOOP;
END;

--44--
CREATE OR REPLACE PACKAGE obsluga_kotow
AS
	FUNCTION policz_podatek(pseudonim VARCHAR2) RETURN NUMBER;
	PROCEDURE dodaj_bande (numer_bandy NUMBER, nazwa_bandy VARCHAR2, teren_bandy VARCHAR2);
END obsluga_kotow;

CREATE OR REPLACE PACKAGE BODY obsluga_kotow
AS
	FUNCTION policz_podatek(pseudonim VARCHAR2)
	RETURN NUMBER
	IS
		przychody Kocury.przydzial_myszy%TYPE;
		podatek Kocury.przydzial_myszy%TYPE;
		podwladni NUMBER(4);
		wrogowie NUMBER(4);
    od_kiedy Kocury.w_stadku_od%TYPE;
	BEGIN
		SELECT NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)
    INTO przychody
		FROM Kocury
		WHERE pseudo = pseudonim;
		
		podatek := ROUND(0.05*przychody + 0.5);
	
		SELECT COUNT(pseudo)
		INTO podwladni
		FROM Kocury
		WHERE szef = pseudonim;
		
		IF podwladni = 0
		THEN 
			podatek := podatek + 2;
		END IF;
		
		SELECT COUNT(pseudo)
		INTO wrogowie
		FROM Wrogowie_Kocurow
		WHERE pseudo = pseudonim;
		
		IF wrogowie = 0
		THEN
			podatek := podatek + 1;
		END IF;
		
    SELECT w_stadku_od
    INTO od_kiedy
    FROM Kocury
    WHERE pseudo = pseudonim;
    
		IF SYSDATE - od_kiedy < 365 * 5
		THEN
			podatek := podatek + 2;
		END IF;
		
		RETURN podatek;
	END policz_podatek;
	PROCEDURE dodaj_bande (numer_bandy NUMBER, nazwa_bandy VARCHAR2, teren_bandy VARCHAR2)
	AS
		exception_message VARCHAR2(50);
		data_collision_flag BOOLEAN;
		data_collision EXCEPTION;
		invalid_number EXCEPTION;
	BEGIN
		IF numer_bandy < 0
		THEN RAISE invalid_number;
		END IF;
		FOR banda IN (
			SELECT
				nr_bandy,
				nazwa,
				teren
			FROM Bandy)
		LOOP
			IF numer_bandy = banda.nr_bandy
			THEN
				IF data_collision_flag
				THEN exception_message := exception_message || ', ';
				END IF;
				
				exception_message := exception_message || numer_bandy;
				data_collision_flag := TRUE;
			END IF;
			
			IF nazwa_bandy = banda.nazwa
			THEN
				IF data_collision_flag
				THEN exception_message := exception_message || ', ';
				END IF;
				
				exception_message := exception_message || nazwa_bandy;
				data_collision_flag := TRUE;
			END IF;
			
			IF teren_bandy = banda.teren
			THEN
				IF data_collision_flag
				THEN exception_message := exception_message || ', ';
				END IF;
				
				exception_message := exception_message || teren_bandy;
				data_collision_flag := TRUE;
			END IF;
		END LOOP;
		IF data_collision_flag
		THEN RAISE data_collision;
		END IF;
	
		INSERT INTO Bandy
		VALUES (numer_bandy, nazwa_bandy, teren_bandy);
	EXCEPTION
		WHEN data_collision
			THEN DBMS_OUTPUT.PUT_LINE(exception_message || ': juz istnieje');
		WHEN invalid_number
			THEN DBMS_OUTPUT.PUT_LINE('Numer mniejszy od zera');
	END dodaj_bande;
END obsluga_kotow;

BEGIN
  DBMS_OUTPUT.PUT_LINE(RPAD('PSEUDONIM', 15, ' ') || LPAD('PODATEK', 10, ' '));

  FOR kot IN (
    SELECT pseudo
    FROM Kocury)
  LOOP
    DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo, 15, ' ') || LPAD(obsluga_kotow.policz_podatek(kot.pseudo), 10, ' '));
  END LOOP;
END;

DROP PACKAGE obsluga_kotow;

--45--
CREATE TABLE Dodatki_extra(
	nr_dodatku NUMBER(10) NOT NULL CONSTRAINT dodatki_pk PRIMARY KEY,
	pseudo VARCHAR2(15) NOT NULL CONSTRAINT dodatki_pseudo_fk REFERENCES Kocury (pseudo),
	dod_extra NUMBER(4) NOT NULL);

CREATE OR REPLACE TRIGGER odwet
FOR UPDATE OF przydzial_myszy
ON Kocury
WHEN (NEW.funkcja = 'MILUSIA'
	AND NEW.przydzial_myszy > OLD.przydzial_myszy)
COMPOUND TRIGGER
	TYPE tab
	IS TABLE OF Kocury.pseudo%TYPE
	INDEX BY BINARY_INTEGER;
	
	milusie tab;
	
	BEFORE STATEMENT
  IS
	BEGIN
		FOR kot IN (
			SELECT K.pseudo
			FROM Kocury K 
			WHERE K.funkcja = 'MILUSIA')
		LOOP
			milusie(NVL(milusie.LAST, 0) + 1) := kot.pseudo;
		END LOOP;
	END BEFORE STATEMENT;
	
	AFTER EACH ROW
  IS
		nastepny_numer NUMBER(10);
	BEGIN 
		IF LOGIN_USER = 'TYGRYS' OR LOGIN_USER = 'C##212745'
		THEN
			FOR i IN 1 .. milusie.COUNT
			LOOP
        SELECT NVL(MAX(NVL(nr_dodatku,0)),0) + 1
        INTO nastepny_numer
        FROM Dodatki_extra;
      
				EXECUTE IMMEDIATE 'INSERT INTO Dodatki_extra
				VALUES ('|| nastepny_numer ||',''' || milusie(i) || ''', -10 )';
			END LOOP;
		END IF;
	END AFTER EACH ROW;
END odwet;

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 5
WHERE pseudo = 'LOLA';

ROLLBACK;

DROP TABLE Dodatki_extra;
DROP TRIGGER odwet;
