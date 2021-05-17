-- TshwaneLua script for TLex or tlTerm.
-- Delete cross-reference nodes with empty cross-references.

local DOC = tApp():GetCurrentDoc();
if DOC == nil then
	return "No document open";
end
local NUMDELETED = 0;

local function DeleteEmptyReferenceNodes(DOC, NODE)

	-- Recurse through child nodes
	if NODE:GetNumChildren() > 0 then
		local i;
		for i=0,NODE:GetNumChildren()-1,1 do
			tLuaLog("CHILD:"..i);
			local CHILD = NODE:GetChild(i);

			if CHILD:GetNumChildren() == 0 then
				if CHILD:IsKindOfClass(NODE_REFERENCES) then
					-- Typecast 'CHILD' to a tcReferences
					local Reference = tolua.cast(CHILD, "tcReferences");
					if Reference:GetNumRefEntries() == 0 then
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
				DeleteEmptyReferenceNodes(DOC, CHILD);
			end
		end
	end

end

DeleteEmptyReferenceNodes(DOC, DOC:GetDocumentRoot());
tLuaLog(NUMDELETED);
return "Success";
