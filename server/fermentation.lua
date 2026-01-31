-- Callback pour vérifier si le joueur a un tonneau vide
ESX.RegisterServerCallback('jks_vigneron:hasContainer', function(source, cb)
    DebugPrint("Vérification container", {source = source})
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local hasContainer = xPlayer.getInventoryItem(Config.FermentationSettings.whiteWine.container).count > 0
        DebugPrint("Container trouvé", {hasContainer = hasContainer, count = xPlayer.getInventoryItem(Config.FermentationSettings.whiteWine.container).count})
        cb(hasContainer)
    else
        LogError("Joueur non trouvé", {source = source})
        cb(false)
    end
end)

-- Callback pour récupérer les informations d'un tonneau
ESX.RegisterServerCallback('jks_vigneron:getBarrelInfo', function(source, cb, itemName)
    DebugPrint("Récupération infos tonneau", {source = source, itemName = itemName})
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        LogError("Joueur non trouvé pour getBarrelInfo", {source = source})
        cb(nil)
        return
    end
    
    local barrelItem = xPlayer.getInventoryItem(itemName)
    if barrelItem and barrelItem.count > 0 and barrelItem.metadata then
        cb({
            wineQuantity = barrelItem.metadata.wineQuantity or 0,
            grapeType = barrelItem.metadata.grapeType or 'unknown',
            vintage = barrelItem.metadata.vintage or 'N/A',
            grapesUsed = barrelItem.metadata.grapesUsed or 0,
            maxCapacity = barrelItem.metadata.maxCapacity or 0,
            createdAt = barrelItem.metadata.createdAt or 0
        })
    else
        cb(nil)
    end
end)

RegisterNetEvent('jks_vigneron:depositGrapes')
AddEventHandler('jks_vigneron:depositGrapes', function(quantity, cuveId, grapeType)
    local _source = source
    DebugPrint("Dépôt de grappes", {source = _source, quantity = quantity, cuveId = cuveId, grapeType = grapeType})
    
    if not _source then
        LogError("Source est nul pour depositGrapes")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(_source)
    local playerId = xPlayer and xPlayer.identifier or nil

    if not playerId or not cuveId or not grapeType then
        LogError("Paramètres manquants pour depositGrapes", {playerId = playerId, cuveId = cuveId, grapeType = grapeType})
        return
    end

    -- Déterminer la configuration selon le type de raisin
    local config = nil
    if grapeType == 'white' then
        config = Config.FermentationSettings.whiteWine
    elseif grapeType == 'red' then
        config = Config.FermentationSettings.redWine
    else
        TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Type de raisin non valide.')
        return
    end

    -- Utiliser les limites définies dans la configuration
    local minGrapes = config.minGrapes
    local maxGrapes = config.maxGrapes
    
    -- Vérifier que la quantité est dans les limites
    if quantity < minGrapes or quantity > maxGrapes then
        TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Quantité invalide! Minimum: ' .. minGrapes .. ', Maximum: ' .. maxGrapes)
        return
    end

    -- Vérifier si la cuve est déjà pleine pour ce joueur
    MySQL.Async.fetchScalar('SELECT COUNT(*) FROM jks_fermentation_tank WHERE player_id = @player_id AND cuve_id = @cuve_id', {
        ['@player_id'] = playerId,
        ['@cuve_id'] = cuveId
    }, function(count)
        if count > 0 then
            TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'La cuve ' .. cuveId .. ' est déjà pleine. Vous ne pouvez pas y déposer plus de grappes.')
        else
            if xPlayer.getInventoryItem(config.input).count >= quantity then
                xPlayer.removeInventoryItem(config.input, quantity)

                -- Calculer le temps de fermentation basé sur la quantité réelle
                local fermentationTime = quantity * config.fermentationTimePerGrape

                MySQL.Async.execute('INSERT INTO jks_fermentation_tank (player_id, grapes_quantity, deposit_time, fermentation_time, cuve_id, grape_type) VALUES (@player_id, @quantity, @deposit_time, @fermentation_time, @cuve_id, @grape_type)', {
                    ['@player_id'] = playerId,
                    ['@quantity'] = quantity,
                    ['@deposit_time'] = os.time(),
                    ['@fermentation_time'] = fermentationTime,
                    ['@cuve_id'] = cuveId,
                    ['@grape_type'] = grapeType
                })

                TriggerClientEvent('ESX:Notify', _source, 'success', 5000, 'Vous avez déposé ' .. quantity .. ' ' .. config.inputLabel .. ' pour fermentation dans la cuve ' .. cuveId .. '.')
            else
                TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Vous n\'avez pas assez de ' .. config.inputLabel .. ' (' .. quantity .. ' requis).')
            end
        end
    end)
