--check that there is a global document object (IE/ Make sure we actually have a dictionary open)
if g_pDoc == nil then
	--No document is loaded - exit
	return "Failed - No document loaded";
end

local VEARRAY = {};
local VEARRAY2 = {};


local LEMMAELEM = g_pDoc:GetDictionary():GetDTD():FindElementByName("Lemma");
local ATTRVERBALEXTENSION = LEMMAELEM:FindAttributeByName("VerbalExtension");

local LANG = g_pDoc:GetDictionary():GetLanguage(1);
for i=0,LANG:GetNumChildren()-1,1 do
    local LEMMA = LANG:GetChild(i);
    local VE = LEMMA:GetAttributeAsString(ATTRVERBALEXTENSION," + ");
    if VE ~= "" then
	  if VEARRAY[VE] == nil then
		VEARRAY[VE] = 1;
        else
		VEARRAY[VE] = VEARRAY[VE] + 1;
        end
    end
end

 for j,k in pairs(VEARRAY) do
   table.insert(VEARRAY2,{freq = k,veseq = j});
 end

 table.sort(VEARRAY2,function (a, b) return b["freq"] < a["freq"] end);

 local HTMLOUTPUT = "<html><body><table border=\"1\">";
 for j,k in pairs(VEARRAY2) do
       HTMLOUTPUT = HTMLOUTPUT.."<tr><td>"..k["freq"].."</td><td>"..k["veseq"].."</td></tr>";
 end
 HTMLOUTPUT=HTMLOUTPUT.."</table></body>";

 tHTMLPopup(tFrameWindow(),"VerbalExtensions",HTMLOUTPUT,600,600);


--script terminated without error
return "done";
