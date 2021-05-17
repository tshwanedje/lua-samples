local LISTELEMENT = "usg_topic";
local LISTATTRIBUTE = "Topic";
local LISTIDTOREMOVE = "289";
local LISTIDTOUSE = "459";

function fixlist(NODE)
	local NUM = NODE:GetNumChildren();
	if NUM > 0 then
		for i=0,NUM-1,1 do
			local CHILD = NODE:GetChild(i);
			fixlist(CHILD);	
		end
	end

	local ELEM = NODE:GetElement();
	if ELEM:GetName() ~= LISTELEMENT then
		return;
	end
	local ATTRLIST = ELEM:FindAttributeByName(LISTATTRIBUTE);
	if ATTRLIST == nil then
		return;
	end	
	local VAL =	NODE:GetAttributeRawAsString(ATTRLIST ,PCDATA);
	if VAL == LISTIDTOREMOVE then 
		VAL = LISTIDTOUSE;
	end

	NODE:SetAttributeRawByString(ATTRLIST,VAL);
end


--check that there is a global document object (IE/ Make sure we actually have a dictionary open)
if tApp():GetCurrentDoc() == nil then
	--No document is loaded - exit
	return "Failed - No document loaded";
end


LANG = tApp():GetCurrentDoc():GetDictionary():GetLanguage(0);
fixlist(LANG);

--script terminated without error
return "Success";