local function oneItemDisinfect(hotItem, playerObj, oneItem)
    ISTimedActionQueue.add(ISDisinfectBandage:new(playerObj, oneItem, hotItem));
end

local function allItemDisinfect(hotItem, playerObj, items)
    for i = 1, #items do
        ISTimedActionQueue.add(ISDisinfectBandage:new(playerObj, items[i], hotItem));
    end
end

local function AllDisinfect(hotItem, playerObj, bandageArr, sheetsArr)

    for i = 1, #bandageArr do
        ISTimedActionQueue.add(ISDisinfectBandage:new(playerObj, bandageArr[i], hotItem));
    end

    for i = 1, #sheetsArr do
        ISTimedActionQueue.add(ISDisinfectBandage:new(playerObj, sheetsArr[i], hotItem));
    end
    
end

local function DisinfectBandage(player, context, items)

    local playerObj = getSpecificPlayer(player)
    local inventory = playerObj:getInventory()

    local bandageArr = {}
    local sheetsArr = {}

    inventory:getAllEval(function(item)
        if item:getFullType() == "Base.Bandage" then
            table.insert(bandageArr, item)
        elseif item:getFullType() == "Base.RippedSheets" then
            table.insert(sheetsArr, item)
        end
    end)

    local hotItem = nil

    for _, entry in ipairs(items) do
        local item = entry.items and entry.items[1] or entry
        if item and item:hasComponent(ComponentType.FluidContainer) then
            if item:getFluidContainer():getAmount() >= 0.1 and item:getItemHeat() > 1.6 then
                hotItem = item
                break
            end
        end
    end

    if not hotItem then
        return
    end

    if #bandageArr + #sheetsArr == 0 then
        return
    end

    local mainmenu = context:addOption(getText("ContextMenu_Disinfect"), hotItem, nil)
    local submenu = ISContextMenu:getNew(context)
    context:addSubMenu(mainmenu, submenu)

    submenu:addOption(getText("ContextMenu_Disinfect_AllBandage"), hotItem, AllDisinfect, playerObj, bandageArr, sheetsArr)

    local oneItem = nil
    if #bandageArr + #sheetsArr == 1 then
        if #bandageArr == 1 and #sheetsArr == 0 then
            oneItem = bandageArr[1]
        end
        if #sheetsArr == 1 and #bandageArr == 0 then
            oneItem = sheetsArr[1]
        end

        local submenuOne = submenu:addOption(getText("ContextMenu_Disinfect_One", oneItem:getDisplayName()), hotItem, oneItemDisinfect, playerObj, oneItem)
        context:addSubMenu(submenu, submenuOne)
        return
    end

    if #bandageArr > 0 then
        local submenu2 = submenu:addOption(getText("IGUI_ItemCat_Bandage", bandageArr[1]:getDisplayName()), hotItem, nil)
        context:addSubMenu(submenu, submenu2)

        local submenu3 = ISContextMenu:getNew(submenu)
        context:addSubMenu(submenu2, submenu3)

        submenu3:addOption(getText("ContextMenu_Disinfect_AllBandage"), hotItem, allItemDisinfect, playerObj, bandageArr)
        submenu3:addOption(getText("ContextMenu_Disinfect_OneBandage"), hotItem, oneItemDisinfect, playerObj, bandageArr[1])
    end

    if #sheetsArr > 0 then
        local submenu2 = submenu:addOption(getText("IGUI_FabricType_1", sheetsArr[1]:getDisplayName()), hotItem, nil, playerObj, oneItem)
        context:addSubMenu(submenu, submenu2)

        local submenu3 = ISContextMenu:getNew(submenu)
        context:addSubMenu(submenu2, submenu3)

        submenu3:addOption(getText("ContextMenu_Disinfect_AllBandage"), hotItem, allItemDisinfect, playerObj, sheetsArr)
        submenu3:addOption(getText("ContextMenu_Disinfect_OneBandage"), hotItem, oneItemDisinfect, playerObj, sheetsArr[1])
    end
end

Events.OnFillInventoryObjectContextMenu.Add(DisinfectBandage)
