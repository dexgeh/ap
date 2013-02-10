function _ap_usage() {
  echo "ap - version 1.0
  Usage:
    ap install [package]+ (install a package with pacman)
    ap remove [package]+  (remove a package, its dependencies and package that depends from it)
    ap compinst [package] (compile + install from aur)
    ap search [keyword]+  (search in pacman and aur)
    ap update             (system update)
    ap bin [package]+      (list files installed by package in a /bin/ directory)
    "
}

function ap() {
  local command=$1
  case $command in
    (update)
      sudo pacman -Scc --noconfirm
      sudo reflector \
        --sort rate \
        --age 6 \
        --latest 5 \
        --protocol http \
        --save /etc/pacman.d/mirrorlist
      curl -s https://www.archlinux.org/feeds/news/ \
        | xmllint --xpath //item/title\ \|\ //item/pubDate /dev/stdin \
        | sed -r -e 's:<title>([^<]*?)</title><pubDate>([^<]*?)</pubDate>:\2\t\1\n:g'
      sudo pacman -Syu
      cower -v -u
      ;;
    (install)
      sudo pacman -S ${*:2}
      ;;
    (compinst)
      package=$2
      cower -d $package
      cd $package
      makepkg -csi
      cd ..
      rm -rf $package
      ;;
    (remove)
      sudo pacman -Rcsn ${*:2}
      ;;
    (search)
      pacman -Ss ${*:2}
      cower -s ${*:2}
      ;;
    (info)
      package=$2
      pacman -Si $package
      if [[ $? = 1 ]] then
        cower -si $package
      fi
      ;;
    (bin)
      pacman -Qql ${*:2} | grep /bin/ | egrep -v '/bin/$'
      ;;
    (-h|--help|*)
      _ap_usage
      ;;
  esac
}

function _ap_completion () {
  local commandline
  read -l commandline
  local words
  words=($(echo $commandline))
  local command=${words[2]}
  case $command in
    (remove|bin)
      reply=($(pacman -Qqs $1))
      ;;
    (install)
      reply=($(pacman -Sqs $1))
      ;;
    (compinst)
      reply=($(cower -sq $1))
      ;;
    (search)
      reply=($(pacman -Sqs $1 | xargs ; cower -sq $1 | xargs))
      ;;
    (info)
      reply=($(pacman -Sqs $1 | xargs ; cower -sq $1 | xargs))
      ;;
    (*)
      reply=(update install compinst remove search info bin)
      ;;
  esac
}

compctl -K _ap_completion ap