end)

RegisterNetEvent('jks_vigneron:retrieveWine')
AddEventHandler('jks_vigneron:retrieveWine', function(cuveId)
    local _source = source
    DebugPrint("Récupération de vin", {source = _source, cuveId = cuveId})
    
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Vérification de xPlayer et cuveId
    if not xPlayer or not cuveId then
        LogError("xPlayer ou cuveId est nul", {xPlayer = xPlayer, cuveId = cuveId})
        return
    end

    local playerId = xPlayer.identifier
    local currentTime = os.time()

    -- Requête SQL pour récupérer les informations dans la cuve
    MySQL.Async.fetchAll('SELECT * FROM jks_fermentation_tank WHERE player_id = @player_id AND cuve_id = @cuve_id', {
        ['@player_id'] = playerId,
        ['@cuve_id'] = cuveId
    }, function(result)
        if result and #result > 0 then
            for i = 1, #result, 1 do
                local entry = result[i]
                local timeElapsed = currentTime - entry.deposit_time

                if entry.deposit_time and entry.fermentation_time then
                    if timeElapsed >= entry.fermentation_time then
                        -- Déterminer la configuration selon le type de raisin
                        local config = nil
                        if entry.grape_type == 'white' then
                            config = Config.FermentationSettings.whiteWine
                        elseif entry.grape_type == 'red' then
                            config = Config.FermentationSettings.redWine
                        else
                            TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Type de raisin non valide dans la base de données.')
                            return
                        end

                        -- Supprimer l'entrée de la base de données
                        MySQL.Async.execute('DELETE FROM jks_fermentation_tank WHERE id = @id', {['@id'] = entry.id})

                        -- Calculer la quantité de vin basée sur la quantité de raisins fermentés
                        local wineQuantity = math.floor(entry.grapes_quantity * Config.FermentationSettings.grapesToWineRatio)
                        
                        -- Le joueur ne peut récupérer qu'un seul tonneau à la fois
                        local barrelsToGive = 1
                        local actualWineQuantity = math.min(wineQuantity, config.winePerBarrel)
                        
                        -- Vérifier si le joueur a un container
                        if xPlayer.getInventoryItem(config.container).count >= 1 then
                            -- Supprimer un container et donner un tonneau de vin avec métadonnées
                            xPlayer.removeInventoryItem(config.container, 1)
                            
                            -- Calculer l'année de millésime
                            local vintageYear = os.date('%Y', entry.deposit_time)
                            
                            -- Créer les métadonnées du tonneau
                            local barrelMetadata = {
                                wineQuantity = actualWineQuantity,
                                grapeType = entry.grape_type,
                                vintage = vintageYear,
                                grapesUsed = entry.grapes_quantity,
                                maxCapacity = config.winePerBarrel,
                                createdAt = os.date('%d/%m/%Y à %H:%M', os.time())
                            }
                            
                            -- Donner le tonneau avec métadonnées
                            xPlayer.addInventoryItem(config.output, 1, barrelMetadata)

                            -- Notifier le joueur avec les détails
                            TriggerClientEvent('ESX:Notify', _source, 'success', 5000, 
                                'Fermentation terminée ! ' .. entry.grapes_quantity .. ' grappes → ' .. actualWineQuantity .. 'L de vin dans 1 tonneau (Millésime ' .. vintageYear .. ')')
                                
                            -- Si il y a du vin en surplus, informer le joueur
                            if wineQuantity > config.winePerBarrel then
                                local surplusWine = wineQuantity - config.winePerBarrel
                                TriggerClientEvent('ESX:Notify', _source, 'info', 5000, 
                                    'Note: ' .. surplusWine .. 'L de vin supplémentaires ont été perdus (limite d\'un tonneau par récupération)')
                            end
                        else
                            -- Si le joueur n'a pas de container
                            TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 
                                'Vous avez besoin d\'un ' .. config.containerLabel .. ' pour récupérer le vin.')
                        end
                    else
                        local remainingTime = entry.fermentation_time - timeElapsed
                        TriggerClientEvent('ESX:Notify', _source, 'info', 5000, 'Votre vin dans la cuve ' .. cuveId .. ' n\'est pas encore prêt. Temps restant : ' .. math.ceil(remainingTime / 60) .. ' minutes.')
                    end
                else
                    print("Erreur : entry.deposit_time ou entry.fermentation_time est nul")
                    TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Erreur : données de fermentation non valides.')
                end
            end
        else
            -- Si aucun vin en fermentation, envoyer une notification
            TriggerClientEvent('ESX:Notify', _source, 'info', 5000, 'Aucun vin en fermentation dans la cuve ' .. cuveId .. '.')
        end
    end)
