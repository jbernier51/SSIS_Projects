create procedure CreateNumberList
as


DECLARE @startnum INT=1
DECLARE @endnum INT=100
;
WITH gen AS (
    SELECT @startnum AS NumberValue
    UNION ALL
    SELECT NumberValue+1 FROM gen WHERE NumberValue+1<=@endnum
)
SELECT * FROM gen
option (maxrecursion 10000)