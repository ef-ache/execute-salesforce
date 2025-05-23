# execute-salesforce

Un plugin Neovim pour exécuter du code Apex anonyme ou des requêtes SOQL directement depuis votre éditeur.

## Fonctionnalités

- 🚀 Exécution asynchrone (ne bloque pas Neovim)
- 🎨 Coloration syntaxique automatique des résultats (JSON/CSV)
- 🔄 Réutilisation du buffer de résultats
- 🌐 Support multi-org avec sélection interactive
- ⚡ Support des CLI `sf` (nouveau) et `sfdx` (legacy)
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

### Commandes avec sélection d'org

3. **Apex avec choix de l'org** :
   ```vim
   :ExecuteApexOrg
   ```

4. **SOQL avec choix de l'org** :
   ```vim
   :ExecuteSoqlOrg
   ```

### Raccourcis clavier (par défaut)

En mode visuel :
- `<leader>sa` - Exécuter le code Apex sélectionné
- `<leader>sq` - Exécuter la requête SOQL sélectionnée

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
    apex = "<leader>sa",
    soql = "<leader>sq",
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