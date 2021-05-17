--This script will combine multiple occurences of an element (Each with one attribute with one or more comma seperated items in)
--Into a single element with a single attribute containing all items
--This was intended for parts of speech after importing a document where the part of speech was something like <pos>noun</pos><pos>verb</pos>
--However it can easily be adapted to other similar scenarios (Currently is assumes that no other attributes exist and that the elements have no children

local ELEMNAME = "part.of.speech";
local ATTRNAME = "part.of.speech";


function CombinePOS(NODE)
	local NUM = NODE:GetNumChildren();
      if NUM > 0 then
	    local i = 0;
          while i < NUM do
              local CHILD = NODE:GetChild(i);
               if CHILD:GetElement():GetName() == ELEMNAME then
                   while i+1 < NUM do
                       local SIB = NODE:GetChild(i+1);
                       if SIB:GetElement():GetName() == "part.of.speech" then
                           local ATTR = SIB:GetElement():FindAttributeByName(ATTRNAME);
                           local POS = SIB:GetAttributeDisplayAsString(ATTR,",");
                           local CURRPOS = CHILD:GetAttributeDisplayAsString(ATTR,",");
                           CHILD:SetAttributeDisplayByString(ATTR,CURRPOS..","..POS,true,",");
                           SIB:RemoveNode();
                           g_pDoc:DeleteTreeFromDoc(SIB);
                       else
                           break;
                       end
                       NUM = NODE:GetNumChildren();
                   end
               else
                   CombinePOS(CHILD); 
               end
          i = i+1;
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
		local LEM = LANG:GetEntry(i);
            tLuaLog(LEM:GetLemmaSign());
		CombinePOS(LEM);
	end
end



--script terminated without error
return "Success";