end)

RegisterNetEvent('jks_vigneron:deposerTonneau')
AddEventHandler('jks_vigneron:deposerTonneau', function(wineType)
    local _source = source
    DebugPrint("Dépôt de tonneau", {source = _source, wineType = wineType})
    
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Déterminer la configuration selon le type de vin
    local config = nil
    if wineType == 'white' then
        config = Config.FermentationSettings.whiteWine
    elseif wineType == 'red' then
        config = Config.FermentationSettings.redWine
    else
        TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Type de vin non valide.')
        return
    end

    -- Vérifier si le joueur a l'item de sortie dans son inventaire
    if xPlayer.getInventoryItem(config.output).count > 0 then
        -- Récupérer les métadonnées via ox_inventory
        local inventory = exports.ox_inventory:GetInventory(_source)
        local wineQuantity = config.winePerBarrel -- Valeur par défaut
        
        -- Chercher le tonneau avec métadonnées
        for slot, item in pairs(inventory.items) do
            if item.name == config.output and item.metadata and item.metadata.wineQuantity then
                wineQuantity = item.metadata.wineQuantity
                break
            end
        end
        
        -- Supprimer l'item de sortie de l'inventaire avec ox_inventory pour préserver les métadonnées
        exports.ox_inventory:RemoveItem(_source, config.output, 1)

        -- Ajouter des litres de vin à la cuve principale selon le type
        local cuveName = wineType == 'white' and 'principal_blanc' or 'principal_rouge'
        MySQL.Async.execute('UPDATE jks_vigneron SET litres = litres + @wine_amount WHERE cuve = @cuve_name', {
            ['@wine_amount'] = wineQuantity,
            ['@cuve_name'] = cuveName
        }, function(affectedRows)
            if affectedRows > 0 then
                -- Notifier le joueur que le vin a été ajouté
                TriggerClientEvent('ESX:Notify', _source, 'success', 5000, wineQuantity .. ' litres de vin ' .. wineType .. ' ont été ajoutés à la cuve principale.')

                -- Informer le client de supprimer le props (tonneau)
                TriggerClientEvent('jks_vigneron:removeBarrelProps', _source)

            else
                -- Si la cuve n'existe pas encore, l'ajouter
                MySQL.Async.execute('INSERT INTO jks_vigneron (cuve, litres) VALUES (@cuve_name, @wine_amount)', {
                    ['@cuve_name'] = cuveName,
                    ['@wine_amount'] = wineQuantity
                }, function()
                    TriggerClientEvent('ESX:Notify', _source, 'success', 5000, 'Une nouvelle cuve principale a été créée avec ' .. wineQuantity .. ' litres de vin ' .. wineType .. '.')

                    -- Informer le client de supprimer le props (tonneau)
                    TriggerClientEvent('jks_vigneron:removeBarrelProps', _source)
                end)
            end
        end)
    else
        TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Vous n\'avez pas de ' .. config.outputLabel .. ' à déposer.')
    end
end)

