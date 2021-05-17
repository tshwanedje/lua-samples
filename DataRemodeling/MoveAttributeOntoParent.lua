--This Lua script moves all occurrences of an attribute from an element to an attribute with the same name on its parent (if the element is under that parent)
local ELEMENTNAME = "IPA.British.group";
local PARENTNAME = "supersense";
local ATTRNAME = "part.of.speech";

function MoveAttribute(NODE)
      local NUM = NODE:GetNumChildren();
      for i=0,NUM-1,1 do
          local CHILD = NODE:GetChild(i)
          MoveAttribute(CHILD);
          if CHILD:GetElement():GetID() == ELEM:GetID() then
              if CHILD:GetParent():GetElement():GetID() == ELEMPARENT:GetID() then
                  local POS = CHILD:GetAttributeDisplayAsString(ATTR);
                  CHILD:GetParent():SetAttributeDisplayByString(ATTRP,POS);
                  CHILD:ResetAttributeValue(ATTR:GetAttributeIndex());
              end
          end
      end
end


--check that there is a global document object (IE/ Make sure we actually have a dictionary open)
if g_pDoc == nil then
	--No document is loaded - exit
	return "Failed - No document loaded";
end

ELEMPARENT = g_pDoc:GetDictionary():GetDTD():FindElementByName(PARENTNAME);
ELEM = g_pDoc:GetDictionary():GetDTD():FindElementByName(ELEMENTNAME);
ATTRP = ELEMPARENT :FindAttributeByName(ATTRNAME);
ATTR = ELEM :FindAttributeByName(ATTRNAME);

LANG = g_pDoc:GetDictionary():GetLanguage(0);
local NUM = LANG:GetNumChildren();
if NUM > 0 then
	for i=0,NUM-1,1 do
	    local LEM = LANG:GetChild(i);
	    MoveAttribute(LEM);
	end
end



--script terminated without error
return "Success";