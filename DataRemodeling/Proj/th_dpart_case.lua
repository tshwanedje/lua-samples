-- ENTRY SCRIPT - THIS CAN BE RUN STRAIGHT FROM TOOLS MENU
-- th->dpart
-- NOTE: It's always ONE dpart under th if there is just dpart(s), never two or more dparts (confirmed that with child stats)
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
local ELEMdpart=DOC:GetDTD():FindElementByName('dpart');
-- Dictionary elements
local ELEMse1=DOC:GetDTD():FindElementByName('se1');

local ATTRnotes=ENTRY:GetElement():FindAttributeByName('InternalEditorNotes');
local ATTRi=ENTRY:GetElement():FindAttributeByName('_ImportThesaurusNotes');

-------------------------------------------------------------------------------------
-- (2) MAIN LOGIC
-------------------------------------------------------------------------------------

-- If no "th" on entry, exit and do nothing
if ENTRY:GetNumDescendantsOfElementType(ELEM_th:GetID())<=0 then return ""; end
local TH=ENTRY:GetNthDescendantOfElementType(ELEM_th:GetID(), 0);

if TH:GetNumChildrenOfElementType(ELEMdpart:GetID())==0 then return ""; end
local DPART=TH:GetNthChildOfElementType(ELEMdpart:GetID(), 0);-- Get first (and should be only) 'dpart' child of the 'th'

-- Now find all 'senitems'
local aNODES2=vector_tcNode__:new_local();	ENTRY:FindDescendantsOfElementType(ELEMse1:GetID(),aNODES2);	-- target nodes

local bMARKED = false;
if aNODES2:size()==0 then
	-- WORRIED ABOUT OVERRWRITING NOTES IF IT ALREADY EXISTS! CAREFUL!
	----- --ENTRY:SetAttributeS(ATTRnotes,'djNoMatchFound');-- 
	if ATTRi~=nil then
		ENTRY:SetAttributeDisplayByString(ATTRi, '_import:dpart: No se1 target'); -- Note if string not exist in list, it creates and adds list item here automatically
		bMARKED = true;
	end
else
	-- YAY! Found a match. Move the dpart to the SE1
	local SE1 = aNODES2[0];
	TH:RemoveChild(DPART);
	SE1:AddChildLast(DPART);
	ENTRY:SetChanged(true,false);-- NO update timestamps etc.
end

-------------------------------------------------------------------------------------
-- (3) FINAL STUFF
-------------------------------------------------------------------------------------
-- If there are ZERO children left on the TH then we are a success, and can delete the "th"
if TH:GetNumChildren()==0 then
	TH:RemoveNode();
	DOC:DeleteTreeFromDoc(TH);
else
	-- If there are still dpart's on the TH then we didn't handle all dpart's (but note there can be other stuff on the 'th' still at this point - eg th_idm's)
	if TH:GetNumDescendantsOfElementType(ELEMdpart:GetID())>0 then
		if ATTRi~=nil and bMARKED==false then
			ENTRY:SetAttributeDisplayByString(ATTRi, '_import_incompletely_handled_/dpart'); -- Note if string not exist in list, it creates and adds list item here automatically
		end
	end
end
-------------------------------------------------------------------------------------
