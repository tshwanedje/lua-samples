-- Sample Lua script
--
-- Call a function on all entries in the currently selected section window that
-- pass the currently applied filter.
--
-- To run this:
-- 1. Open TLex/tlTerm/tlDatabase
-- 2. Go to 'Tools' menu, select "Execute Lua Script", and select this file

function YourFunc(ENTRY)
	tLuaLog(ENTRY:GetLemmaSign());
end

-- Make sure we have a document open
local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end

-- Get currently selected section/language window in the application
local FRAME = tFrameWindow();
local SECTIONWND = FRAME:GetSelectedSectionWindow();
local SECTION = SECTIONWND:GetLanguage();
-- Get filter tool
local FILTER = SECTIONWND:GetFilter();
local i;
for i=0,SECTION:GetNumEntries()-1,1 do
	local ENTRY = SECTION:GetEntry(i);
	local include = true; -- <- If no filter is currently applied at all, then we run on all entries by default
	if FILTER:IsFiltered() then
		include = FILTER:PassFilter(ENTRY); -- PassFilter returns true if entry passes the filter, otherwise false
	end

	if include then	
		YourFunc(ENTRY);
	end
end
