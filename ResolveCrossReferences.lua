-- Sample Lua script showing basic resolving of plain XML elements to TLex smart cross-reference nodes (tcReferences class)
-- Level: Intermediate
--
-- Call a function on all entries in the currently selected section window that
-- pass the currently applied filter, and recurse all nodes in document tree
-- 
-- To run this:
-- 1. Open TLex/tlTerm/tlDatabase, and open your document
-- 2. Go to 'Tools' menu, select "Execute Lua Script", and select this file
--
-- [dj2021-08]

-- Make sure we have a document open
local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end

-- Look for the TLex smartref element in the DTD
local ELEMref=DOC:GetDTD():FindElementByName('References');
if ELEMref==nil then
	return "TLex smartref element not found - check the DTD - do you have the correct document open?";
end

-- Find entry/entries with matching headword.
-- If zero matches, it's a reference error the editor must know about - unknown referenced
-- If 1 matches, it's probably perfectly correct
-- If 2 or more matches, it's an ambiguous match - editor should check - as we don't know which entry is intended
function GetMatchingEntries(s, matches)
	local l;
	for l=0,SECTION:GetNumEntries()-1,1 do
		if s==tQuery(SECTION:GetEntry(l),'/hg/hw') then
			matches:push_back(SECTION:GetEntry(l));
		end
	end
end

function YourFunc(ENTRY,NODE)
	-- Log to application log just to help show it's working - comment out log if it's slowing things down for your script
	if ENTRY==NODE then
		tLuaLog('Entry:'..ENTRY:GetLemmaSign());
	end

	-- If node is our plain XML element we want to add smart-references for
	if NODE:GetElementName()=='xr' then
		local s=NODE:GenerateXML(true,false);
		tLuaLog('xr_xml:'..s);
		local x=tQuery(NODE,'/x');
		local matches=nil;
		-- Check for common forms
		matches = nil;
		if tRegMatch(s,'^<xr><x>([^<>]*)</x></xr>$',true) then
			matches = vector_tcEntry__:new_local();
			GetMatchingEntries(x, matches);
		end
		if matches~=nil then
			if matches:size()==0 then
				tLuaLog('ERROR: No matches: '..s);
			else
				-- Create a smart-references node and typecast to a tcReferences so we can work with it
				local NEWREF = tolua.cast(DOC:AllocateElement(ELEMref), 'tcReferences');
				if matches:size()>=2 then
					tLuaLog('WARNING: Ambiguous matches '..tostring(matches:size())..': '..s);
				else
					tLuaLog('GOOD match: '..s);
				end

				local n;
				for n=0,matches:size()-1,1 do
					tLuaLog('addmatch '..tostring(n));
					NEWREF:AddRefEntry(matches[n], 0);
					tLuaLog('addmatch '..tostring(n)..' done');
				end

				-- This is not the right place to add it yet but want to see this works
				NODE:AddChildLast(NEWREF);
				ENTRY:SetChanged(true, false);
			end
			matches:clear();
		end
	end

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
SECTION = SECTIONWND:GetLanguage();--Global
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
