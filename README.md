# execute-salesforce

Un plugin Neovim pour exécuter du code Apex anonyme ou des requêtes SOQL directement depuis votre éditeur.

## Fonctionnalités

- 🚀 Exécution asynchrone (ne bloque pas Neovim)
- 🎨 Coloration syntaxique automatique des résultats (JSON/CSV)
- 🔄 Réutilisation du buffer de résultats
- 🌐 Support multi-org avec sélection interactive
- ⚡ Support des CLI `sf` (nouveau) et `sfdx` (legacy)
- 📝 Historique persistant avec édition avant exécution
- 🛠️ Configuration flexible
- 🔔 Messages d'erreur clairs et détaillés
- ⌨️ Raccourcis clavier personnalisables

## Prérequis

Installer la CLI Salesforce :
```bash
# Nouvelle CLI (recommandée)
npm install -g @salesforce/cli

# Ou ancienne CLI
npm install -g sfdx-cli
```

Vérifier l'installation :
```bash
sf --version
# ou
sfdx --version
```

## Installation

### Avec [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'ef-ache/execute-salesforce',
  config = function()
    require('execute-salesforce').setup({
      -- Configuration optionnelle
      keymaps = {
        apex = "<leader>sa",
        soql = "<leader>sq",
      }
    })
  end
}
```

### Avec [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'ef-ache/execute-salesforce',
  config = function()
    require('execute-salesforce').setup()
  end
}
```

## Utilisation

### Commandes de base

1. **Exécuter du code Apex** - Sélectionnez le code et exécutez :
   ```vim
   :ExecuteApex
   ```

2. **Exécuter une requête SOQL** - Sélectionnez la requête et exécutez :
   ```vim
   :ExecuteSoql
   ```

### Exécution rapide (sans sélection)

3. **Exécution rapide avec choix du type** :
   ```vim
   :ExecuteQuick
   ```
   Ouvre un prompt pour choisir entre Apex et SOQL, puis un buffer pour saisir le code.

4. **Exécution rapide Apex** :
   ```vim
   :ExecuteQuickApex
   ```
   Ouvre directement un buffer pour saisir du code Apex.

5. **Exécution rapide SOQL** :
   ```vim
   :ExecuteQuickSoql
   ```
   Ouvre directement un buffer pour saisir une requête SOQL.

### Commandes avec sélection d'org

6. **Apex avec choix de l'org** :
   ```vim
   :ExecuteApexOrg
   ```

7. **SOQL avec choix de l'org** :
   ```vim
   :ExecuteSoqlOrg
   ```

### Historique

8. **Interface unifiée pour l'historique** :
   ```vim
   :ExecuteHistory
   ```
   Affiche le nombre d'éléments dans chaque historique et permet de choisir.

9. **Exécuter depuis l'historique Apex** :
   ```vim
   :ExecuteApexHistory
   ```
   - Sélectionnez un élément pour l'exécuter directement
   - Choisissez "Edit then Execute" pour modifier avant l'exécution

10. **Exécuter depuis l'historique SOQL** :
    ```vim
    :ExecuteSoqlHistory
    ```

11. **Gérer l'historique** (voir et supprimer des éléments individuels) :
    ```vim
    :ExecuteManageApexHistory
    :ExecuteManageSoqlHistory
    ```

12. **Effacer tout l'historique** :
   ```vim
   :ExecuteClearApexHistory
   :ExecuteClearSoqlHistory
   ```

L'historique est sauvegardé automatiquement dans `~/.local/share/nvim/execute-salesforce/`.

**Options disponibles dans l'historique :**
- **Execute** : Exécute directement le code/requête
- **Edit then Execute** : Ouvre un buffer pour modifier avant l'exécution
- **Delete from History** : Supprime l'élément de l'historique

### Raccourcis clavier (par défaut)

En mode visuel :
- `<leader>sa` - Exécuter le code Apex sélectionné
- `<leader>sq` - Exécuter la requête SOQL sélectionnée

En mode normal :
- `<leader>sh` - Ouvrir l'interface d'historique
- `<leader>sah` - Historique Apex
- `<leader>sqh` - Historique SOQL
- `<leader>se` - Exécution rapide (choix du type)
- `<leader>sea` - Exécution rapide Apex
- `<leader>seq` - Exécution rapide SOQL

## Configuration

```lua
require('execute-salesforce').setup({
  -- Format de sortie : "json", "csv", ou "table"
  output_format = "json",
  
  -- Direction du split : "vertical", "horizontal", ou "float"
  split_direction = "vertical",
  
  -- Org cible (nil = org par défaut)
  target_org = nil,
  
  -- Réutiliser le buffer de résultats existant
  reuse_buffer = true,
  
  -- Nom du buffer de résultats
  result_buffer_name = "Salesforce Results",
  
  -- Timeout en millisecondes
  timeout = 30000,
  
  -- Raccourcis (false pour désactiver)
  keymaps = {
    apex = "<leader>sa",              -- Mode visuel : exécuter Apex
    soql = "<leader>sq",              -- Mode visuel : exécuter SOQL
    history = "<leader>sh",           -- Mode normal : interface d'historique
    apex_history = "<leader>sah",     -- Mode normal : historique Apex
    soql_history = "<leader>sqh",     -- Mode normal : historique SOQL
    quick = "<leader>se",             -- Mode normal : exécution rapide
    quick_apex = "<leader>sea",       -- Mode normal : exécution rapide Apex
    quick_soql = "<leader>seq",       -- Mode normal : exécution rapide SOQL
  },
  
  -- Afficher un spinner pendant l'exécution
  show_spinner = true,
  
  -- Utiliser 'sf' au lieu de 'sfdx' (recommandé)
  use_sf_cli = true,
})
```

## Exemples

### Apex
```apex
System.debug('Hello World');
List<Account> accounts = [SELECT Id, Name FROM Account LIMIT 5];
for(Account acc : accounts) {
    System.debug(acc.Name);
}
```

### SOQL
```sql
SELECT Id, Name, Email 
FROM Contact 
WHERE LastName = 'Doe' 
LIMIT 10
```

### SOQL multi-lignes
```sql
SELECT 
    Id, 
    Name,
    (SELECT Id, Subject FROM Tasks)
FROM Account
WHERE CreatedDate = TODAY
```

## Fenêtre flottante

Pour utiliser une fenêtre flottante :
```lua
require('execute-salesforce').setup({
  split_direction = "float",
})
```

## Dépannage

### "No Salesforce org connected"
Connectez-vous à une org :
```bash
sf org login web
```

### "Salesforce CLI not found"
Assurez-vous que `sf` ou `sfdx` est dans votre PATH.

## Contribution

Les contributions sont les bienvenues ! N'hésitez pas à ouvrir une issue ou une pull request.

## License

MIT