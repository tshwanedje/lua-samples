-- TOOLS / LUA SCRIPT (NB, run on carefully filtered subset only)
-- TLex script to help convert Woordsoort text child to a list attribute in TLex
-- To use, first once-off run the INIT script via Tools / Exec Lua Script (which sets up some global variables used by the ENTRY script)
-- then right-click entry list and for all entries run the 'Lua ENTRY script'
-- dj2021-04

--tRequestLoadAll();
CHANGED=0;
MAXTODO=20000000;
TOTALNUMDONE=0;
SAVEAFTER=40;--Save after every N entries changed with ODBC (can set this to very high value for local dry run testing or .tldict file)
SECONDSSLEEPAFTERSAVE=0;--Sleep between saves? If running 'heavy' script on live server to minimize impact on other users
-- Uncomment for local dry-run test:
--MAXTODO=200000000;
--SAVEAFTER=400000000;
--SECONDSSLEEPAFTERSAVE=0;

-- Make sure we don't change timestamps and lastmodifiedby etc. [this is a new thing 2019-04, may change, API-unstable]
g_bAdminNoUpdateTimestamps=true;--API-unstable

-- Make sure we have a document open
local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end

ELEM1=DOC:GetDTD():FindElementByName("Woordsoort");
if ELEM1==nil then return "No desired element";end
ATTR=ELEM1:FindAttributeByName("Woordsoort");
if ATTR==nil then return "No desired attribute";end

LOADED=0;
tRequestLoadAll();

return "";
