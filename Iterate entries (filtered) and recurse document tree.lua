-- Sample Lua script
--
-- Call a function on all entries in the currently selected section window that
-- pass the currently applied filter, and recurse all nodes in document tree
-- 
-- To run this:
-- 1. Open TLex/tlTerm/tlDatabase, and open your document
-- 2. Go to 'Tools' menu, select "Execute Lua Script", and select this file

-- Make sure we have a document open
local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end

function YourFunc(ENTRY,NODE)
	-- Log to application log just to help show it's working - comment out log if it's slowing things down for your script
	if ENTRY==NODE then
		tLuaLog('Entry:'..ENTRY:GetLemmaSign());
	end

	-- Typically your own custom document node processing might go here

	-- Recurse through child nodes (child XML elements or text nodes etc.)
	local k;
	for k=0,NODE:GetNumChildren()-1,1 do
		local CHILD = NODE:GetChild(k);
		YourFunc(ENTRY,CHILD);
	end
end

-- Get currently selected section/language window in the application
local FRAME = tFrameWindow();
local SECTIONWND = FRAME:GetSelectedSectionWindow();
local SECTION = SECTIONWND:GetLanguage();
-- Get filter tool
local FILTER = SECTIONWND:GetCurrentFilter();
local i;
for i=0,SECTION:GetNumEntries()-1,1 do
	local ENTRY = SECTION:GetEntry(i);
	local include = true; -- <- If no filter is currently applied at all, then we run on all entries by default
	if FILTER~=nil then
		include = FILTER:Pass(ENTRY); -- PassFilter returns true if entry passes the filter, otherwise false
	end

	if include then
		YourFunc(ENTRY,ENTRY);
	end
end

--Script terminated without error
return "Success";
