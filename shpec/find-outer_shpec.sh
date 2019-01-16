#!/usr/bin/env bash
# shellcheck disable=SC2164
# shellcheck disable=SC1083
shopt -s expand_aliases

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMMAND=$(cd $DIR && cd ../ && realpath ./find-outer.bash)

# Localize find-outer (instead of probably existing global command)
find-outer() {
  if eval "$COMMAND" "$@"; then
    return 0
  else
    return 1
  fi
}

find-outerGreedy() {
  find-outer -g "$@"
}

alias find-outer=find-outer
alias find-outer -g=find-outerGreedy

ROOT=/tmp/find-outer.shpec
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
describe 'noglob find-outer'
  describe 'find-outer'
    it 'find-outer empty string'
      cd $ROOT
      stdout=$(find-outer)
      assert equal "$stdout" "find-outer:  not found"
      assert equal $(evalSuccess "find-outer") false
    end
    it 'find-outer unexisten path'
      cd $ROOT
      stdout=$(find-outer undefined/path)
      assert equal "$stdout" "find-outer: undefined/path not found"
    end
    it 'find-outer existen path'
      cd $ROOT/Work/projects/era/
      stdout=$(find-outer .npmrc)
      assert test $(endsWith "$stdout" "/Work/projects/era/.npmrc")
      assert equal $(evalSuccess "find-outer .npmrc") true
    end
    it 'find-outer existen file path'
      cd $ROOT/Work/projects/era/
      stdout=$(find-outer .npmrc)
      assert test $(endsWith "$stdout" "/Work/projects/era/.npmrc")
    end
    it 'find-outer existen folder path'
      cd $ROOT/Work/projects/era/
      stdout=$(find-outer era)
      assert test $(endsWith "$stdout" "/Work/projects/era")
    end
    it 'find-outer existen folder/file path'
      cd $ROOT/Work/projects/era/
      stdout=$(find-outer Work/.npmrc)
      assert test $(endsWith "$stdout" "Work/.npmrc")
    end
    it 'find-outer existen folder, unexisten file path'
      cd $ROOT/Work/projects/era/
      stdout=$(find-outer Work/.npmrc2)
      assert test $(endsWith "$stdout" "find-outer: Work/.npmrc2 not found")
      assert equal $(evalSuccess "find-outer Work/.npmrc2") false
    end
    it 'find-outer unexisten path with one symbol'
      cd $ROOT
      stdout=$(find-outer x)
      assert equal "$stdout" "find-outer: x not found"
    end
  end

  describe 'find-outer -g'
    it 'greedy find-outer'
      cd $ROOT/Work/projects/era/
      stdout=($(find-outer -g .npmrc))
      assert test $(endsWith "${stdout[0]}" "/Work/projects/era/.npmrc")
      assert test $(endsWith "${stdout[1]}" "/Work/.npmrc")
    end
  end

  describe 'glob'
    describe 'find-outer'
      cd $ROOT/Work/projects/
      local stdout
      stdout=$(find-outer '.*rc')
      stdout=($stdout[@])
      assert equal "${#stdout[@]}" "3"
      assert test ${endsWith "${stdout[0]}" "Work/.eslintrc"}
      assert test ${endsWith "${stdout[0]}" "Work/.npmrc"}
      assert test ${endsWith "${stdout[0]}" "Work/.stylelintrc"}
    end
  end
end
