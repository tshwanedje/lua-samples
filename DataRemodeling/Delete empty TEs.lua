-- TshwaneLua script for TLex or tlTerm.
-- Delete cross-reference nodes with empty cross-references.

local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end
local NUMDELETED = 0;

local function DeleteEmptyTEs(DOC, NODE)

	-- Recurse through child nodes
	if NODE:GetNumChildren() > 0 then
		local i = 0;
		while i<NODE:GetNumChildren() do
		--for i=0,NODE:GetNumChildren()-1,1 do
			tLuaLog("CHILD:"..i);
			local CHILD = NODE:GetChild(i);

			if CHILD:GetNumChildren() == 0 then
				if CHILD:GetElementName()=="TE_Eng" then
					local TE = CHILD:GetAttributeAsStringByIndex(0, "");
					if TE == "" then
						local ENTRY = tGetNodeEntry(NODE);
--						if (!tRequestModify(tGetNodeEntry(GetNode()), eChanged))
--						{
--							HandleChanged(pTree, eChanged);
--							return;
--						}
						
						tLuaLog("DELETING NODE["..tGetNodeEntry(NODE):GetLemmaSign().."]");
						DOC:DeleteTreeFromDoc(CHILD);
						--tElementModified(g_pDoc, pParent, NULL, true);
						ENTRY:SetChanged(true, false);
						--Evt_LemmaChanged.Trigger(0, ENTRY);
						NUMDELETED = NUMDELETED+1;
						i = i - 1;
						tLuaLog(i);
						if i < 0 then
							break;
						end
					end
				end
			else
				-- Recurse
				DeleteEmptyTEs(DOC, CHILD);
			end
			i = i + 1;
		end
	end

end

DeleteEmptyTEs(DOC, DOC:GetDocumentRoot());
tLuaLog(NUMDELETED);
return "Success";
