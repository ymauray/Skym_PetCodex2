-- Copyright (c) 2014 Yannick Mauray.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

--
-- Created by IntelliJ IDEA.
-- User: Yannick
-- Date: 20.10.2014
-- Time: 13:00
-- To change this template use File | Settings | File Templates.
--

-- Persistant storage

Skym_PetCodex2DB = Skym_PetCodex2DB or {};
Skym_PetCodex2DB.skymPetCodex2Tab = Skym_PetCodex2DB.skymPetCodex2Tab or "1";
Skym_PetCodex2DB.teams = Skym_PetCodex2DB.teams or {};

-- Constants

local COMPANION_BUTTON_HEIGHT = 46;
local HEAL_PET_SPELL = 125439;
local MAX_ACTIVE_PETS = 3;
local MAX_PET_LEVEL = 25;

-- Popups

StaticPopupDialogs["SKYM_PET_CODEX_2_TEAM_ADD"] = {
    text = "Ajouter une équipe",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    maxLetters = 30,
    OnAccept = function(self)
        local text = self.editBox:GetText();
        SkymPetCodex2Teams_CreateTeam(text);
        Skym_PetCodex2DB.teams = Skym_PetCodex2DB.teams or {};
        Skym_PetCodex2DB.teams[1 + #Skym_PetCodex2DB.teams] = {name = text};
        SkymPetCodex2Teams_UpdateTeamList();
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent();
        local text = parent.editBox:GetText();
        SkymPetCodex2Teams_CreateTeam(text);
        parent:Hide();
    end,
    OnShow = function(self)
        self.editBox:SetFocus();
    end,
    OnHide = function(self)
        ChatEdit_FocusActiveWindow();
        self.editBox:SetText("");
    end,
    timeout = 0,
    exclusive = 1,
    hideOnEscape = true
};

StaticPopupDialogs["SKYM_PET_CODEX_2_TEAM_RENAME"] = {
    text = "Renommer l'équipe \"%s\"",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 30,
    OnAccept = function(self)
        local text = self.editBox:GetText();
        Skym_PetCodex2DB.teams[SkymPetCodex2Teams.menuTeamIndex].name = text;
        SkymPetCodex2Teams_UpdateTeamList();
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent();
        local text = parent.editBox:GetText();
        Skym_PetCodex2DB.teams[SkymPetCodex2Teams.menuTeamIndex].name = text;
        SkymPetCodex2Teams_UpdateTeamList();
        parent:Hide();
    end,
    OnShow = function(self)
        ChatEdit_FocusActiveWindow();
        self.editBox:SetText(Skym_PetCodex2DB.teams[SkymPetCodex2Teams.menuTeamIndex].name);
    end,
    timeout = 0,
    exclusive = true,
    hideOnEscape = true
};

StaticPopupDialogs["SKYM_PET_CODEX_2_TEAM_DELETE"] = {
    text= "Etes-vous certain de vouloir effacer l'équippe \"%s\" ?",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = false,
    OnAccept = function(self)
        table.remove(Skym_PetCodex2DB.teams, SkymPetCodex2Teams.menuTeamIndex);
        SkymPetCodex2Teams_UpdateTeamList();
    end,
    timeout = 0,
    exclusive = true,
    hideOnEscape = true
};

-- Slash command

SLASH_SPC21 = '/spc2';

function SlashCmdList.SPC2(msg, editbox)
    SkymPetCodex2MainFrame:Show();
end

-- Minimap icon

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)
if LDB then
    local SkymPetCodex2Launcher = LDB:NewDataObject("SkymPetCodex2", {
        type = "launcher",
        icon = "Interface\\Icons\\PetJournalPortrait",
        OnClick = function(clickedframe, button)
            if button == "RightButton" then SkymPetCodex2MainFrame:Show() else SkymPetCodex2MainFrame:Show() end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("Skym Pet Codex 2")
        --tt:AddLine("|cffffff00" .. "Click|r to toggle the SkymPetCodex2 main window")
        --tt:AddLine("|cffffff00" .. "Right-click|r to open the options menu")
        end,
    })
    if LDBIcon then
        LDBIcon:Register("SkymPetCodex2", SkymPetCodex2Launcher, Skym_PetCodex2DB.MinimapIcon)
    end
