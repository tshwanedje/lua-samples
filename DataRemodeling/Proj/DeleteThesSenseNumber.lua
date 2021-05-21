-- 'Global' Lua script - can run from Tools menu

-------------------------------------------------------------------------------------
-- (1) INIT/SETUP
-------------------------------------------------------------------------------------

-- Make sure we don't change timestamps and lastmodifiedby etc. [this is a new thing, may change, API-unstable]
g_bAdminNoUpdateTimestamps=true;--API-unstable-- NO update timestamps etc.

local ENTRY=gCurrentEntry;
local DOC=tApp():GetCurrentDoc();
local SECTION = DOC:GetDictionary():GetLanguage(0);

local ELEM=DOC:GetDTD():FindElementByName('th_sensenumber');

-------------------------------------------------------------------------------------
-- (2) MAIN LOGIC
-------------------------------------------------------------------------------------

-- Find all nodes
local aNODES=vector_tcNode__:new_local();
SECTION:FindDescendantsOfElementType(ELEM:GetID(), aNODES);

-- If th_sensenumber's number is the same as the 'se2' it inherits from, delete it?
if (aNODES:size()>0) then
	for i=0,aNODES:size()-1,1 do
		local NODE=aNODES[i];

		if NODE:GetParent():GetParent():GetElementName()=='se2' then
			local s1 = tQuery(NODE, '/');
			local s2 = tQuery(NODE:GetParent():GetParent(), '@SenseNumberAuto');
			if s1==s2 then
				tGetNodeEntry(NODE):SetChanged(true,false);-- NO update timestamps etc.
				NODE:GetParent():RemoveChild(NODE);
				DOC:DeleteTreeFromDoc(NODE);
			end
		end
	end
end
