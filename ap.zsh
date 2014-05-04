function _ap_usage() {
  echo "ap - version 1.0
  Usage:
    ap install [package]+       install a package with pacman
    ap remove [package]+        remove a package, its dependencies and packages
                                that depends from it
    ap compinst [package]       compile and install from aur, keep packages in
                                ~/pkg
    ap search [keyword]+        search in pacman and aur
    ap update                   system update
    ap info [package]+          show informations about a package
    ap bin [package]+           list files installed by package in a /bin/
                                directory
    ap own [file or executable] tell which package own a file or an executable in path
    ap localinstall [file]+     install a package from file .pkg.tar.xz
    ap ls [package]+            list files in package
    ap clean                    clean the package cache
    "
}

function ap() {
  local command=$1
  case $command in
    (update)
      sudo pacman -Scc --noconfirm --color=always
      sudo reflector \
        --sort rate \
        --age 6 \
        --latest 5 \
        --protocol http \
        --save /etc/pacman.d/mirrorlist
      echo 'Server = http://delta.archlinux.fr/$repo/os/$arch' | \
        cat - /etc/pacman.d/mirrorlist | sudo tee /etc/pacman.d/mirrorlist >/dev/null
      grep -v '#' /etc/pacman.d/mirrorlist
      curl -s https://www.archlinux.org/feeds/news/ \
        | xmllint --xpath //item/title\ \|\ //item/pubDate /dev/stdin \
        | sed -r -e 's:<title>([^<]*?)</title><pubDate>([^<]*?)</pubDate>:\2\t\1\n:g'
      sudo pacman -Syu --color=always
      cower -v -u -c
      ;;
    (install)
      sudo pacman -S --color=always ${*:2}
      ;;
    (compinst)
      mkdir -p ~/pkg
      pushd ~/pkg
      package=$2
      cower -d $package
      cd $package
      makepkg -csi
      cd ..
      rm -rf $package
      popd
      ;;
    (remove)
      sudo pacman -Rcsn --color=always ${*:2}
      ;;
    (search)
      pacman -Ss --color=always ${*:2}
      cower -sc ${*:2}
      ;;
    (info)
      package=$2
      pacman -Si --color=always $package
      if [[ $? = 1 ]] then
        cower -ic $package
      fi
      ;;
    (bin)
      pacman -Qql ${*:2} | grep /bin/ | egrep -v '/bin/$'
      ;;
    (own)
      pacman -Qo ${*:2}
      ;;
    (localinstall)
      sudo pacman -U ${*:2}
      ;;
    (ls)
      pacman -Ql ${*:2}
      ;;
    (clean)
      pacman -Scc
      ;;
    (help|-h|--help|*)
      _ap_usage
      ;;
  esac
}

function _ap_path_completion () {
  for pathvar in $(echo $PATH | tr : ' ') ; do
    find $pathvar -maxdepth 1 -executable -name "$1*" -not -type d -print 2>/dev/null | \
      cut -c $(( ${#pathvar} + 2 ))-
  done
  unset pathvar
}

function _ap_completion () {
  local commandline
  read -l commandline
  local words
  words=($(echo $commandline))
  local command=${words[2]}
  case $command in
    (remove|bin|ls)
      reply=($(pacman -Qqs $1))
      ;;
    (install)
      reply=($(pacman -Sqs $1))
      ;;
    (compinst)
      reply=($(cower -sq $1))
      ;;
    (search|info)
      reply=($(pacman -Sqs $1 | xargs ; cower -sq $1 | xargs))
      ;;
    (own)
      reply=($(find . -maxdepth 1 -type f -name "$1*" -print | cut -c 3- ; \
        _ap_path_completion "$1" ))
      ;;
    (localinstall)
      reply=($(find . -maxdepth 1 -type f -iname \*.pkg.tar.xz -print | cut -c 3-))
      ;;
    (*)
      reply=(update install compinst remove search info bin localinstall ls clean)
      ;;
  esac
}

compctl -K _ap_completion ap
