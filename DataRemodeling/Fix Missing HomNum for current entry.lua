-- David 2017-12: Script to fix cases like "bota" in ca-ge where the TLex automatic homonym numbers haven't updated correctly (not sure why but possibly to do with the orthreview-related changes)
-- Use 'Tools / Execute Lua Script' in TLex to run this script.
-- This script runs on the currently selected entry (and potentially its homonyms) only.
-- It checks if the HomNum is missing (i.e. '0') and if there "should be" a homonym,
-- i.e. if the previous or next entry has the same LemmaSign - then it performs the
-- correction. It does not do a 'save', so you can manually review the changes before saving.

-- Get selected section/language window, if any
local FRAME = tFrameWindow();
local SECTION = FRAME:GetSelectedSectionWindow();

--tMessageBox("one");
if (SECTION~=nil) then
	local LANG = SECTION:GetLanguage();
	--tMessageBox("two");

	-- Get current selected entry, if any
	local Entry = SECTION:GetSelectedEntry();
	if (Entry~=nil) then

		--tMessageBox("three");
		tRequestLoad(Entry);--Just in case, don't think that should be necessary

		local IsMissing;
		IsMissing=false;

		-- Find entries that look like they 'should be' homonyms, but aren't
		--local LANG = tApp():GetCurrentDoc():GetDictionary():GetLanguage(0);
		local LS=Entry:GetLemmaSign();
		local i=Entry:FindOurIndex();
		if (i>0) then
		 if (LANG:GetEntry(i-1):GetLemmaSign()==LS and Entry:GetHomNum()==0) then
		  IsMissing=true;
		 end
		end

		if (i<LANG:GetNumEntries()-1) then
		 if (LANG:GetEntry(i+1):GetLemmaSign()==LS and Entry:GetHomNum()==0) then
		  IsMissing=true;
		 end
		end
		--tMessageBox("LS:"..LS);
		if IsMissing then
			tMessageBox("Fixing missing homonym numbers for: "..LS);
			-- Fix
			local HOMONYMS = vector_tcEntry__:new_local();
			LANG:FindAllExactHomonyms(Entry, HOMONYMS);
	
			--LANG:OnLemmaSignChanged(Entry, HOMONYMS, false);
			--LANG:FixHomonymNumbers(Entry, HOMONYMS);
			for h=0, HOMONYMS:size()-1, 1 do
				tRequestModify(HOMONYMS[h],true);--Check out for ODBC
			end
			for h=0, HOMONYMS:size()-1, 1 do
				HOMONYMS[h]:SetHomNum(h+1);
			end
			for h=0, HOMONYMS:size()-1, 1 do
				--LANG:OnLemmaSignChanged(HOMONYMS[h], NULL, false);
				HOMONYMS[h]:SetChanged(true,false);--NB, second parameter must be false, we don't want to update timestamp, this isn't a "real" edit
			end
			--for h=0, HOMONYMS:size()-1, 1 do
			--	local HOMONYMS2 = vector_tcEntry__:new_local();
			--	LANG:FindAllExactHomonyms(HOMONYMS[h], HOMONYMS2);
			--	if HOMONYMS2:size() < 2 then
			--		HOMONYMS[h]:SetHomNum(0);
			--	end
			--	LANG:OnLemmaSignChanged(HOMONYMS[h], HOMONYMS2, false);
			--end
			--LANG:OnLemmaSignChanged(Entry, HOMONYMS, false);
		end

	end

end
