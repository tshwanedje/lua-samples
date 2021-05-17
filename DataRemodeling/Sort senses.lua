-- TshwaneLua script for TLex or tlTerm.

local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end
local NUMDELETED = 0;

local ELEM = DOC:GetDTD():FindElementByName("TE_NS");
if ELEM == nil then
	return "No TE_NS found";
end
local ATTR = ELEM:FindAttributeByName("TEFrequency");
if ATTR == nil then
	return "No TE_NS::TEFrequency attribute found";
end

local function GetFreq(SENSE)
	if SENSE:GetNumChildrenOfElementType(ELEM:GetID())==0 then
		return 0;
	end
	local TE = SENSE:GetNthChildOfElementType(ELEM:GetID(), 0);
	return TE:GetAttributeI(ATTR);
end

local function SortSenses(DOC, ENTRY)

	local NUMSENSES = ENTRY:GetNumChildrenOfElementType(NODE_SENSE);

	-- BUBBLE SORT - URGH!
	if NUMSENSES>1 then
		local i;
		local j;
		for i=0,NUMSENSES-2,1 do
			for j=i+1,NUMSENSES-1,1 do
				local SENSEI = ENTRY:GetNthChildOfElementType(NODE_SENSE, i);
				local SENSEJ = ENTRY:GetNthChildOfElementType(NODE_SENSE, j);
				local nFreq1 = GetFreq(SENSEI);
				local nFreq2 = GetFreq(SENSEJ);
				if nFreq1 < nFreq2 then
					local nIndex1 = SENSEI:FindOurIndex();
					local nIndex2 = SENSEJ:FindOurIndex();
					ENTRY:SwopChildren(nIndex1, nIndex2);
					ENTRY:SetChanged(true, false);
				end
			end
		end
	end
end

local LANG = DOC:GetDictionary():GetLanguage(0);
local i;
for i=0,LANG:GetNumChildren()-1,1 do
	local ENTRY = LANG:GetEntry(i);
	SortSenses(DOC, ENTRY);
end
return "Success";
