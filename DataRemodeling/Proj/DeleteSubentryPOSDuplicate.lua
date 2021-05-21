-- 'Global' Lua script - can run from Tools menu
-- Delete redundant part of speech that has now been moved under subEntry by other Lua script if same as subEntry POS

-------------------------------------------------------------------------------------
-- (1) INIT/SETUP
-------------------------------------------------------------------------------------

-- Make sure we don't change timestamps and lastmodifiedby etc. [this is a new thing, may change, API-unstable]
g_bAdminNoUpdateTimestamps=true;--API-unstable-- NO update timestamps etc.

local ENTRY=gCurrentEntry;
local DOC=tApp():GetCurrentDoc();
local SECTION = DOC:GetDictionary():GetLanguage(0);

local ELEM=DOC:GetDTD():FindElementByName('th_gm');

-------------------------------------------------------------------------------------
-- (2) MAIN LOGIC
-------------------------------------------------------------------------------------

-- Find all nodes
local aNODES=vector_tcNode__:new_local();
SECTION:FindDescendantsOfElementType(ELEM:GetID(), aNODES);

if (aNODES:size()>0) then
	for i=0,aNODES:size()-1,1 do
		local NODE=aNODES[i];

		if NODE:GetParent():GetParent():GetElementName()=='subEntry' then
			local s1 = tQuery(NODE, '/th_ps/');
			local s2 = tQuery(NODE:GetParent():GetParent(), '/posg/pos/@value');
			if s1==s2 then
				tGetNodeEntry(NODE):SetChanged(true,false);-- NO update timestamps etc.
				NODE:GetParent():RemoveChild(NODE);
				DOC:DeleteTreeFromDoc(NODE);
			end
		end
	end
end
