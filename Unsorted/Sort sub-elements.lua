-- Sort example phrases by word in <sw> tags

-- Make sure we have a document open
local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end

local DTD = DOC:GetDTD();
local EXAMPLE  = DTD:FindElementByName("Example");
local EXPHRASE = DTD:FindElementByName("ExPhrase");
if EXPHRASE==nil or EXAMPLE==nil then
	return "Wrong DTD";
end

function GetSortStrValue(NODE)
	local N = NODE:GetNumChildrenOfElementType(EXPHRASE:GetID());
	if N>=1 then
		local ELEM = NODE:GetNthChildOfElementType(EXPHRASE:GetID(), 0);
		local STR = ELEM:GetAttributePByIndex(0); -- Fixme, dangerous, should check first if attribute exists etc.
		-- Return the portion inside "<sw>" tags
		local POS = string.find(STR, "<sw>");
		if POS==nil then
			return STR;
		end
		return string.sub(STR, POS);
	end
	return "";
end

function Recurse(NODE)
	local k, l;
	local TYPE = NODE:GetElement():GetName();
	if TYPE=="Examples" then
		-- Iterate children
		local NUM = NODE:GetNumChildrenOfElementType(EXAMPLE:GetID());
		if NUM>1 then
			for k=0,NUM-2,1 do
				for l=k+1,NUM-1,1 do
					local CHILD1 = NODE:GetNthChildOfElementType(EXAMPLE:GetID(), k);
					local CHILD2 = NODE:GetNthChildOfElementType(EXAMPLE:GetID(), l);
					local STR1 = GetSortStrValue(CHILD1);
					local STR2 = GetSortStrValue(CHILD2);
					if STR1>STR2 then
						-- Swop the two elements around
						NODE:SwopChildren(CHILD1:FindOurIndex(), CHILD2:FindOurIndex());
					end
				end
			end
		end
	else
		-- Recurse children
		for k=0,NODE:GetNumChildren()-1,1 do
			local CHILD = NODE:GetChild(k);
			Recurse(CHILD);
		end
	end
end

function Sort(ENTRY)
	tLuaLog(ENTRY:GetLemmaSign());
	Recurse(ENTRY);
end

-- Iterate through all 'sections'/languages, and for each section, through all entries.
local i, j;
local LANG = DOC:GetDictionary():GetLanguage(0);
for i=0,DOC:GetDictionary():GetNumLanguages()-1,1 do
	local SECTION = DOC:GetDictionary():GetLanguage(i);
	for j=0,SECTION:GetNumEntries()-1,1 do
		local ENTRY = SECTION:GetEntry(j);
		Sort(ENTRY);
	end
end

return "";