end

-- Main frame

function SkymPetCodex2MainFrame_SetTab(self, tab)
    PanelTemplates_SetTab(self, tab);
    Skym_PetCodex2DB.skymPetCodex2Tab = tab;
    SkymPetCodex2MainFrame_UpdateSelectedTab(self);
end

function SkymPetCodex2MainFrame_UpdateSelectedTab(self)
    local selected = PanelTemplates_GetSelectedTab(self);
    if ( selected == 1 ) then
        SkymPetCodex2Teams:Show();
        SkymPetCodex2Mascottes:Hide();
        SkymPetCodex2Recherche:Hide();
    elseif (selected == 2 ) then
        SkymPetCodex2Teams:Hide();
        SkymPetCodex2Mascottes:Show();
        SkymPetCodex2Recherche:Hide();
    else
        SkymPetCodex2Teams:Hide();
        SkymPetCodex2Mascottes:Hide();
        SkymPetCodex2Recherche:Show();
    end
end

function SkymPetCodex2MainFrame_OnShow(self)
    PlaySound("igCharacterInfoOpen");
    if (Skym_PetCodex2DB.skymPetCodex2Tab == "3") then
        SkymPetCodex2MainFrame_SetTab(self, 3);
    elseif (Skym_PetCodex2DB.skymPetCodex2Tab == "2") then
        SkymPetCodex2MainFrame_SetTab(self, 2);
    else
        SkymPetCodex2MainFrame_SetTab(self, 1);
    end
    SkymPetCodex2MainFrame_UpdateSelectedTab(self);
    UpdateMicroButtons();
end

function SkymPetCodex2MainFrame_OnHide()
    PlaySound("igCharacterInfoClose");
    UpdateMicroButtons();
end

-- Teams

function SkymPetCodex2Teams_OnShow(self)
    SkymPetCodex2Teams_UpdateTeamList();
    SkymPetCodex2Teams_UpdatePetList();
    SkymPetCodex2Teams_UpdatePetLoadOut();
    UIDropDownMenu_Initialize(self.teamOptionsMenu, TeamOptionsMenu_Init, "MENU");
end

function SkymPetCodex2Teams_OnHide(self)
    print("SkymPetCodex2Teams_OnHide");
end

function SkymPetCodex2Teams_OnLoad(self)
    self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
    self:RegisterEvent("PET_JOURNAL_LIST_UPDATE");
    self:RegisterEvent("PET_JOURNAL_PET_DELETED");
    self:RegisterEvent("PET_JOURNAL_PETS_HEALED");
    self:RegisterEvent("PET_JOURNAL_CAGE_FAILED");
    self:RegisterEvent("BATTLE_PET_CURSOR_CLEAR");
    self:RegisterEvent("COMPANION_UPDATE");
    self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED");
    self:RegisterEvent("PET_BATTLE_QUEUE_STATUS");

    self.teamsScroll.update = SkymPetCodex2Teams_UpdateTeamList;
    self.teamsScroll.scrollBar.doNotHide = true;
    HybridScrollFrame_CreateButtons(self.teamsScroll, "TeamListButtonTemplate", 44, 0);

    self.listScroll.update = SkymPetCodex2Teams_UpdatePetList;
    self.listScroll.scrollBar.doNotHide = true;
    HybridScrollFrame_CreateButtons(self.listScroll, "CompanionListButtonTemplate", 44, 0);
end

function SkymPetCodex2Teams_OnEvent(self, event, ...)
    print(event)
    if event == "PET_JOURNAL_LIST_UPDATE" then
        SkymPetCodex2Teams_UpdatePetList();
        PetJournal_HidePetDropdown();
    end

