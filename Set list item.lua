-- Sample entry script for TLex (or tlTerm, tlDatabase etc.) to set a multi-selection list item value on an attribute (F2 style lists, e.g. to tick 'Noun' in a PartOfSpeech multi-selection list)

-- Get document and DTD (document type definition)
local DOC = tApp():GetCurrentDoc();
local DTD = DOC:GetDTD();

local ELEM = DTD:FindElementByName("Entry");
if ELEM == nil then
    return "Error: element not found."
end
local ATTR = ELEM:FindAttributeByName("SUBJECT");
if ATTR == nil then
    return "Error: attribute not found."
end
local list = DTD:FindListByName("SUBJECT");
local value = "History";

-- Find the list item internal ID via the DTD
local idListItemValue = -1;
if list~=nil then
    idListItemValue = list:FindByText(value);
else
    return "Error: List item not found."
end

if gCurrentEntry == nil then
    return "Error: No current entry."
end

-- If we found the list item ID (if not it's an invalid list item specified above)
if idListItemValue>=0 then
    -- If we have entry
    if gCurrentEntry~=nil and ATTR~=nil then
        --gCurrentEntry:SetAttributeListID(ATTR, idListItemValue);
        if not gCurrentEntry:HasAttributeListID(ATTR, idListItemValue) then
            gCurrentEntry:AddAttributeListID(ATTR, idListItemValue);
        end
    end
end

return ""
