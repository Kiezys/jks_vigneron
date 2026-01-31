Config = {}

--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                              🍷 CONFIGURATION 🍷                            ║
║                                                                              ║
║  🌾 Configuration du système vigneron                                       ║
║  🍇 Récolte, fermentation et vente de vin                                     ║
║  📦 Stashes et zones d'interaction                                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ⚙️ Configuration générale
Config.General = {
    requiredJob = 'vigneron',         -- 👥 Job requis pour utiliser le script
    requiredGroups = 'vigneron',      -- 🔐 Groups requis pour les interactions ox_target
    debug = false,                    -- 🐛 Activer/désactiver le mode debug
}

--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                            🌾 SYSTÈME DE RÉCOLTE 🌾                        ║
║                                                                              ║
║  Configuration complète du système de récolte de raisins                   ║
║  Inclut les zones, paramètres et limites                                    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]
-- 🌾 Configuration des zones de récolte avec leurs items associés
Config.HarvestZones = {
    {
        id = 'red_grapes',
        name = 'Raisins rouges',
        coords = vector3(-1730.3909912109, 2180.6879882812, 109.58501434326),
        item = 'red_grapes',
        label = 'Grappes de raisin rouge',
        minAmount = 2,
        maxAmount = 6,
        maxItemsPerReboot = 250,        -- Limite maximum d'items récoltables par reboot (par joueur)
        icon = 'fa-solid fa-hand-sparkles',
        blipSprite = 85,
        blipColor = 2
    },
    {
        id = 'white_grapes',
        name = 'Raisins blancs',
        coords = vector3(-1722.5949707031, 2331.0773925781, 65.092437744141),
        item = 'white_grapes',
        label = 'Grappes de raisin blanc',
        minAmount = 2,
        maxAmount = 6,
        maxItemsPerReboot = 250,        -- Limite maximum d'items récoltables par reboot (par joueur)
        icon = 'fa-solid fa-hand-sparkles',
        blipSprite = 85,
        blipColor = 1
    }
}

-- ⚙️ Configuration des paramètres de récolte
Config.HarvestSettings = {
    autoHarvest = true,               -- 🔄 Activer/désactiver l'auto-récolte
    radius = 30.0,                    -- 📏 Rayon des zones d'interaction
    harvestTime = 5000,               -- ⏱️ Temps de récolte en ms
    intervalTime = 2500,              -- 🔄 Intervalle entre chaque récolte en ms (2.5 secondes)
    enableMaxItemsLimit = true,       -- 📊 Activer/désactiver le système de limitation par reboot
    animation = {
        dict = "amb@prop_human_bum_bin@idle_b",
        lib = "idle_d"
    },
    messages = {
        started = 'Récolte automatique démarrée. Bougez pour arrêter.',
        stopped = 'Récolte automatique arrêtée.',
        stopped_inventory_full = 'Récolte automatique arrêtée - Inventaire plein.',
        stopped_limit_reached = 'Récolte automatique arrêtée - Limite atteinte.',
        manual_harvest = 'Récolte manuelle effectuée.',
        manual_harvest_failed = 'Récolte échouée.'
    }
}

