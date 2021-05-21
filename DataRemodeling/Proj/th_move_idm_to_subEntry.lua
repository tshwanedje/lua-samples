-- ENTRY SCRIPT - THIS CAN BE RUN STRAIGHT FROM TOOLS MENU
-- th->th_idm
-- THIS SHOULD (probably?) BE RUN BEFORE THE SENSE AND DPART CASES SO IT CAN PROCESS AWAY THE th_idm's FIRST on cases like 'sense,th_idm' and 'dpart,th_idm'

-------------------------------------------------------------------------------------
-- (1) INIT/SETUP
-------------------------------------------------------------------------------------

-- Make sure we don't change timestamps and lastmodifiedby etc. [this is a new thing, may change, API-unstable]
g_bAdminNoUpdateTimestamps=true;--API-unstable-- NO update timestamps etc.

local ENTRY=gCurrentEntry;
local DOC=tApp():GetCurrentDoc();
local SECTION = DOC:GetDictionary():GetLanguage(0);

-- EXCLUDE CASES WHERE IT'S JUST SIMPLE THESAURUS-ONLY ENTRIES - THESE WILL HAVE TWO CHILDREN, A th AND A th_hg
if ENTRY:GetNumChildren()==2 and ENTRY:GetChild(0):GetElementName()=='th' and ENTRY:GetChild(1):GetElementName()=='th_hg' then return ''; end
if ENTRY:GetNumChildren()==2 and ENTRY:GetChild(0):GetElementName()=='th_hg' and ENTRY:GetChild(1):GetElementName()=='th' then return ''; end

-- Thesaurus elements (source)
local ELEM_th=DOC:GetDTD():FindElementByName('th');
local ELEMdpart=DOC:GetDTD():FindElementByName('dpart');
local ELEMsense=DOC:GetDTD():FindElementByName('sense');
local ELEMth_idm=DOC:GetDTD():FindElementByName('th_idm');
-- Dictionary elements (target)
local ELEMsubEntry=DOC:GetDTD():FindElementByName('subEntry');
local ELEMse1=DOC:GetDTD():FindElementByName('se1');
-- General processing elements
--local ATTRnotes=ENTRY:GetElement():FindAttributeByName('InternalEditorNotes');
local ATTRi=ENTRY:GetElement():FindAttributeByName('_ImportThesaurusNotes');

-------------------------------------------------------------------------------------
-- (2) MAIN LOGIC
-------------------------------------------------------------------------------------

-- If no "th" on entry, exit and do nothing
if ENTRY:GetNumDescendantsOfElementType(ELEM_th:GetID())<=0 then return ""; end
local TH=ENTRY:GetNthDescendantOfElementType(ELEM_th:GetID(), 0);
-- We're looking for cases that have th_idms
if TH:GetNumChildrenOfElementType(ELEMth_idm:GetID())<=0 then return ""; end

local aNODES=vector_tcNode__:new_local();	TH:FindDescendantsOfElementType(ELEMth_idm:GetID(),aNODES);	-- source nodes
local aNODES2=vector_tcNode__:new_local();	ENTRY:FindDescendantsOfElementType(ELEMsubEntry:GetID(),aNODES2);	-- target nodes

local bMARKED=false;
if (aNODES:size()>0) then
	-- CONSISTENCY CHECK: CHECK IF FEWER TARGET subentry's than th_idm's
	if aNODES:size()>aNODES2:size() then
		if ATTRi~=nil then
			ENTRY:SetAttributeDisplayByString(ATTRi, '_import:th_idm:warn:Fewer subEntries than th_idms'); -- Note if string not exist in list, it creates and adds list item here automatically
			bMARKED = true;
		end
	end

	--local bTHISCHANGED=false;
	local i, j;
	for i=0,aNODES:size()-1,1 do
		local NODE=aNODES[i];
		local sSrcLemma = tQuery(NODE,'/lt/'); -- SRC lemma-thesaurus (headword) for derivative or phrase
		local sSrcPOS = tQuery(NODE,'/lt/th_gm/th_ps/'); -- SRC part of speech

		-- Now look for a matching subEntry
		for j=0,aNODES2:size()-1,1 do
			local DEST=aNODES2[j];
			local sDestLemma = tQuery(DEST,'/l/'); -- DEST lemma-thesaurus (headword) for derivative or phrase
			local sDestPOS = tQuery(DEST,'/l/posg/pos/'); -- DEST part of speech
			if sSrcLemma==sDestLemma and sSrcPOS==sDestPOS then
				-- YAY! Found a match. Move the it to the target node
				TH:RemoveChild(NODE);
				DEST:AddChildLast(NODE);
				ENTRY:SetChanged(true,false);-- NO update timestamps etc.
				break;
			end
		end
	end
end
-------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------
-- (3) FINAL STUFF
-------------------------------------------------------------------------------------
-- If there are ZERO children left on the TH then we are a success, and can delete the "th"
if TH:GetNumChildren()==0 then
	TH:RemoveNode();
	DOC:DeleteTreeFromDoc(TH);
else
	-- If there are still th_idm's on the TH then we didn't handle all th_idms (but note there can be other stuff on the 'th' still at this point - eg dparts and senses to be processed so that is normal)
	if TH:GetNumDescendantsOfElementType(ELEMth_idm:GetID())>0 then
		if ATTRi~=nil and bMARKED==false then
			ENTRY:SetAttributeDisplayByString(ATTRi, '_import_incompletely_handled_/th_idm cases'); -- Note if string not exist in list, it creates and adds list item here automatically
		end
	else
		-- This labeling is not necessary but just doing it so we can help filter on and study the cases where this was done
		if ATTRi~=nil then
			ENTRY:SetAttributeDisplayByString(ATTRi, 'SUCCESS: All th_idm moved to subentry'); -- Note if string not exist in list, it creates and adds list item here automatically
		end
	end
end
-------------------------------------------------------------------------------------
