-- Constants

local COMPANION_BUTTON_HEIGHT = 46;
local HEAL_PET_SPELL = 125439;
local MAX_ACTIVE_PETS = 3;
local MAX_PET_LEVEL = 25;

-- Code

function SkymPetCodex2Teams_OnSearchTextChanged(self)
    SearchBoxTemplate_OnTextChanged(self);
    SkymPetCodex2Teams.teamFilter = self:GetText();
    SkymPetCodex2Teams_UpdateTeamList();
end

function SkymPetCodex2Teams_UpdateTeamList()
    local scrollFrame = SkymPetCodex2Teams.teamsScroll;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local teamButtons = scrollFrame.buttons;
    local team, index;

    local filteredTeams = {};
    for _, team in pairs(Skym_PetCodex2DB.teams) do
        if (string.match(string.lower(team.name), '.*' .. string.lower(SkymPetCodex2Teams.teamFilter or '') .. '.*')) then
            filteredTeams[1 + #filteredTeams] = team;
        end
    end

    table.sort(filteredTeams, function(a, b)
        return a.name < b.name;
    end);

    for i = 1, #teamButtons do
        team = teamButtons[i];
        index = offset + i;
        if (index <= #filteredTeams) then
            team.name:SetText(filteredTeams[index].name);
            team.name:SetHeight(30);
            team.subName:Hide();
            team.index = index;
            team:Show();
        else
            team:Hide();
        end
    end

    local totalHeight = #filteredTeams * COMPANION_BUTTON_HEIGHT;
    HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
end

