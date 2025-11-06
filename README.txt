# ⚙️ AutoCrafter - Mod Luanti / Minetest

**AutoCrafter** est un mod pour Minetest / Luanti qui ajoute un système de fabrication automatique configurable et administrable.  
Il introduit deux nouveaux blocs :  
- 🧱 **AutoCrafter** (table de craft automatique)  
- 🪨 **CrafterChest** (coffre d'entrée pour les ressources)

---

## 📦 Fonctionnalités

- Crée automatiquement n’importe quel objet du jeu à partir de ressources.
- Interface simple pour choisir la recette et activer/désactiver le craft.
- Les items produits sont déposés dans un coffre de sortie.
- Un système d’administration complet permet de :
  - Voir tous les AutoCrafters actifs et leur propriétaire.
  - Désactiver ou réactiver un AutoCrafter à distance.
  - Scanner un bloc pour afficher ses informations.

---

## 🛠️ Crafting Recipe

Pour créer un **AutoCrafter**, utilisez la recette suivante :

🧩 Ce craft donne **1 AutoCrafter + 1 CrafterChest**

---

## 💬 Commandes

| Commande | Accès | Description |
|-----------|--------|-------------|
| `/crafthelp` | Tous | Affiche l’aide et les instructions du mod |
| `/craft` | Tous | Donne l’objet "Scanner" (outil d’information) |
| `/Crafter` | Admin | Ouvre l’interface de gestion de tous les AutoCrafters |
| `/crafter_disable` | Admin | Désactive le dernier AutoCrafter scanné |
| `/crafter_enable` | Admin | Réactive le dernier AutoCrafter scanné |

---

## 🔍 Scanner Admin

L’outil **Scanner** permet de cliquer sur un AutoCrafter pour :
- Voir son propriétaire 👤  
- Obtenir sa position 📍  
- Vérifier son état ⚙️  
- Et ensuite le **désactiver** ou **réactiver** avec `/crafter_disable` et `/crafter_enable`

---

## 💾 Sauvegarde

Les données des AutoCrafters (propriétaires, états, positions, désactivations, etc.) sont sauvegardées automatiquement et restaurées au redémarrage du serveur.

---

## 📁 Installation

1. Télécharge le mod et place-le dans ton dossier :
2. Active le mod dans ton monde via le menu ou `world.mt`
3. Démarre le serveur ou le jeu
4. Utilise `/crafthelp` pour afficher les instructions

---

## 🧑‍💻 Compatibilité

- ✅ Compatible avec **Minetest 5.8+** et **Luanti**
- ✅ Multijoueur supporté
- ⚙️ Nécessite les mods de base (`default`, `inventory_plus` facultatif)

---

## 📜 Licence

Code : [MIT License](./LICENSE)  
Textures : Créées par [Ton Nom ou Pseudo] — sous licence **CC-BY-SA 4.0**

---

## 💡 Auteur

Créé par **[Ton Nom ou Pseudo]**  
📅 Version : 1.0  
📂 Nom du dossier : `autocrafter`

---

### ❤️ Merci d’utiliser AutoCrafter !
Si tu aimes ce mod, n’hésite pas à le partager ou à le publier sur ContentDB !