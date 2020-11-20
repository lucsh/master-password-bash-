#!/usr/bin/env bash

REDACTED='\033[1;107;97m'
NC='\033[0m'

header_flag=true
pass_input=""
len=15
use_symbols=true
use_caps=true

while test $# -gt 0; do
  case "$1" in
    -z|--header)
      header_flag=true
      shift
      ;;
  	-s|--seed)
	shift
	    if  [[ $1 == "-p" ]] ; then
        echo "no seed was specified"
        exit 1
      fi
      if test $# -gt 0; then
        export seed_input=$1
      else
        echo "no seed was specified"
        exit 1
      fi
      shift
      ;;
    -p|--pass)
	shift
      if test $# -gt 0; then
        export pass_input=$1
      fi
      shift
      ;;
    -l|--length)
	shift
      if test $# -gt 0; then
        export len=$1
      fi
      shift
      ;;
   -c|--captitals)
      use_caps=false
      shift
      ;;
    -e|--symbols)
      use_symbols=false
      shift
      ;;
    *)

      break
      ;;
  esac
done
shopt -s expand_aliases
if [[ ${header_flag} = true ]]; then
echo ""
echo ""
echo "    ███████╗██████╗  ██████╗"
echo "    ██╔════╝██╔══██╗██╔════╝ "
echo "    ███████╗██████╔╝██║  ███╗"
echo "    ╚════██║██╔═══╝ ██║   ██║"
echo "    ███████║██║     ╚██████╔╝"
echo "    ╚══════╝╚═╝      ╚═════╝"
echo ""
echo "  repo:   https://github.com/lucsh/master-password-bash"
echo "  web:    https://pass.luc.sh"
echo "  author: https://luc.sh"
echo ""
echo ""
fi

if sha256sum 2>/dev/null ; then
  echo "using sha256sum"
else
  alias sha256sum='shasum --algorithm 256'
fi

if [[ $seed_input == "" ]]; then
    echo -n Seed:
    read -r seed_input
    echo
fi

if [[ $pass_input == "" ]]; then
    echo -n Password:
    read -r -s pass_input
    echo
fi

prepass=$(echo -n "$seed_input""$pass_input" | sha256sum)
if [[ ${use_symbols} = true ]]; then
vowels=( $(echo $prepass | grep -o '[aeiou]') )

syms="{!#$%&()*+,-./:;<=>?@[{}]^_|~}"

symsLen=${#syms}
vowelsLen=${#vowels[@]}

r=$(((vowelsLen*symsLen+100/2)/100))
prepass=${prepass:0:len/3}${syms:r:1}${prepass:len/3:len/3}${syms:r+2:1}${prepass:len/3*2:len/3}
fi
if [[ ${use_caps} = true ]]; then

midddle=${prepass:len/3:len/3}
capped=$(echo "$midddle" | tr '[:lower:]' '[:upper:]')
prepass=${prepass:0:len/3}${capped}${prepass:len/3*2:len/3}
fi

prepass=${prepass:0:len}
cancopy=$(command -v pbcopya 2>/dev/null)
if  $cancopy ; then
    echo -n "$prepass" | pbcopy
fi

echo -e "${REDACTED}$prepass${NC}"
