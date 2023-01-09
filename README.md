## Frozen Magisk app

Automatically freeze Magisk app and open automatically when you open key app (Settings app). Proc Monitor v2.1+ is required for this module to work.

### How to use
1. Magisk app must be repackaged through "Hide Magisk app" optio 
2. After "Hide Magisk app" step, open Settings app for the first time
3. Magisk app automatically unfreeze and open when you open Settings app
4. Magisk app automatically freeze when you close Magisk app

### Key processes list
- The default key process to open Magisk app is `com.android.settings` (Settings app), you can change the key process in `key.txt`

### Uninstall
- Before uninstalling this module, please un-hide Magisk app to original package first!!!