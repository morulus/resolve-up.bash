#!/usr/bin/env bash
# shellcheck disable=SC2164
# shellcheck disable=SC1083
shopt -s expand_aliases

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
COMMAND=$(cd $DIR && cd ../ && realpath ./resolve-up.bash)

# Localize resolve-up (instead of probably existing global command)
resolve-up() {
  if eval "$COMMAND" "$@"; then
    return 0
  else
    return 1
  fi
}

resolve-upGreedy() {
  resolve-up -g "$@"
}

alias resolve-up=resolve-up
alias resolve-up -g=resolve-upGreedy

ROOT=/tmp/resolve-up.shpec
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
describe 'noglob resolve-up'
  describe 'resolve-up'
    it 'resolve-up empty string'
      cd $ROOT
      stdout=$(resolve-up)
      assert equal "$stdout" "resolve-up:  not found"
      assert equal $(evalSuccess "resolve-up") false
    end
    it 'resolve-up unexisten path'
      cd $ROOT
      stdout=$(resolve-up undefined/path)
      assert equal "$stdout" "resolve-up: undefined/path not found"
    end
    it 'resolve-up existen path'
      cd $ROOT/Work/projects/era/
      stdout=$(resolve-up .npmrc)
      assert test $(endsWith "$stdout" "/Work/projects/era/.npmrc")
      assert equal $(evalSuccess "resolve-up .npmrc") true
    end
    it 'resolve-up existen file path'
      cd $ROOT/Work/projects/era/
      stdout=$(resolve-up .npmrc)
      assert test $(endsWith "$stdout" "/Work/projects/era/.npmrc")
    end
    it 'resolve-up existen folder path'
      cd $ROOT/Work/projects/era/
      stdout=$(resolve-up era)
      assert test $(endsWith "$stdout" "/Work/projects/era")
    end
    it 'resolve-up existen folder/file path'
      cd $ROOT/Work/projects/era/
      stdout=$(resolve-up Work/.npmrc)
      assert test $(endsWith "$stdout" "Work/.npmrc")
    end
    it 'resolve-up existen folder, unexisten file path'
      cd $ROOT/Work/projects/era/
      stdout=$(resolve-up Work/.npmrc2)
      assert test $(endsWith "$stdout" "resolve-up: Work/.npmrc2 not found")
      assert equal $(evalSuccess "resolve-up Work/.npmrc2") false
    end
    it 'resolve-up unexisten path with one symbol'
      cd $ROOT
      stdout=$(resolve-up x)
      assert equal "$stdout" "resolve-up: x not found"
    end
  end

  describe 'resolve-up -g'
    it 'greedy resolve-up'
      cd $ROOT/Work/projects/era/
      stdout=($(resolve-up -g .npmrc))
      assert test $(endsWith "${stdout[0]}" "/Work/projects/era/.npmrc")
      assert test $(endsWith "${stdout[1]}" "/Work/.npmrc")
    end
  end

  describe 'glob'
    describe 'resolve-up'
      cd $ROOT/Work/projects/
      local stdout
      stdout=$(resolve-up '.*rc')
      stdout=($stdout[@])
      assert equal "${#stdout[@]}" "3"
      assert test $(endsWith "${stdout[0]}" "Work/.eslintrc")
      assert test $(endsWith "${stdout[1]}" "Work/.npmrc")
      assert test $(endsWith "${stdout[2]}" "Work/.stylelintrc")
    end
  end
end
