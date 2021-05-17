--The ElementParent::Element::Attribute grouping on which tilde replacements should be done can be modified below
--One pair per line
--"" can be used for ElementParent when th e parent of the element does not matter
--Any invalid pairs will cause the script to halt with an error message

local ElementAttributePairsOnWhichToDoReplacement = {
                                {"sense",{"example","example"}},
                                {"irregular.forms.group",{"irregular.form","irregular.form"}},
                                {"internal.inflection.group",{"irregular.form","irregular.form"}},
                                {"idiom.group",{"idiom","idiom"}},
                                {"",{"idiom","Or"}},
                                {"",{"idiom","Or2"}},
                                {"",{"derivative","zero.derivative"}},
                                {"",{"derivative","derivative"}},
                                {"",{"usage.note","content"}},
                                {"",{"definition","definition.continued"}},
                                {"",{"example","info"}},
                                {"",{"example","examplecontinued"}},
                                {"",{"alternative.form","alternative.form"}},
                                {"",{"definition","definition"}},
                                {"",{"phrasal.verb","Phrasal.verb"}}
            };


function ReplaceHeadwordOccurencesWithTildes(NODE,HEADWORD,ELEMPARENT,ELEM,ATTR)
    local i = 0;
    local NUM = NODE:GetNumChildren();
    for i=0,NUM-1,1  do
        local CHILD = NODE:GetChild(i)
        ReplaceHeadwordOccurencesWithTildes(CHILD,HEADWORD,ELEMPARENT,ELEM,ATTR);
        if CHILD:GetElement():GetID() == ELEM:GetID() then
            if ELEMPARENT == nil or CHILD:GetParent():GetElement():GetID() ~= ELEMPARENT:GetID() then
                local VAL = CHILD:GetAttributeDisplayAsString(ATTR);  
                local VALORIG = VAL;
                VAL = string.gsub(VAL,"(%s)"..HEADWORD.."(%s)","%1~%2")
                if VAL ~= VALORIG then
                    CHILD:SetAttributeDisplayByString(ATTR,VAL);
                end 
            end
        end
    end
end

--check that there is a global document object (IE/ Make sure we actually have a dictionary open)
if g_pDoc == nil then
	--No document is loaded - exit
	return "Failed - No document loaded";
end

--ELEMLABEL = g_pDoc:GetDictionary():GetDTD():FindElementByName("comment");

LANG = g_pDoc:GetDictionary():GetLanguage(0);
local NUM = LANG:GetNumChildren();
if NUM > 0 then
	for i=0,NUM-1,1 do
		local LEM = LANG:GetEntry(i);
            for ignoreme,x in pairs(ElementAttributePairsOnWhichToDoReplacement) do
                local PARENTNAME = x[1];
                local NAME = x[2][1];
                local ATTRNAME = x[2][2];
                local ELEMPARENT = nil;
                if PARENTNAME ~= "" then
                   ELEMPARENT = g_pDoc:GetDictionary():GetDTD():FindElementByName(PARENTNAME);
                   if ELEMPARENT == nil then
                      return "Element name "..PARENTNAME.." does not exist in DTD...";
                   end
                end
                local ELEM = g_pDoc:GetDictionary():GetDTD():FindElementByName(NAME);
                if ELEM == nil then
                    return "Element name "..NAME.." does not exist in DTD...";
                end
                local ATTR = ELEM:FindAttributeByName(ATTRNAME);
                if ATTR == nil then
                   return "Element name "..NAME.." does not have an attribute named "..ATTRNAME;
                end
                ReplaceHeadwordOccurencesWithTildes(LEM,LEM:GetLemmaSign(),ELEMPARENT,ELEM,ATTR);
            end
	end
end



--script terminated without error
return "Success";