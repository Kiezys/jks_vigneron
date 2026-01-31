# 🍷 Système Vigneron ESX

<div align="center">

![Version](https://img.shields.io/badge/Version-2.6.0-green.svg)
![ESX](https://img.shields.io/badge/ESX-Optimisé-blue.svg)
![FiveM](https://img.shields.io/badge/FiveM-Compatible-orange.svg)

**Un système complet de vigneron pour FiveM ESX avec récolte, fermentation, mise en bouteille et système de qualité**

*Créé par Kiezys*

</div>

---

## 🌟 Fonctionnalités

### 🌾 **Système de Récolte Avancé**
- ✅ Récolte de raisins rouges et blancs
- ✅ **Mode auto-récolte configurable** (true/false)
- ✅ **Mode récolte manuelle** (une seule récolte par interaction)
- ✅ Limite configurable par reboot
- ✅ Zones personnalisables avec blips automatiques
- ✅ **Système de debug intégré**

### 🍇 **Système de Fermentation Complet**
- ✅ Cuves individuelles pour chaque joueur
- ✅ Maturation séparée blanc/rouge avec temps différents
- ✅ Cuves principales pour stockage et mise en bouteille
- ✅ Paramètres configurables par type de vin
- ✅ **Interface ox_lib context menu** pour les informations de cuve
- ✅ **Métadonnées complètes** sur les tonneaux (millésime, créateur, etc.)

### 🍾 **Système de Mise en Bouteille**
- ✅ **Mise en bouteille depuis les cuves principales**
- ✅ **Système de qualité réaliste** (5 niveaux de qualité)
- ✅ **Métadonnées sur les bouteilles** (millésime, date, créateur, qualité)
- ✅ Animations et props réalistes
- ✅ Configuration flexible des quantités

### ⭐ **Système de Qualité du Vin**
- ✅ **5 niveaux de qualité** avec chances réalistes :
  - 🔘 Vin de Table (70%)
  - 🟢 Vin de Qualité (20%)
  - 🔵 Vin d'Appellation (8%)
  - 🟡 Grand Cru (1.8%)
  - 🔴 Millésime Exceptionnel (0.2%)
- ✅ **Notifications spéciales** pour les qualités supérieures
- ✅ **Descriptions détaillées** pour chaque qualité

### 🛒 **Système de Commandes de Tonneaux**
- ✅ **Commande de tonneaux vides** avec grade requis
- ✅ **Missions de livraison** avec zones de récupération et dépôt
- ✅ **Système de prix configurable**
- ✅ **Blips automatiques** pour les missions

### 🏪 **Vente & Économie**
- ✅ Intégration ESX Society
- ✅ Système de vente automatique
- ✅ Gestion des stocks

### 📦 **Stashes Configurables**
- ✅ Ajout illimité de coffres
- ✅ Positions personnalisables
- ✅ Labels et icônes personnalisés
- ✅ **Stash spéciale pour tonneaux** avec capacité étendue

### 👕 **Système de Vêtements**
- ✅ **Zones de changement de tenues** avec illenium-appearance
- ✅ Configuration flexible des zones

### 🗺️ **Système de Blips**
- ✅ **Blips automatiques** pour toutes les zones importantes
- ✅ **Blip principal du vignoble**
- ✅ Configuration centralisée

### 🐛 **Système de Debug Avancé**
- ✅ **Mode debug configurable** (true/false)
- ✅ **Logs avec niveaux** (ERROR, WARNING, INFO, VERBOSE)
- ✅ **Couleurs distinctives** pour chaque niveau
- ✅ **Logs centralisés** dans tous les fichiers
- ✅ **Fonctions utilitaires** réutilisables

---

## 🛠️ Installation

### 1. **Prérequis**
- 🎮 ESX Framework
- 🎯 ox_target (pour les interactions)
- 📦 ox_inventory (pour la stash et métadonnées)
- ⏱️ ox_lib (pour les menus et progressbars)
- 🗄️ oxmysql (pour la base de données)
- 👕 illenium-appearance (pour les vêtements)

### 2. **Installation**
1. 📁 Placer le script dans `resources/jks_vigneron/`
2. 🗄️ Exécuter le fichier SQL `jks_vigneron.sql`
3. ⚙️ Ajouter `ensure jks_vigneron` dans `server.cfg`
4. 🔄 Redémarrer le serveur

### 3. **Configuration ESX Society**
```sql
-- Dans votre base de données
INSERT INTO `addon_account` (`name`, `label`, `shared`) VALUES
('society_vigneron', 'Vigneron', 1);

INSERT INTO `addon_account_data` (`account_name`, `money`) VALUES
('society_vigneron', 0);
```

---

## ⚙️ Configuration

### ⚙️ **Configuration Générale**
```lua
Config.General = {
    requiredJob = 'vigneron',         -- 👥 Job requis
    requiredGroups = 'vigneron',      -- 🔐 Groups requis
    debug = false,                    -- 🐛 Mode debug
}
```

### 🌾 **Système de Récolte**
```lua
Config.HarvestSettings = {
    autoHarvest = true,               -- 🔄 Mode auto-récolte
    radius = 30.0,                    -- 📏 Rayon des zones
    harvestTime = 5000,               -- ⏱️ Temps de récolte
    intervalTime = 2500,              -- 🔄 Intervalle entre récoltes
    enableMaxItemsLimit = true,       -- 📊 Limitation par reboot
    animation = {
        dict = "amb@prop_human_bum_bin@idle_b",
        lib = "idle_d"
    },
    messages = {
        started = 'Récolte automatique démarrée. Bougez pour arrêter.',
        stopped = 'Récolte automatique arrêtée.',
        manual_harvest = 'Récolte manuelle effectuée.',
        manual_harvest_failed = 'Récolte échouée.'
    }
}
```

### 🍇 **Système de Fermentation**
```lua
Config.FermentationSettings = {
    whiteWine = {
        input = 'white_grapes',
        output = 'tonneaux_blanc',
        container = 'tonneaux_vide',
        defaultGrapes = 25,           -- 🍇 Grappes par défaut
        fermentationTimePerGrape = 5, -- ⏱️ Temps par grappe
        winePerBarrel = 30,           -- 🍷 Litres par tonneau
        minGrapes = 20,               -- 🍇 Minimum requis
        maxGrapes = 50,               -- 🍇 Maximum autorisé
    },
    redWine = {
        input = 'red_grapes',
        output = 'tonneaux_rouge',
        container = 'tonneaux_vide',
        defaultGrapes = 30,
        fermentationTimePerGrape = 7,
        winePerBarrel = 35,
        minGrapes = 25,
        maxGrapes = 60,
    },
    grapesToWineRatio = 0.7,          -- 📊 Ratio raisins → vin
}
```

### 🍾 **Système de Mise en Bouteille**
```lua
Config.Bottling = {
    whiteWine = {
        output = 'bouteille_vin_blanc',
        container = 'bouteille_vide',
        bottlingTime = 3000,          -- ⏱️ Temps de mise en bouteille
        winePerBottle = 1,            -- 🍷 Litres par bouteille
    },
    redWine = {
        output = 'bouteille_vin_rouge',
        container = 'bouteille_vide',
        bottlingTime = 3000,
        winePerBottle = 1,
    },
    quality = {
        enabled = true,                -- 🎯 Système de qualité
        qualities = {
            {
                name = 'Commun',
                label = 'Vin de Table',
                chance = 70,           -- 📊 70% de chance
                description = 'Vin de consommation courante'
            },
            {
                name = 'Bon',
                label = 'Vin de Qualité',
                chance = 20,           -- 📊 20% de chance
                description = 'Vin de bonne qualité'
            },
            {
                name = 'Excellent',
                label = 'Vin d\'Appellation',
                chance = 8,            -- 📊 8% de chance
                description = 'Vin d\'appellation contrôlée'
            },
            {
                name = 'Exceptionnel',
                label = 'Grand Cru',
                chance = 1.8,          -- 📊 1.8% de chance
                description = 'Vin de grand cru'
            },
            {
                name = 'Légendaire',
                label = 'Millésime Exceptionnel',
                chance = 0.2,          -- 📊 0.2% de chance
                description = 'Millésime d\'exception'
            }
        }
    }
}
```

### 🛒 **Système de Commandes**
```lua
Config.BarrelOrders = {
    pricePerBarrel = 1000,            -- 💰 Prix par tonneau vide
    barrelWeight = 5000,              -- ⚖️ Poids d'un tonneau vide
    minGrade = 1,                     -- 📊 Grade minimum requis
}
```

### 📦 **Stashes**
```lua
Config.Stashes = {
    {
        id = 'vigneron_stash',
        name = 'Coffre Principal',
        coords = vector3(-1893.44, 2060.44, 141.09),
        radius = 0.5,
        icon = 'fa-solid fa-box-open',
        iconColor = '#bf0404',
        label = 'Ouvrir Coffre Principal',
        slots = 25,
        weight = 500000
    },
    {
        id = 'vigneron_barrel_stash',
        name = 'Stockage Tonneaux',
        slots = 100,                  -- Plus de slots pour les tonneaux
        weight = 500000,
    },
}
```

---

## 🎮 Utilisation

### 🌾 **Récolte**
1. 🚶 Aller dans une zone de récolte
2. 🎯 Utiliser `ox_target` pour démarrer
3. **Mode Auto** : Attendre et bouger pour arrêter
4. **Mode Manuel** : Cliquer pour chaque récolte

### 🍇 **Fermentation**
1. 🏺 Aller à une cuve individuelle
2. 📥 Déposer les grappes (20-50 blanc / 25-60 rouge)
3. ⏱️ Attendre la fermentation
4. 📤 Récupérer le vin avec un tonneau vide
5. 🔍 Vérifier l'état avec le context menu ox_lib

### 🍾 **Mise en Bouteille**
1. 🍷 Aller aux cuves principales
2. 📦 Avoir des bouteilles vides
3. ⏱️ Attendre la mise en bouteille
4. 🍾 Récupérer les bouteilles avec métadonnées complètes
5. ⭐ Obtenir une qualité aléatoire (avec notifications spéciales)

### 🛒 **Commandes de Tonneaux**
1. 🏢 Aller à l'entreprise
2. 💰 Commander des tonneaux vides (grade requis)
3. 🚚 Aller récupérer la commande
4. 📦 Déposer les tonneaux au vignoble

### 🏪 **Vente**
1. 🍷 Aller aux cuves principales
2. 📤 Déposer les tonneaux de vin
3. 💰 Le vin est automatiquement vendu
4. 💳 L'argent va dans la société ESX

---

## 📊 Base de Données

### 🗄️ **Tables Principales**
- `jks_fermentation_tank` - Cuves individuelles
- `jks_vigneron` - Cuves principales
- `jks_vigneron_limits` - Limites par reboot

### 📋 **Items Requis**

#### **📦 Pour ox_inventory (items.lua)**
```lua
-- Raisins
['red_grapes'] = {
    label = 'Grappes de raisin rouge',
    weight = 1,
    stack = true,
    close = true,
    description = 'De délicieuses grappes de raisin rouge'
},
['white_grapes'] = {
    label = 'Grappes de raisin blanc',
    weight = 1,
    stack = true,
    close = true,
    description = 'De délicieuses grappes de raisin blanc'
},

-- Tonneaux
['tonneaux_vide'] = {
    label = 'Tonneau vide',
    weight = 5,
    stack = true,
    close = true,
    description = 'Un tonneau vide prêt à être rempli'
},
['tonneaux_blanc'] = {
    label = 'Tonneau de vin blanc',
    weight = 5,
    stack = true,
    close = true,
    description = 'Un tonneau rempli de vin blanc'
},
['tonneaux_rouge'] = {
    label = 'Tonneau de vin rouge',
    weight = 5,
    stack = true,
    close = true,
    description = 'Un tonneau rempli de vin rouge'
},

-- Bouteilles
['bouteille_vide'] = {
    label = 'Bouteille vide',
    weight = 1,
    stack = true,
    close = true,
    description = 'Une bouteille vide prête à être remplie'
},
['bouteille_vin_blanc'] = {
    label = 'Bouteille de vin blanc',
    weight = 1,
    stack = true,
    close = true,
    description = 'Une bouteille de vin blanc de qualité'
},
['bouteille_vin_rouge'] = {
    label = 'Bouteille de vin rouge',
    weight = 1,
    stack = true,
    close = true,
    description = 'Une bouteille de vin rouge de qualité'
}
```

---

## 🔧 Personnalisation

### ➕ **Ajouter une Stash**
```lua
-- Dans Config.Stashes
{
    id = 'vigneron_stash_4',
    name = 'Coffre Spécial',
    coords = vector3(x, y, z),
    radius = 0.5,
    icon = 'fa-solid fa-box-open',
    iconColor = '#bf0404',
    label = 'Ouvrir Coffre Spécial',
    slots = 30,
    weight = 600000
}
```

### ➕ **Ajouter une Cuve**
```lua
-- Dans Config.FermentationSettings.individualTanks
{
    id = 4,
    name = "Cuve 4",
    coords = vector3(x, y, z),
    radius = 2.0
}
```

### ➕ **Ajouter une Zone de Récolte**
```lua
-- Dans Config.HarvestZones
{
    id = 'new_grapes',
    name = 'Nouveaux raisins',
    coords = vector3(x, y, z),
    item = 'new_grapes',
    label = 'Nouveaux raisins',
    minAmount = 1,
    maxAmount = 5,
    maxItemsPerReboot = 30,
    icon = 'fa-solid fa-hand-sparkles',
    blipSprite = 85,
    blipColor = 3
}
```

### ➕ **Modifier les Qualités**
```lua
-- Dans Config.Bottling.quality.qualities
{
    name = 'NouvelleQualite',
    label = 'Vin Nouveau',
    chance = 5,                       -- 📊 5% de chance
    description = 'Une nouvelle qualité de vin'
}
```

---

## 🐛 Système de Debug

### 🔧 **Activation du Debug**
```lua
-- Dans Config.General
debug = true  -- Activer le mode debug
```

### 📝 **Fonctions Disponibles**
```lua
-- Debug simple
DebugPrint("Message de debug")

-- Debug avec données
DebugPrint("Message", {data = "valeur"})

-- Debug avec niveaux
DebugLog("ERROR", "Message d'erreur", {error = "détails"})
DebugLog("WARNING", "Message d'avertissement")
DebugLog("INFO", "Message d'information")
DebugLog("VERBOSE", "Message détaillé")

-- Logs spécialisés
LogError("Erreur critique", {context = "détails"})
LogWarning("Avertissement", {context = "détails"})
LogEvent("nom_evenement", {data = "données"})
```

### 🎨 **Niveaux de Debug**
- **ERROR** : Rouge (`^1`) - Erreurs critiques
- **WARNING** : Jaune (`^3`) - Avertissements
- **INFO** : Vert (`^2`) - Informations générales
- **VERBOSE** : Magenta (`^5`) - Détails techniques

---

## 📝 Changelog

### 🆕 **Version 2.6.0**
- ✅ **Système de qualité du vin** avec 5 niveaux réalistes
- ✅ **Métadonnées complètes** sur bouteilles et tonneaux
- ✅ **Mode récolte configurable** (auto/manuel)
- ✅ **Système de debug avancé** avec niveaux et couleurs
- ✅ **Interface ox_lib context menu** pour les cuves
- ✅ **Système de commandes de tonneaux** avec missions
- ✅ **Configuration réorganisée** par groupes logiques
- ✅ **Fonctions utilitaires** centralisées
- ✅ **Logs détaillés** dans tous les fichiers

### 🆕 **Version 2.5.0**
- ✅ Stashes configurables
- ✅ Ajout de stashes multiples
- ✅ Configuration centralisée des coffres
- ✅ Génération automatique des zones d'interaction
- ✅ Système de mise en bouteille
- ✅ Zones de mise en bouteille configurables
- ✅ Support des bouteilles vides et pleines

### 🔄 **Version 2.4.0**
- ✅ Optimisation ESX maximale
- ✅ Remplacement d'ox_lib par ESX.ShowNotification
- ✅ Utilisation d'ESX.TriggerServerCallback
- ✅ Compatibilité ESX améliorée

### 🔧 **Version 2.3.0**
- ✅ Configuration par type de vin
- ✅ Cuves principales séparées

---

<div align="center">

**🍷 Profitez de votre système vigneron avancé ! 🍷**

*Merci d'utiliser ce script et n'hésitez pas à contribuer !*

</div>