--    if event == "PET_BATTLE_LEVEL_CHANGED" then
--        PetJournal_UpdatePetLoadOut();
--    elseif event == "PET_JOURNAL_PET_DELETED" then
--        local petID = ...;
--        if (PetJournal_IsPendingCage(petID)) then
--            PetJournal_ClearPendingCage();
--        end
--        PetJournal_UpdatePetList();
--        PetJournal_UpdatePetLoadOut();
--        if(PetJournalPetCard.petID == petID) then
--            PetJournal_ShowPetCard(1);
--        end
--        PetJournal_FindPetCardIndex();
--        PetJournal_UpdatePetCard(PetJournalPetCard);
--        PetJournal_HidePetDropdown();
--    elseif event == "PET_JOURNAL_CAGE_FAILED" then
--        PetJournal_ClearPendingCage();
--    elseif event == "PET_JOURNAL_PETS_HEALED" then
--        PetJournal_UpdatePetLoadOut();
--    elseif event == "PET_JOURNAL_LIST_UPDATE" then
--        PetJournal_FindPetCardIndex();
--        PetJournal_UpdatePetList();
--        PetJournal_UpdatePetLoadOut();
--        PetJournal_UpdatePetCard(PetJournalPetCard);
--        PetJournal_HidePetDropdown();
--    elseif event == "BATTLE_PET_CURSOR_CLEAR" then
--        PetJournal.Loadout.Pet1.setButton:Hide();
--        PetJournal.Loadout.Pet2.setButton:Hide();
--        PetJournal.Loadout.Pet3.setButton:Hide();
--    elseif event == "COMPANION_UPDATE" then
--        local companionType = ...;
--        if companionType == "CRITTER" then
--            PetJournal_UpdatePetList();
--            PetJournal_UpdateSummonButtonState();
--        end
--    elseif event == "ACHIEVEMENT_EARNED" then
--        PetJournal.AchievementStatus.SumText:SetText(GetCategoryAchievementPoints(PET_ACHIEVEMENT_CATEGORY, true));
--    elseif event == "PET_BATTLE_QUEUE_STATUS" then
--        PetJournal_UpdatePetLoadOut();
--    end
end

function SkymPetCodex2Teams_UpdatePetList()
    local scrollFrame = SkymPetCodex2Teams.listScroll;
    local offset = HybridScrollFrame_GetOffset(scrollFrame);
    local petButtons = scrollFrame.buttons;
    local pet, index;

    local numPets, numOwned = C_PetJournal.GetNumPets();
    SkymPetCodex2Teams.PetCount.Count:SetText(numOwned);

    local summonedPetID = C_PetJournal.GetSummonedPetGUID();

    for i = 1,#petButtons do
        pet = petButtons[i];
        index = offset + i;
        if index <= numPets then
            local petID, speciesID, isOwned, customName, level, favorite, isRevoked, name, icon, petType, _, _, _, _, canBattle = C_PetJournal.GetPetInfoByIndex(index);

            if customName then
                pet.name:SetText(customName);
                pet.name:SetHeight(12);
                pet.subName:Show();
                pet.subName:SetText(name);
            else
                pet.name:SetText(name);
                pet.name:SetHeight(30);
                pet.subName:Hide();
            end
            pet.icon:SetTexture(icon);
            pet.petTypeIcon:SetTexture(GetPetTypeTexture(petType));

            if (favorite) then
                pet.dragButton.favorite:Show();
            else
                pet.dragButton.favorite:Hide();
            end

            if isOwned then
                local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);

                pet.dragButton.levelBG:SetShown(canBattle);
                pet.dragButton.level:SetShown(canBattle);
                pet.dragButton.level:SetText(level);

                pet.icon:SetDesaturated(false);
                pet.name:SetFontObject("GameFontNormal");
                pet.petTypeIcon:SetShown(canBattle);
                pet.petTypeIcon:SetDesaturated(false);
                pet.dragButton:Enable();
                pet.iconBorder:Show();
                pet.iconBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);
                if (health and health <= 0) then
                    pet.isDead:Show();
                else
                    pet.isDead:Hide();
                end
                if(isRevoked) then
                    pet.dragButton.levelBG:Hide();
                    pet.dragButton.level:Hide();
                    pet.iconBorder:Hide();
                    pet.icon:SetDesaturated(true);
                    pet.petTypeIcon:SetDesaturated(true);
                    pet.dragButton:Disable();
                end
            else
                pet.dragButton.levelBG:Hide();
                pet.dragButton.level:Hide();
                pet.icon:SetDesaturated(true);
                pet.iconBorder:Hide();
                pet.name:SetFontObject("GameFontDisable");
                pet.petTypeIcon:SetShown(canBattle);
                pet.petTypeIcon:SetDesaturated(true);
                pet.dragButton:Disable();
                pet.isDead:Hide();
            end

            if ( petID and petID == summonedPetID ) then
                pet.dragButton.ActiveTexture:Show();
            else
                pet.dragButton.ActiveTexture:Hide();
            end

            pet.petID = petID;
            pet.speciesID = speciesID;
            pet.index = index;
            pet.owned = isOwned;
            pet:Show();

            if ( petID ) then
                local start, duration, enable = C_PetJournal.GetPetCooldownByGUID(pet.petID);
                if (start) then
                    CooldownFrame_SetTimer(pet.dragButton.Cooldown, start, duration, enable);
                end
            end
        else
            pet:Hide();
        end
    end

    local totalHeight = numPets * COMPANION_BUTTON_HEIGHT;
    HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
