local QBCore = exports['qb-core']:GetCoreObject()
local PlayerGang = QBCore.Functions.GetPlayerData().gang
local shownGangMenu = false
local shownGangMenu2 = false

-- UTIL
local function CloseMenuFullGang()
    exports['qb-menu']:closeMenu()
    exports['qb-core']:HideText()

end

local function comma_valueGang(amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

--//Events
AddEventHandler('onResourceStart', function(resource)--if you restart the resource
    if resource == GetCurrentResourceName() then
        Wait(200)
        PlayerGang = QBCore.Functions.GetPlayerData().gang
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerGang = QBCore.Functions.GetPlayerData().gang
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
    PlayerGang = InfoGang
end)

RegisterNetEvent('qb-gangmenu:client:Stash', function()
    TriggerServerEvent("inventory:server:OpenInventory", "stash", "fraktion_" .. PlayerGang.name, {
        maxweight = 4000000,
        slots = 100,
    })
    TriggerEvent("inventory:client:SetCurrentStash", "fraktion_" .. PlayerGang.name)
end)

RegisterNetEvent('qb-gangmenu:client:Warbobe', function()
    TriggerEvent('qb-clothing:client:openOutfitMenu')
end)

RegisterNetEvent('qb-gangmenu:client:OpenMenu', function()
    shownGangMenu = true
    local gangMenu = {
        {
            header = "Fraktion verwalten - " .. string.upper(PlayerGang.label),
            isMenuHeader = true,
        },
        {
            header = "📋 Mitglieder",
            txt = "Rekrutiere oder Feuere Mitglieder",
            params = {
                event = "qb-gangmenu:client:ManageGang",
            }
        },
        {
            header = "💛 Rekrutieren",
            txt = "Rekrutiere Bürger",
            params = {
                event = "qb-gangmenu:client:HireMembers",
            }
        },
        {
            header = "💰 Fraktionskonto",
            txt = "Überprüfen das Firmenkapital",
            params = {
                event = "qb-gangmenu:client:SocietyMenu",
            }
        },
        {
            header = "Schließen",
            params = {
                event = "qb-menu:closeMenu",
            }
        },
    }
    exports['qb-menu']:openMenu(gangMenu)
end)

RegisterNetEvent('qb-gangmenu:client:OpenMenu2', function()
    shownGangMenu2 = true
    local gangMenu = {
        {
            header = "Fraktion - " .. string.upper(PlayerGang.label),
            isMenuHeader = true,
        },
        {
            header = "🗄️ Lager",
            txt = "Lager öffnen",
            params = {
                event = "qb-gangmenu:client:Stash",
            }
        },
        {
            header = "🚪 Outfits",
            txt = "Gespeicherte Outfits",
            params = {
                event = "qb-gangmenu:client:Warbobe",
            }
        },
        {
            header = "Schließen",
            params = {
                event = "qb-menu:closeMenu",
            }
        },
    }
    exports['qb-menu']:openMenu(gangMenu)
end)

RegisterNetEvent('qb-gangmenu:client:ManageGang', function()
    local GangMembersMenu = {
        {
            header = "Mitglieder verwalten - " .. string.upper(PlayerGang.label),
            isMenuHeader = true,
        },
    }
    QBCore.Functions.TriggerCallback('qb-gangmenu:server:GetEmployees', function(cb)
        for _, v in pairs(cb) do
            GangMembersMenu[#GangMembersMenu + 1] = {
                header = v.name,
                txt = v.grade.name,
                params = {
                    event = "qb-gangmenu:lient:ManageMember",
                    args = {
                        player = v,
                        work = PlayerGang
                    }
                }
            }
        end
        GangMembersMenu[#GangMembersMenu + 1] = {
            header = "< Zurück",
            params = {
                event = "qb-gangmenu:client:OpenMenu",
            }
        }
        exports['qb-menu']:openMenu(GangMembersMenu)
    end, PlayerGang.name)
end)

RegisterNetEvent('qb-gangmenu:lient:ManageMember', function(data)
    local MemberMenu = {
        {
            header = "Verwalten " .. data.player.name .. " - " .. string.upper(PlayerGang.label),
            isMenuHeader = true,
        },
    }
    for k, v in pairs(QBCore.Shared.Gangs[data.work.name].grades) do
        MemberMenu[#MemberMenu + 1] = {
            header = v.name,
            txt = "Rang: " .. k,
            params = {
                isServer = true,
                event = "qb-gangmenu:server:GradeUpdate",
                args = {
                    cid = data.player.empSource,
                    degree = tonumber(k),
                    named = v.name
                }
            }
        }
    end
    MemberMenu[#MemberMenu + 1] = {
        header = "Feuern",
        params = {
            isServer = true,
            event = "qb-gangmenu:server:FireMember",
            args = data.player.empSource
        }
    }
    MemberMenu[#MemberMenu + 1] = {
        header = "< Zurück",
        params = {
            event = "qb-gangmenu:client:ManageGang",
        }
    }
    exports['qb-menu']:openMenu(MemberMenu)
end)

RegisterNetEvent('qb-gangmenu:client:HireMembers', function()
    local HireMembersMenu = {
        {
            header = "Rekrutieren - " .. string.upper(PlayerGang.label),
            isMenuHeader = true,
        },
    }
    QBCore.Functions.TriggerCallback('qb-gangmenu:getplayers', function(players)
        for _, v in pairs(players) do
            if v and v ~= PlayerId() then
                HireMembersMenu[#HireMembersMenu + 1] = {
                    header = v.name,
                    txt = "Bürger ID: " .. v.citizenid .. " - ID: " .. v.sourceplayer,
                    params = {
                        isServer = true,
                        event = "qb-gangmenu:server:HireMember",
                        args = v.sourceplayer
                    }
                }
            end
        end
        HireMembersMenu[#HireMembersMenu + 1] = {
            header = "< Zurück",
            params = {
                event = "qb-gangmenu:client:OpenMenu",
            }
        }
        exports['qb-menu']:openMenu(HireMembersMenu)
    end)
end)

RegisterNetEvent('qb-gangmenu:client:SocietyMenu', function()
    QBCore.Functions.TriggerCallback('qb-gangmenu:server:GetAccount', function(cb)
        local SocietyMenu = {
            {
                header = "Kapital: $" .. comma_valueGang(cb) .. " - " .. string.upper(PlayerGang.label),
                isMenuHeader = true,
            },
            {
                header = "💸 Einzahlen",
                txt = "Geld auf das Fraktionskonto einzahlen",
                params = {
                    event = "qb-gangmenu:client:SocietyDeposit",
                    args = comma_valueGang(cb)
                }
            },
            {
                header = "💸 Abheben",
                txt = "Geld vom Fraktionskonto abheben",
                params = {
                    event = "qb-gangmenu:client:SocietyWithdraw",
                    args = comma_valueGang(cb)
                }
            },
            {
                header = "< Return",
                params = {
                    event = "qb-gangmenu:client:OpenMenu",
                }
            },
        }
        exports['qb-menu']:openMenu(SocietyMenu)
    end, PlayerGang.name)
end)

RegisterNetEvent('qb-gangmenu:client:SocietyDeposit', function(saldoattuale)
    local deposit = exports['qb-input']:ShowInput({
        header = "Geld einzahlen <br> Kapital: $" .. saldoattuale,
        submitText = "Bestätigen",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = 'Amount'
            }
        }
    })
    if deposit then
        if not deposit.amount then return end
        TriggerServerEvent("qb-gangmenu:server:depositMoney", tonumber(deposit.amount))
    end