RegisterNetEvent('jks_vigneron:checkCuve')
AddEventHandler('jks_vigneron:checkCuve', function(cuveId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Vérification de xPlayer et cuveId
    if not xPlayer or not cuveId then
        LogError("xPlayer ou cuveId est nul", {xPlayer = xPlayer, cuveId = cuveId})
        return
    end

    local playerId = xPlayer.identifier
    local currentTime = os.time()

    -- Requête SQL pour récupérer les informations de la cuve
    MySQL.Async.fetchAll('SELECT * FROM jks_fermentation_tank WHERE player_id = @player_id AND cuve_id = @cuve_id', {
        ['@player_id'] = playerId,
        ['@cuve_id'] = cuveId
    }, function(result)
        if result and #result > 0 then
            for i = 1, #result, 1 do
                local entry = result[i]
                local timeElapsed = currentTime - entry.deposit_time
                local remainingTime = entry.fermentation_time - timeElapsed

                if entry.deposit_time and entry.fermentation_time then
                    -- Déterminer la configuration selon le type de raisin
                    local config = nil
                    if entry.grape_type == 'white' then
                        config = Config.FermentationSettings.whiteWine
                    elseif entry.grape_type == 'red' then
                        config = Config.FermentationSettings.redWine
                    end
                    
                    -- Préparer les données pour l'UI
                    local cuveData = {
                        cuveId = cuveId,
                        grapesQuantity = entry.grapes_quantity,
                        depositTime = entry.deposit_time,
                        fermentationTime = entry.fermentation_time,
                        grapeType = entry.grape_type,
                        remainingTime = math.max(0, remainingTime),
                        isReady = timeElapsed >= entry.fermentation_time,
                        progress = math.min((timeElapsed / entry.fermentation_time) * 100, 100),
                        -- Informations d'item depuis la config
                        itemName = config and config.input or 'unknown',
                        itemLabel = config and config.inputLabel or 'Unknown Item',
                        itemImage = config and ('nui://ox_inventory/web/images/' .. config.input .. '.png') or '',
                        -- Dates formatées côté serveur
                        formattedDepositDate = os.date('%d/%m/%Y %H:%M', entry.deposit_time),
                        vintageYear = os.date('%Y', entry.deposit_time),
                        formattedEndDate = os.date('%d/%m/%Y %H:%M', entry.deposit_time + entry.fermentation_time),
                        serverTime = os.time()
                    }
                    
                    -- Envoyer les données au client pour afficher l'UI
                    TriggerClientEvent('jks_vigneron:showCuveInfo', _source, cuveData)
                else
                    print("Erreur : entry.deposit_time ou entry.fermentation_time est nul")
                    TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Erreur : données de fermentation non valides pour la cuve ' .. cuveId .. '.')
                end
            end
        else
            -- Si aucune donnée en fermentation n'est trouvée, envoyer des données vides
            local emptyCuveData = {
                cuveId = cuveId,
                grapesQuantity = 0,
                depositTime = 0,
                fermentationTime = 0,
                grapeType = 'white',
                remainingTime = 0,
                isReady = false,
                progress = 0,
                isEmpty = true
            }
            TriggerClientEvent('jks_vigneron:showCuveInfo', _source, emptyCuveData)
        end
    end)
end)

RegisterNetEvent('jks_vigneron:checkCuvePrincipale')
AddEventHandler('jks_vigneron:checkCuvePrincipale', function(wineType)
    local _source = source

    local cuveName = wineType == 'white' and 'principal_blanc' or 'principal_rouge'
    local wineLabel = wineType == 'white' and 'blanc' or 'rouge'

    -- Requête SQL pour obtenir le nombre de litres dans la cuve principale
    MySQL.Async.fetchScalar('SELECT litres FROM jks_vigneron WHERE cuve = @cuve_name', {
        ['@cuve_name'] = cuveName
    }, function(litres)
        if litres then
            TriggerClientEvent('ESX:Notify', _source, 'info', 5000, 'La cuve principale de vin ' .. wineLabel .. ' contient actuellement ' .. litres .. ' litres.')
        else
            TriggerClientEvent('ESX:Notify', _source, 'info', 5000, 'La cuve principale de vin ' .. wineLabel .. ' est vide.')
        end
    end)
end)

-- Callback pour vérifier si le joueur a des bouteilles vides
ESX.RegisterServerCallback('jks_vigneron:hasEmptyBottles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and Config.Bottling and Config.Bottling.whiteWine and Config.Bottling.whiteWine.container then
        local hasBottles = xPlayer.getInventoryItem(Config.Bottling.whiteWine.container).count > 0
        cb(hasBottles)
    else
        cb(false)
    end
end)

-- Callback pour vérifier la quantité de vin disponible dans la cuve
ESX.RegisterServerCallback('jks_vigneron:getTankWineAmount', function(source, cb, wineType)
    local cuveName = wineType == 'white' and 'principal_blanc' or 'principal_rouge'
    
    MySQL.Async.fetchAll('SELECT litres FROM jks_vigneron WHERE cuve = @cuve_name', {
        ['@cuve_name'] = cuveName
    }, function(result)
        local wineAmount = result[1] and result[1].litres or 0
        cb(wineAmount)
    end)
end)

-- Fonction pour déterminer la qualité du vin
function determineWineQuality()
    DebugPrint("Détermination de la qualité du vin")
    
    if not Config.Bottling.quality.enabled then
        DebugPrint("Système de qualité désactivé, retour qualité par défaut")
        return Config.Bottling.quality.qualities[1] -- Retourner la qualité par défaut
    end
    
    local random = math.random(1, 100)
    local cumulativeChance = 0
    
    DebugPrint("Calcul qualité", {random = random})
    
    for _, quality in ipairs(Config.Bottling.quality.qualities) do
        cumulativeChance = cumulativeChance + quality.chance
        if random <= cumulativeChance then
            DebugPrint("Qualité déterminée", {quality = quality.name, chance = quality.chance})
            return quality
        end
    end
    
    -- Fallback vers la première qualité si aucune n'est sélectionnée
    DebugPrint("Fallback vers qualité par défaut")
    return Config.Bottling.quality.qualities[1]
end

-- Événement pour mettre en bouteille depuis la cuve principale
RegisterNetEvent('jks_vigneron:bottleWineFromTank')
AddEventHandler('jks_vigneron:bottleWineFromTank', function(wineType, bottleCount)
    local _source = source
    DebugPrint("Mise en bouteille depuis cuve", {source = _source, wineType = wineType, bottleCount = bottleCount})
    
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not xPlayer or not Config.Bottling then return end
    
    local config = wineType == 'white' and Config.Bottling.whiteWine or Config.Bottling.redWine
    if not config then return end
    
    local cuveName = wineType == 'white' and 'principal_blanc' or 'principal_rouge'
    
    -- Vérifier le nombre de bouteilles demandé
    if not bottleCount or bottleCount < 1 then
        bottleCount = 1
    end
    
    local totalBottlesNeeded = bottleCount
    local totalWineNeeded = bottleCount * config.winePerBottle
    
    -- VÉRIFICATION FINALE : Vérifier si le joueur a encore assez de bouteilles vides
    local currentEmptyBottles = xPlayer.getInventoryItem(config.container).count
    if currentEmptyBottles < totalBottlesNeeded then
        TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Vous n\'avez plus assez de ' .. config.containerLabel .. '. Vous en avez ' .. currentEmptyBottles .. ' sur ' .. totalBottlesNeeded .. ' nécessaires.')
        return
    end
    
    -- VÉRIFICATION FINALE : Vérifier s'il y a encore assez de vin dans la cuve
    MySQL.Async.fetchAll('SELECT litres FROM jks_vigneron WHERE cuve = @cuve_name', {
        ['@cuve_name'] = cuveName
    }, function(result)
        local currentWineAmount = result[1] and result[1].litres or 0
        
        if currentWineAmount < totalWineNeeded then
            local maxPossible = math.floor(currentWineAmount / config.winePerBottle)
            TriggerClientEvent('ESX:Notify', _source, 'error', 5000, 'Il n\'y a plus assez de vin dans la cuve. Disponible: ' .. currentWineAmount .. 'L (max ' .. maxPossible .. ' bouteilles).')
            return
        end
        
        -- Si tout est OK, procéder à la transaction
        -- Retirer les bouteilles vides
        xPlayer.removeInventoryItem(config.container, totalBottlesNeeded)
        
        -- Retirer le vin de la cuve
        MySQL.Async.execute('UPDATE jks_vigneron SET litres = litres - @wine_amount WHERE cuve = @cuve_name', {
            ['@wine_amount'] = totalWineNeeded,
            ['@cuve_name'] = cuveName
        })
        
        -- Créer les métadonnées pour les bouteilles
        local wineQuality = determineWineQuality()
        local bottleMetadata = {
            vintage = os.date('%Y', os.time()), -- Millésime (année actuelle)
            bottledDate = os.date('%d/%m/%Y à %H:%M', os.time()), -- Date de mise en bouteille
            bottledBy = xPlayer.getName(), -- Nom du joueur qui a mis en bouteille
            wineAmount = config.winePerBottle, -- Quantité de vin par bouteille
            quality = wineQuality.name, -- Qualité du vin
            qualityLabel = wineQuality.label, -- Label de la qualité
            qualityDescription = wineQuality.description -- Description de la qualité
        }
        
        -- Ajouter les bouteilles de vin avec métadonnées
        for i = 1, totalBottlesNeeded do
            exports.ox_inventory:AddItem(_source, config.output, 1, bottleMetadata)
        end
        
        -- Notifier le joueur
        TriggerClientEvent('ESX:Notify', _source, 'success', 5000, 'Vous avez mis en bouteille ' .. totalBottlesNeeded .. ' ' .. config.outputLabel .. '.')
        
        -- Notifier la qualité obtenue
        if wineQuality.name ~= 'Commun' then
            TriggerClientEvent('ESX:Notify', _source, 'info', 8000, '⭐ Qualité obtenue: ' .. wineQuality.label .. ' - ' .. wineQuality.description)
        end
    end)
end)