--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🍇 SYSTÈME DE FERMENTATION 🍇                       ║
║                                                                              ║
║  Configuration complète du système de fermentation des raisins en vin       ║
║  Inclut les cuves individuelles et principales                             ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]
-- 🍇 Configuration du système de fermentation
Config.FermentationSettings = {
    -- 🍷 Items utilisés pour la fermentation (raisins blancs)
    whiteWine = {
        input = 'white_grapes',        -- 📥 Item à déposer pour la fermentation
        inputLabel = 'Grappes de raisin blanc', -- 🏷️ Label de l'item d'entrée
        output = 'tonneaux_blanc',     -- 📤 Item produit après fermentation
        outputLabel = 'Tonneau de vin blanc', -- 🏷️ Label de l'item de sortie
        container = 'tonneaux_vide',   -- 📦 Container nécessaire pour récupérer
        containerLabel = 'Tonneau vide', -- 🏷️ Label du container
        
        -- ⚙️ Paramètres spécifiques au vin blanc
        defaultGrapes = 25,           -- 🍇 Nombre de grappes suggéré par défaut
        fermentationTimePerGrape = 5,    -- ⏱️ Temps de fermentation par grappe en secondes
        winePerBarrel = 30,            -- 🍷 Litres de vin par tonneau
        
        -- 📊 Limites de quantité pour le dépôt
        minGrapes = 20,                -- 🍇 Minimum de grappes pour un dépôt réaliste
        maxGrapes = 50,                -- 🍇 Maximum de grappes pour un dépôt réaliste (limité à 1 tonneau)
    },
    
    -- 🍷 Items utilisés pour la fermentation (raisins rouges)
    redWine = {
        input = 'red_grapes',          -- 📥 Item à déposer pour la fermentation
        inputLabel = 'Grappes de raisin rouge', -- 🏷️ Label de l'item d'entrée
        output = 'tonneaux_rouge',     -- 📤 Item produit après fermentation
        outputLabel = 'Tonneau de vin rouge', -- 🏷️ Label de l'item de sortie
        container = 'tonneaux_vide',   -- 📦 Container nécessaire pour récupérer
        containerLabel = 'Tonneau vide', -- 🏷️ Label du container
        
        -- ⚙️ Paramètres spécifiques au vin rouge
        defaultGrapes = 30,           -- 🍇 Nombre de grappes suggéré par défaut
        fermentationTimePerGrape = 7,    -- ⏱️ Temps de fermentation par grappe en secondes
        winePerBarrel = 35,            -- 🍷 Litres de vin par tonneau
        
        -- 📊 Limites de quantité pour le dépôt
        minGrapes = 25,                -- 🍇 Minimum de grappes pour un dépôt réaliste
        maxGrapes = 60,                -- 🍇 Maximum de grappes pour un dépôt réaliste (limité à 1 tonneau)
    },
    
    -- ⏱️ Temps d'animations
    depositTime = 5000,               -- ⏱️ Temps de dépôt des grappes en ms
    retrieveTime = 5000,              -- ⏱️ Temps de récupération du vin en ms
    
    -- 🍷 Ratio de conversion raisins → vin
    grapesToWineRatio = 0.7,          -- 📊 Litres de vin par kg de raisins (ratio réaliste)
    
    -- 🎭 Animation de fermentation
    animation = {
        dict = "amb@prop_human_bum_bin@idle_b",
        lib = "idle_d"
    },
    
    -- 🏺 Configuration des cuves individuelles
    individualTanks = {
        {
            id = 1,
            name = "Cuve 1",
            coords = vector3(-1931.80, 2057.99, 141.23),
            radius = 2.0
        },
        {
            id = 2,
            name = "Cuve 2", 
            coords = vector3(-1932.33, 2055.62, 141.25),
            radius = 2.0
        },
        {
            id = 3,
            name = "Cuve 3",
            coords = vector3(-1933.00, 2052.72, 141.27),
            radius = 2.0
        }
    },
    
    -- 🏪 Configuration des cuves principales
    mainTanks = {
        white = {
            name = "Cuve principale (vin blanc)",
            coords = vector3(-1868.26, 2055.96, 141.25),
            radius = 2.0
        },
        red = {
            name = "Cuve principale (vin rouge)",
            coords = vector3(-1868.33, 2058.73, 141.29), -- Coordonnées différentes
            radius = 2.0
        }
    }
}

--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🍾 SYSTÈME DE MISE EN BOUTEILLE 🍾                   ║
║                                                                              ║
║  Configuration complète du système de mise en bouteille avec qualité        ║
║  Inclut les animations, props et système de qualité réaliste               ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]
-- 🍾 Configuration du système de mise en bouteille
Config.Bottling = {
    -- 🍷 Vin blanc
    whiteWine = {
        output = 'bouteille_vin_blanc',  -- 📤 Bouteille de vin blanc produite
        outputLabel = 'Bouteille de vin blanc',
        container = 'bouteille_vide',   -- 📦 Bouteille vide nécessaire
        containerLabel = 'Bouteille vide',
        bottlesPerFill = 1,             -- 🍾 Nombre de bouteilles par remplissage
        bottlingTime = 3000,            -- ⏱️ Temps de mise en bouteille en ms
        winePerBottle = 1,              -- 🍷 Litres de vin par bouteille
    },
    
    -- 🍷 Vin rouge
    redWine = {
        output = 'bouteille_vin_rouge',  -- 📤 Bouteille de vin rouge produite
        outputLabel = 'Bouteille de vin rouge',
        container = 'bouteille_vide',    -- 📦 Bouteille vide nécessaire
        containerLabel = 'Bouteille vide',
        bottlesPerFill = 1,              -- 🍾 Nombre de bouteilles par remplissage
        bottlingTime = 3000,             -- ⏱️ Temps de mise en bouteille en ms
        winePerBottle = 1,               -- 🍷 Litres de vin par bouteille
    },
    
    -- 🎭 Animation de mise en bouteille
    animation = {
        dict = "amb@prop_human_bum_bin@idle_b",
        lib = "idle_d"
    },
    
    -- 🍾 Props pour plus de réalisme
    props = {
        whiteWine = {
            model = "prop_wine_white",        -- 🍷 Modèle de bouteille de vin blanc
            bone = 60309,                     -- 🦴 Os de la main droite (bone correct)
            offset = vector3(0.2, -0.1, 0.1), -- 📍 Position relative optimisée
            rotation = vector3(241.0, 319.0, 0.0) -- 🔄 Rotation optimisée
        },
        redWine = {
            model = "prop_wine_red",          -- 🍷 Modèle de bouteille de vin rouge
            bone = 60309,                     -- 🦴 Os de la main droite (bone correct)
            offset = vector3(0.2, -0.1, 0.1), -- 📍 Position relative optimisée
            rotation = vector3(241.0, 319.0, 0.0) -- 🔄 Rotation optimisée
        }
    },
    
    -- ⭐ Système de qualité du vin
    quality = {
        enabled = true,                      -- 🎯 Activer le système de qualité
        qualities = {
            {
                name = 'Commun',
                label = 'Vin de Table',
                chance = 70,                 -- 📊 70% de chance (majorité des vins)
                description = 'Vin de consommation courante'
            },
            {
                name = 'Bon',
                label = 'Vin de Qualité',
                chance = 20,                 -- 📊 20% de chance (vins corrects)
                description = 'Vin de bonne qualité'
            },
            {
                name = 'Excellent',
                label = 'Vin d\'Appellation',
                chance = 8,                  -- 📊 8% de chance (vins d\'appellation)
                description = 'Vin d\'appellation contrôlée'
            },
            {
                name = 'Exceptionnel',
                label = 'Grand Cru',
                chance = 1.8,                -- 📊 1.8% de chance (grands crus)
                description = 'Vin de grand cru'
            },
            {
                name = 'Légendaire',
                label = 'Millésime Exceptionnel',
                chance = 0.2,                -- 📊 0.2% de chance (millésimes légendaires)
                description = 'Millésime d\'exception'
            }
        }
    }
}

--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                            🛒 SYSTÈME DE COMMANDES 🛒                      ║
║                                                                              ║
║  Configuration du système de commande et livraison de tonneaux            ║
║  Inclut les zones de récupération et dépôt                                ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]
-- 🛒 Configuration des commandes de tonneaux
Config.BarrelOrders = {
    pricePerBarrel = 1000,            -- 💰 Prix par tonneau vide
    barrelWeight = 5000,              -- ⚖️ Poids d'un tonneau vide (5kg)
    minGrade = 1,                     -- 📊 Grade minimum requis pour commander
}