end)

RegisterNetEvent('qb-gangmenu:client:SocietyWithdraw', function(saldoattuale)
    local withdraw = exports['qb-input']:ShowInput({
        header = "Geld abheben <br> Kapital: $" .. saldoattuale,
        submitText = "Bestätigen",
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = '$'
            }
        }
    })
    if withdraw then
        if not withdraw.amount then return end
        TriggerServerEvent("qb-gangmenu:server:withdrawMoney", tonumber(withdraw.amount))
    end
end)



-- MAIN THREAD

CreateThread(function()
        while true do
            local wait = 2500
            local pos = GetEntityCoords(PlayerPedId())
            local inRangeGang = false
            local nearGangmenu = false
            if PlayerGang then
                
                wait = 0
                for k, menus in pairs(Config.GangMenus.boss) do
                    for _, coords in ipairs(menus) do
                        if k == PlayerGang.name and PlayerGang.isboss then
                            if #(pos - coords) < 5.0 then
                                inRangeGang = true
                                if #(pos - coords) <= 1.5 then
                                    nearGangmenu = true
                                    if not shownGangMenu then 
                                        exports['qb-core']:DrawText('[E] Fraktionsverwaltung', 'left')
                                    end

                                    if IsControlJustReleased(0, 38) then
                                        exports['qb-core']:HideText()
                                        TriggerEvent("qb-gangmenu:client:OpenMenu")
                                    end
                                end
                                
                                if not nearGangmenu and shownGangMenu then
                                    CloseMenuFullGang()
                                    shownGangMenu = false
                                end
                            end
                        end
                    end
                end
                if not inRangeGang then
                    Wait(1500)
                    if shownGangMenu then
                        CloseMenuFullGang()
                        shownGangMenu = false
                    end
                end
            end
            Wait(wait)
        end
end)

CreateThread(function()
    while true do
        local wait = 2500
        local pos = GetEntityCoords(PlayerPedId())
        local inRangeGang2 = false
        local nearGangmenu2 = false
        if PlayerGang then
            
            wait = 0

            for k, menus in pairs(Config.GangMenus.stash) do
                for _, coords in ipairs(menus) do
                    if k == PlayerGang.name then
                        if #(pos - coords) < 5.0 then
                            inRangeGang2 = true
                            if #(pos - coords) <= 1.5 then
                                nearGangmenu2 = true
                                if not shownGangMenu2 then 
                                    exports['qb-core']:DrawText('[E] Fraktionsmenü', 'left')
                                end

                                if IsControlJustReleased(0, 38) then
                                    exports['qb-core']:HideText()
                                    TriggerEvent("qb-gangmenu:client:OpenMenu2")
                                end
                            end
                            
                            if not nearGangmenu2 and shownGangMenu2 then
                                CloseMenuFullGang()
                                shownGangMenu2 = false
                            end
                        end
                    end
                end
            end
            if not inRangeGang2 then
                Wait(1500)
                if shownGangMenu2 then
                    CloseMenuFullGang()
                    shownGangMenu2 = false
                end
            end
        end
        Wait(wait)
    end
end)
