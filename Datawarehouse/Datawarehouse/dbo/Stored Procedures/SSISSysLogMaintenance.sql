

CREATE procedure dbo.SSISSysLogMaintenance
as
begin

delete sysssislog where DATEDIFF(d, starttime, getdate()) > 14


end