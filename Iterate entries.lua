-- Sample Lua script
--
-- Call a function on all entries in a specific section/language window
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

-- Iterate through all 'sections'/languages, and for each section, iterate through all entries in that section
local i, j;
for i=0,DOC:GetDictionary():GetNumLanguages()-1,1 do
	local SECTION = DOC:GetDictionary():GetLanguage(i); -- <- Note that section/language index in parameter here is 0-based, as are most/all indexes in our applications
	for j=0,SECTION:GetNumEntries()-1,1 do
		local ENTRY = SECTION:GetEntry(j);
		YourFunc(ENTRY);
	end
end
