### ap - ArchLinux PackageManager ###

small shell utility written in zsh, with autocompletion, that wrap pacman and
cower.

Ensure that zsh completion is loaded in your .zshrc, then load ap with

    source ~/.zsh/ap.zsh

in your rc.

Usage:

```
    ap install [package]+       install a package with pacman
    ap remove [package]+        remove a package, its dependencies and packages
                                that depends from it
    ap download [package]       download package from aur in ~/pkg/ ; cd in directory
    ap aurinstall [package]+    install package from aur
    ap search [keyword]+        search in pacman and aur
    ap update                   system update
    ap info [package]+          show informations about a package
    ap bin [package]+           list files installed by package in a /bin/
                                directory
    ap own [file or executable] tell which package own a file or an executable in path
    ap localinstall [file]+     install a package from file .pkg.tar.xz
    ap ls [package]+            list files in package
    ap clean                    clean the package cache
    ap bootstrap                install needed helpers (cower, pacaur, powerpill)
```
`
