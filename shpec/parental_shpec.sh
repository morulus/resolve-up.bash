#!/usr/bin/env bash
# shellcheck disable=SC2164
# shellcheck disable=SC1083
shopt -s expand_aliases

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMMAND=$(cd $DIR && cd ../ && realpath ./parental.bash)

# Localize parental (instead of probably existing global command)
parental() {
  if eval "$COMMAND" "$@"; then
    return 0
  else
    return 1
  fi
}

parentalGreedy() {
  parental -g "$@"
}

alias parental=parental
alias parental -g=parentalGreedy

ROOT=/tmp/parental.shpec
rm -rf $ROOT

mkdir -p $ROOT/Work/projects/era/{node_modules,src/styles}
touch $ROOT/Work/projects/era/.npmrc
touch $ROOT/Work/{.npmrc,.eslintrc,.stylelintrc}

evalSuccess() {
  local xxx;
  if xxx=$($@); then
    echo true
  else
    echo false
  fi
}

endsWith() {
  if [[ "$1" == *$2* ]]
  then
      echo true
  else
      echo false
  fi
}

ABSROOT=$(cd "$ROOT" && pwd)
echo "Root: $ABSROOT"
stdout=""
describe 'noglob parental'
  describe 'parental'
    it 'parental empty string'
      cd $ROOT
      stdout=$(parental)
      assert equal "$stdout" "parental:  not found"
      assert equal $(evalSuccess "parental") false
    end
    it 'parental unexisten path'
      cd $ROOT
      stdout=$(parental undefined/path)
      assert equal "$stdout" "parental: undefined/path not found"
    end
    it 'parental existen path'
      cd $ROOT/Work/projects/era/
      stdout=$(parental .npmrc)
      assert test $(endsWith "$stdout" "/Work/projects/era/.npmrc")
      assert equal $(evalSuccess "parental .npmrc") true
    end
    it 'parental existen file path'
      cd $ROOT/Work/projects/era/
      stdout=$(parental .npmrc)
      assert test $(endsWith "$stdout" "/Work/projects/era/.npmrc")
    end
    it 'parental existen folder path'
      cd $ROOT/Work/projects/era/
      stdout=$(parental era)
      assert test $(endsWith "$stdout" "/Work/projects/era")
    end
    it 'parental existen folder/file path'
      cd $ROOT/Work/projects/era/
      stdout=$(parental Work/.npmrc)
      assert test $(endsWith "$stdout" "Work/.npmrc")
    end
    it 'parental existen folder, unexisten file path'
      cd $ROOT/Work/projects/era/
      stdout=$(parental Work/.npmrc2)
      assert test $(endsWith "$stdout" "parental: Work/.npmrc2 not found")
      assert equal $(evalSuccess "parental Work/.npmrc2") false
    end
    it 'parental unexisten path with one symbol'
      cd $ROOT
      stdout=$(parental x)
      assert equal "$stdout" "parental: x not found"
    end
  end

  describe 'parental -g'
    it 'greedy parental'
      cd $ROOT/Work/projects/era/
      stdout=($(parental -g .npmrc))
      assert test $(endsWith "${stdout[0]}" "/Work/projects/era/.npmrc")
      assert test $(endsWith "${stdout[1]}" "/Work/.npmrc")
    end
  end

  describe 'glob'
    describe 'parental'
      cd $ROOT/Work/projects/
      local stdout
      stdout=$(parental '.*rc')
      stdout=($stdout[@])
      assert equal "${#stdout[@]}" "3"
      assert test ${endsWith "${stdout[0]}" "Work/.eslintrc"}
      assert test ${endsWith "${stdout[0]}" "Work/.npmrc"}
      assert test ${endsWith "${stdout[0]}" "Work/.stylelintrc"}
    end
  end
end
