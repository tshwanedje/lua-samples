-- ENTRY SCRIPT - THIS CAN BE RUN STRAIGHT FROM TOOLS MENU
-- th->sense
-- NOTE: It's always ONE sense under th for these cases (confirmed with stats)
-- root=elem:th>sense
--

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

-- Thesaurus elements
local ELEM_th=DOC:GetDTD():FindElementByName('th');
local ELEMsense=DOC:GetDTD():FindElementByName('sense');
local ELEMsenitem=DOC:GetDTD():FindElementByName('senitem');
local ELEMth_sensenumber=DOC:GetDTD():FindElementByName('th_sensenumber');
-- Dictionary elements
--local ELEM_sg=DOC:GetDTD():FindElementByName('sg');
local ELEMse1=DOC:GetDTD():FindElementByName('se1');
local ELEMse2=DOC:GetDTD():FindElementByName('se2');

local ATTRnotes=ENTRY:GetElement():FindAttributeByName('InternalEditorNotes');
local ATTRi=ENTRY:GetElement():FindAttributeByName('_ImportThesaurusNotes');

-------------------------------------------------------------------------------------
-- (2) MAIN LOGIC
-------------------------------------------------------------------------------------

if ENTRY:GetNumDescendantsOfElementType(ELEM_th:GetID())<=0 then return ""; end
local TH=ENTRY:GetNthDescendantOfElementType(ELEM_th:GetID(), 0);

if TH:GetNumChildrenOfElementType(ELEMsense:GetID())==0 then return ""; end
local SENSE=TH:GetNthChildOfElementType(ELEMsense:GetID(), 0);-- Get first (and should be only) 'sense' child of the 'th'

-- Now find all 'senitems'
local aNODES=vector_tcNode__:new_local();	SENSE:FindDescendantsOfElementType(ELEMsenitem:GetID(),aNODES);	-- source nodes
local aNODES2=vector_tcNode__:new_local();	ENTRY:FindDescendantsOfElementType(ELEMse2:GetID(),aNODES2);	-- target nodes

if (aNODES:size()>0) then
	-- CONSISTENCY CHECK: MAKE SURE NUMBER OF SENITEMS MATCHES NUMBER OF TARGET SENSES ... IF NOT, WHAT DO WE DO .. WARN THE EDITORS? LET'S CHECK WHAT THE RESULTS LOOK LIKEE
	-- NOTE: THERE CAN BE *LESS* SENITEM'S THAN TARGET SENSES - THAT'S PRECISELY OK, AND DESIRED! EG SEE "ABUSE[2]" .. BUT NOT MORE.
	if aNODES:size()>aNODES2:size() then
		-- WORRIED ABOUT OVERRWRITING NOTES IF IT ALREADY EXISTS! CAREFUL!
		----- --ENTRY:SetAttributeS(ATTRnotes,'djNoMatchFound');-- 
		if ATTRi~=nil then
			ENTRY:SetAttributeDisplayByString(ATTRi, '_import:_thSenseNumberCase:Sense number mismatch'); -- Note if string not exist in list, it creates and adds list item here automatically
		end
	end

	local bTHISCHANGED=false;
	for i=0,aNODES:size()-1,1 do
		local NODE=aNODES[i];

		-- IF IT HAS COMMAS IN IT, DON'T MOVE IT ---- THAT'S FOR THE EDITORS TO SORT OUT AND DECIDE WHAT TO DO HERE
		local sSenseNum = tQuery(NODE,'/th_sensenumber/');
		if sSenseNum:find(',', 1, true) or sSenseNum:find(' ', 1, true) then
			-- Commas in the sensenumber - we leave these for now, not sure yet what to do with them
		else
			-- No comma in sensenumber, so let's look for matching sensenumber in 'se2's
			for j=0,aNODES2:size()-1,1 do
				local SE2=aNODES2[j];
				if tQuery(SE2,'@SenseNumberAuto')==sSenseNum then
					-- YAY! Found a match. Move the senitem to the SE2
					SENSE:RemoveChild(NODE);
					SE2:AddChildLast(NODE);
					ENTRY:SetChanged(true,false);-- NO update timestamps etc.
					break;
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------
-- (3) FINAL STUFF
-------------------------------------------------------------------------------------
-- If there are ZERO children left on the SENSE then we can delete the sense (as a 'sense' only has 1 or more senitems)
if SENSE:GetNumChildren()==0 then
	SENSE:RemoveNode();
	DOC:DeleteTreeFromDoc(SENSE);
end

-- If there are ZERO children left on the TH then we are a success, and can delete the "th"
if TH:GetNumChildren()==0 then
	TH:RemoveNode();
	DOC:DeleteTreeFromDoc(TH);
else
	-- If there are still sense's on the TH then we didn't handle all sense's (but note there can be other stuff on the 'th' still at this point - eg th_idm's)
	if TH:GetNumDescendantsOfElementType(ELEMsense:GetID())>0 then
		if ATTRi~=nil then
			ENTRY:SetAttributeDisplayByString(ATTRi, '_import_incompletely_handled_/sense'); -- Note if string not exist in list, it creates and adds list item here automatically
		end
	end
end
-------------------------------------------------------------------------------------