end

function SkymPetCodex2Teams_ShowTeamDropdown(index, anchorTo, offsetX, offsetY, teamIndex)
    SkymPetCodex2Teams.menuTeamIndex = index;
    ToggleDropDownMenu(1, nil, SkymPetCodex2Teams.teamOptionsMenu, anchorTo, offsetX, offsetY);
end

function SkymPetCodex2Teams_HideTeamDropdown()
    HideDropDownMenu(1);
end

-- PetCount

function SkymPetCodex2PetCount_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(BATTLE_PETS_TOTAL_PETS, 1, 1, 1);
    GameTooltip:AddLine(BATTLE_PETS_TOTAL_PETS_TOOLTIP, nil, nil, nil, true);
    GameTooltip:Show();
end

-- BattlePets

function SkymPetCodex2Mascottes_OnLoad(self)
    print("SkymPetCodex2Mascottes_OnLoad");
end

-- Search

function SkymPetCodex2Recherche_OnLoad(self)
    print("SkymPetCodex2Recherche_OnLoad");
end

-- Menus

function TeamOptionsMenu_Init(self, level)
    local info = UIDropDownMenu_CreateInfo();
    info.notCheckable = true;

    info.text = "Renommer";
    info.func = function()
        print("Renommer");
        StaticPopup_Show("SKYM_PET_CODEX_2_TEAM_RENAME", Skym_PetCodex2DB.teams[SkymPetCodex2Teams.menuTeamIndex].name);
    end;
    UIDropDownMenu_AddButton(info, level);

    info.text = "Supprimer";
    info.func = function()
        StaticPopup_Show("SKYM_PET_CODEX_2_TEAM_DELETE", Skym_PetCodex2DB.teams[SkymPetCodex2Teams.menuTeamIndex].name);
    end;
    UIDropDownMenu_AddButton(info, level);

    info.text = CANCEL
    info.func = nil
    UIDropDownMenu_AddButton(info, level)
end

function SkymPetCodex2TeamsTeamItem_OnClick(self, button)
    if button == "RightButton" then
        SkymPetCodex2Teams_ShowTeamDropdown(self.index, self, 80, 20);
    else
        -- Charger équippe.
    end
end

