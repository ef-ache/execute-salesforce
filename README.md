# execute-salesforce

Un plugin Neovim pour exécuter du code Apex anonyme ou des requêtes SOQL.

## Installation de la CLI Salesforce DX

Pour utiliser ce plugin, vous devez d'abord installer la CLI Salesforce DX (sfdx). Suivez les étapes ci-dessous :

1. Téléchargez et installez la CLI Salesforce DX depuis [le site officiel](https://developer.salesforce.com/tools/sfdxcli).
2. Vérifiez l'installation en exécutant `sfdx --version` dans votre terminal.

## Installation du Plugin

Utilisez Lazy.nvim pour installer ce plugin. Voici un exemple de configuration :

```lua
-- Exemple de configuration avec Lazy.nvim
use {
  'F-Hameau/execute-salesforce',
}
```

## Utilisation

### Exécuter du code Apex

Pour exécuter du code Apex anonyme, sélectionnez les lignes de code dans Neovim et utilisez la commande suivante :

```
:ExecuteApex
```

### Exécuter une requête SOQL

Pour exécuter une requête SOQL, sélectionnez les lignes de la requête dans Neovim et utilisez la commande suivante :

```
:ExecuteSoql
```
