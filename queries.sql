%sql
SELECT
  iyear,
  region_txt,
  COUNT(*) AS num_attacks
FROM bigdata_finals.default.clean_terror
GROUP BY iyear, region_txt
ORDER BY iyear, num_attacks DESC;


%sql
SELECT
  weaptype1_txt,
  SUM(nkill + nwound) AS total_casualties
FROM bigdata_finals.default.clean_terror
GROUP BY weaptype1_txt
ORDER BY total_casualties DESC;


%sql
SELECT
  targtype1_txt,
  SUM(nkill + nwound) AS total_casualties
FROM bigdata_finals.default.clean_terror
GROUP BY targtype1_txt
ORDER BY total_casualties DESC;