function SkymPetCodex2Teams_CreateTeam(text)
    Skym_PetCodex2DB.teams = Skym_PetCodex2DB.teams or {};
    local team = {name = text};
    team.pet = {}
    for i=1,MAX_ACTIVE_PETS do
        local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);
        team.pet[i] = {
            id = petID,
            ability1ID = ability1ID,
            ability2ID = ability2ID,
            ability3ID = ability3ID,
            locked = locked
        }
    end
    Skym_PetCodex2DB.teams[1 + #Skym_PetCodex2DB.teams] = team;
    SkymPetCodex2Teams_UpdateTeamList();
end

function SkymPetCodex2Teams_UpdatePetLoadOut()
    for i=1,MAX_ACTIVE_PETS do
        local loadoutPlate = SkymPetCodex2Teams.Loadout["Pet"..i];
        local petID, ability1ID, ability2ID, ability3ID, locked = C_PetJournal.GetPetLoadOutInfo(i);

        loadoutPlate.ReadOnlyFrame:Hide();
        if (petID == nil) then
            loadoutPlate.name:Hide();
            loadoutPlate.subName:Hide();
            loadoutPlate.level:Hide();
            loadoutPlate.levelBG:Hide();
            loadoutPlate.icon:Hide();
            loadoutPlate.qualityBorder:Hide();
            loadoutPlate.favorite:Hide()
            loadoutPlate.model:Hide();
            loadoutPlate.xpBar:Hide();
            loadoutPlate.healthFrame:Hide();
            loadoutPlate.spell1:Hide();
            loadoutPlate.spell2:Hide();
            loadoutPlate.spell3:Hide();
            loadoutPlate.iconBorder:Hide();
            loadoutPlate.helpFrame:Hide();
            loadoutPlate.requirement:Hide();
            loadoutPlate.emptyslot:Show();
            loadoutPlate.emptyslot.slot:SetText(format(BATTLE_PET_SLOT, i));
            loadoutPlate.dragButton:Show();
            loadoutPlate.isDead:Hide();
            loadoutPlate.petTypeIcon:Hide();
            loadoutPlate.petID = nil;
        else -- petID is not nil
            local speciesID, customName, level, xp, maxXp, displayID, isFavorite, name, icon, petType = C_PetJournal.GetPetInfoByPetID(petID);
            C_PetJournal.GetPetAbilityList(speciesID, loadoutPlate.abilities, loadoutPlate.abilityLevels);	--Read ability/ability levels into the correct tables

            --Find out how many abilities are usable due to level
            local numUsableAbilities = 0;
            for j=1, #loadoutPlate.abilityLevels do
                if ( loadoutPlate.abilityLevels[j] and level >= loadoutPlate.abilityLevels[j] ) then
                    numUsableAbilities = numUsableAbilities + 1;
                end
            end

            --If we don't have something in a flyout, automatically put there the lower level ability
            if ( ability1ID == 0 and loadoutPlate.abilities[1] ) then
                ability1ID = loadoutPlate.abilities[1];
                C_PetJournal.SetAbility(i, 1, ability1ID);
            end
            if ( ability2ID == 0 and loadoutPlate.abilities[2] ) then
                ability2ID = loadoutPlate.abilities[2];
                C_PetJournal.SetAbility(i, 2, ability2ID);
            end
            if ( ability3ID == 0 and loadoutPlate.abilities[3] ) then
                ability3ID = loadoutPlate.abilities[3];
                C_PetJournal.SetAbility(i, 3, ability3ID);
            end
            loadoutPlate.name:Show();
            loadoutPlate.subName:Show();
            loadoutPlate.level:Show();
            loadoutPlate.levelBG:Show();
            loadoutPlate.icon:Show();
            loadoutPlate.iconBorder:Show();
            loadoutPlate.spell1:Show();
            loadoutPlate.spell2:Show();
            loadoutPlate.spell3:Show();

            if (isFavorite) then
                loadoutPlate.favorite:Show()
            else
                loadoutPlate.favorite:Hide()
            end

            if customName then
                loadoutPlate.name:SetText(customName);
                loadoutPlate.name:SetHeight(12);
                loadoutPlate.subName:Show();
                loadoutPlate.subName:SetText(name);
            else
                loadoutPlate.name:SetText(name);
                loadoutPlate.name:SetHeight(28);
                loadoutPlate.subName:Hide();
            end
            loadoutPlate.level:SetText(level);
            loadoutPlate.icon:SetTexture(icon);

            loadoutPlate.petTypeIcon:Show();
            loadoutPlate.petTypeIcon:SetTexture(GetPetTypeTexture(petType));
            loadoutPlate.petID = petID;
            loadoutPlate.speciesID = speciesID;
            if(level < MAX_PET_LEVEL) then
                loadoutPlate.xpBar:Show();
            else
                loadoutPlate.xpBar:Hide();
            end

            loadoutPlate.xpBar:SetMinMaxValues(0, maxXp);
            loadoutPlate.xpBar:SetValue(xp);
            local display = GetCVar("statusTextDisplay")
            if (display == "3") then
                loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_BOTH, xp, maxXp, xp/maxXp*100);
            elseif (display == "2") then
                loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_PERCENT, xp/maxXp*100);
            else
                loadoutPlate.xpBar.rankText:SetFormattedText(PET_BATTLE_CURRENT_XP_FORMAT_VERBOSE, xp, maxXp);
            end
            loadoutPlate.xpBar.tooltip = format(PET_BATTLE_CURRENT_XP_FORMAT_TOOLTIP, xp, maxXp, xp/maxXp*100);

            local health, maxHealth, attack, speed, rarity = C_PetJournal.GetPetStats(petID);
            loadoutPlate.healthFrame.healthValue:SetFormattedText(PET_BATTLE_CURRENT_HEALTH_FORMAT, health, maxHealth);
            loadoutPlate.healthFrame.healthBar:SetMinMaxValues(0, maxHealth);
            loadoutPlate.healthFrame.healthBar:SetValue(health);
            loadoutPlate.healthFrame:Show();

            loadoutPlate.qualityBorder:SetVertexColor(ITEM_QUALITY_COLORS[rarity-1].r, ITEM_QUALITY_COLORS[rarity-1].g, ITEM_QUALITY_COLORS[rarity-1].b);

            loadoutPlate.isDead:SetShown(health <= 0);

            loadoutPlate.model:Show();
            local modelChanged = false;
            if ( displayID ~= loadoutPlate.displayID ) then
                loadoutPlate.displayID = displayID;
                loadoutPlate.model:SetDisplayInfo(displayID);
                loadoutPlate.model:SetDoBlend(false);
                modelChanged = true;
            end
            local isDead = health <= 0;
            if ( modelChanged or isDead ~= loadoutPlate.model.wasDead ) then
                if ( isDead ) then
                    loadoutPlate.model:SetAnimation(6,-1);
                else
                    loadoutPlate.model:SetAnimation(0,-1);
                end
                loadoutPlate.model.wasDead = isDead;
            end