-- 🚚 Configuration de la zone de récupération des commandes
Config.DeliveryZone = {
    coords = vector3(-841.96606445312, 5400.9243164062, 34.958763122559), -- Zone de récupération
    radius = 2.0,
    blip = {
        sprite = 478, -- Icône de livraison
        color = 2,    -- Vert
        scale = 0.8,
        name = "Zone de récupération des commandes"
    }
}

-- 🏢 Configuration de la zone de dépôt à l'entreprise
Config.DepositZone = {
    coords = vector3(-1936.0340576172, 2041.7132568359, 140.70919799805), -- Zone de dépôt à l'entreprise
    radius = 2.0,
    blip = {
        sprite = 478, -- Icône de dépôt
        color = 3,    -- Jaune
        scale = 0.8,
        name = "Zone de dépôt des tonneaux"
    }
}

--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                            📦 STOCKAGE & ÉQUIPEMENT 📦                     ║
║                                                                              ║
║  Configuration des coffres de stockage et équipements des vignerons       ║
║  Inclut les stashes et zones de changement de tenues                      ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]
-- 📦 Configuration des stashes
Config.Stashes = {
    {
        id = 'vigneron_stash',
        name = 'Coffre Principal',
        coords = vector3(-1893.4417724609, 2060.4489746094, 141.09080505371),
        radius = 0.5,
        icon = 'fa-solid fa-box-open',
        iconColor = '#bf0404',
        label = 'Ouvrir Coffre Principal',
        slots = 25,
        weight = 500000 -- 500kg
    },
    {
        id = 'vigneron_barrel_stash',   -- ne pas modifier ou si modification modifier aussi coté server/tonneaux.lua
        name = 'Stockage Tonneaux',
        slots = 100, -- Plus de slots pour les tonneaux
        weight = 500000, -- 500kg
    },
}

-- 👕 Configuration des vêtements
Config.Outfits = {
    {
        id = 'vigneron_outfit_1',
        name = 'Tenue Vigneron Classique',
        coords = vector3(-1874.259765625, 2052.6142578125, 141.26528930664),
        radius = 0.5,
        icon = 'fas fa-user-edit',
        iconColor = '#bf0404',
        label = 'Ouvrir le menu des tenues',
        event = 'illenium-appearance:client:openOutfitMenu'
    },
}

--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                            🗺️ CONFIGURATION DES BLIPS 🗺️                   ║
║                                                                              ║
║  Configuration des blips sur la carte pour les zones importantes           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]
-- 🗺️ Configuration des blips (générés automatiquement depuis HarvestZones)
Config.Blips = {}

Config.UniversalBlips = {
    ['Vineyard'] = {
        name = "🍷 Vignoble",
        coords = vector3(-1883.86, 2061.85, 140.35),
        sprite = 85,  -- 🍇 Icône de vigne
        color = 47,  -- 🟣 Couleur violet (ou tu peux choisir une autre couleur)
        scale = 0.8,
        display = 4
    }
}