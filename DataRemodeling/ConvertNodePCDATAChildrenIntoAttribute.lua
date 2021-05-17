function convertpcdataintoattribute(NODE,ELEMNAME,ATTRNAME)
	local NUM = NODE:GetNumChildren();
	local ELEM = NODE:GetElement();
	--Pcdata won't have an element
	if ELEM == nil then
	    return;
	end
	
	if ELEM:GetName() == ELEMNAME then
		local VAL = NODE:GenerateXMLChildren(true,true);
		local ATTR = ELEM:FindAttributeByName(ATTRNAME);
		NODE:SetAttributeDisplayByString(ATTR,VAL);
		while NODE:GetNumChildren() > 0 do
			g_pDoc:DeleteTreeFromDoc(NODE:GetChild(0));
		end
	else
		if NUM > 0 then
			for i=0,NUM-1,1 do
				local CHILD = NODE:GetChild(i);
				convertpcdataintoattribute(CHILD,ELEMNAME,ATTRNAME);
			end
		end
	end
end


--check that there is a global document object (IE/ Make sure we actually have a dictionary open)
if g_pDoc == nil then
	--No document is loaded - exit
	return "Failed - No document loaded";
end

LANG = g_pDoc:GetDictionary():GetLanguage(0);
local NUM = LANG:GetNumChildren();
if NUM > 0 then
	for i=0,NUM-1,1 do
		local LEM = LANG:GetChild(i);
		convertpcdataintoattribute(LEM,"ORT","ORT");
	end
end

--script terminated without error
return "Success";