--            PetJournal_UpdatePetAbility(loadoutPlate.spell1, ability1ID, petID);
--            PetJournal_UpdatePetAbility(loadoutPlate.spell2, ability2ID, petID);
--            PetJournal_UpdatePetAbility(loadoutPlate.spell3, ability3ID, petID);

            loadoutPlate.spell1.enabled = true;
            loadoutPlate.spell2.enabled = true;
            loadoutPlate.spell3.enabled = true;
            loadoutPlate.spell1:GetHighlightTexture():SetAlpha(1);
            loadoutPlate.spell2:GetHighlightTexture():SetAlpha(1);
            loadoutPlate.spell3:GetHighlightTexture():SetAlpha(1);
            loadoutPlate.spell1:GetPushedTexture():SetAlpha(1);
            loadoutPlate.spell2:GetPushedTexture():SetAlpha(1);
            loadoutPlate.spell3:GetPushedTexture():SetAlpha(1);
            loadoutPlate.spell1.FlyoutArrow:Show();
            loadoutPlate.spell2.FlyoutArrow:Show();
            loadoutPlate.spell3.FlyoutArrow:Show();

            loadoutPlate.helpFrame:Hide();
            loadoutPlate.requirement:Hide();
            loadoutPlate.emptyslot:Hide();
            loadoutPlate.dragButton:Show();
        end
    end

--    PetJournal.Loadout.Pet1.setButton:Hide();
--    PetJournal.Loadout.Pet2.setButton:Hide();
--    PetJournal.Loadout.Pet3.setButton:Hide();
end