SELECT SECTORS.SECTOR_LEVEL, COUNT(*) AS ROOM_COUNT
FROM (ROOMS JOIN SECTORS ON ROOMS.SECTOR_ID = SECTORS.SECTOR_ID)
GROUP BY SECTORS.SECTOR_LEVEL;