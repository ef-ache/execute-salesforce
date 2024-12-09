# execute-salesforce

A nvim package to execute anonymous apex or soql

# Votre Plugin Neovim

Ce plugin permet d'exécuter du code Apex directement depuis Neovim.

## Installation

Utilisez Lazy.nvim pour installer ce plugin.

```lua
-- Exemple de configuration avec Lazy.nvim
use {
  'F-Hameau/execute-salesforce',
  cmd = 'ExecuteApex', -- Charger à la commande `:ExécuterApex`
  config = function()
    require('./lua/apex').setup()  -- Optionnel si vous avez une fonction de setup
  end,
}

```
