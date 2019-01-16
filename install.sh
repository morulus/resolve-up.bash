#!/usr/bin/env bash
POSITIONAL=()
ARGUMENTS=""
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -f|--force)
    FORCE=true
    shift; # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done

# Copy to the home directory if we are not inside home directory
CURERNTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
TARGETDIST="$HOME/.find-outer.bash"
TARGETSIM='/usr/local/bin/find-outer'
HL='\033[1;33m' # Yellow
ER='\033[0;31m' # Red
NC='\033[0m' # No Color
CHECKED="${HL}\xE2\x9C\x94${NC}"

# TOOLS
goSleep() {
    if ! [ $FORCE ]; then
        sleep 0.025
    fi
}

dotEffect() {
   printf "."
   goSleep
}

doneEffect() {
    printf " $CHECKED\n"
}

cancel() {
    printf "${ER}Installation cancelled.${NC}\n"
}

fatalError() {
    printf "\n${ER}$1${NC}\n"
    cancel
    exit 1
}


# TASKS
cleanTargetDist() {
    # If ~/.find-outer.bash already exists we should remove it
    dotEffect
    rm -r "$TARGETDIST"
    mkdir "$TARGETDIST"
    dotEffect
}

cleanCommand() {
    dotEffect
    rm -rf "$TARGETSIM"
    dotEffect
}

copyDist() {
    dotEffect
    cp -R "$CURERNTDIR/." "$HOME/.find-outer.bash"
    dotEffect
}

linkCommand() {
    dotEffect
    cp "$TARGETDIST/find-outer.bash" $TARGETSIM
    dotEffect
}

patchBashrc() {
    local hide

    # Check for bashrc exists
    if ! [ -f "$HOME/.bashrc" ] || ! [ -w "$HOME/.bashrc" ]; then
        fatalError "Installer expects ~/.bashrc exists and writable."
    fi
    dotEffect
    if ! hide=$(grep -R "source ~/.find-outer.bash/find-outer-initialize.sh" "$HOME/.bashrc")
    then
        printf '\n\n'$"# Initialize find-outer.bash" >> "$HOME/.bashrc"
        printf "\nsource ~/.find-outer.bash/find-outer-initialize.sh" >> "$HOME/.bashrc"
        dotEffect
    fi
    dotEffect
}

NEEDS_CLEAN_TARGETDIST=false
NEEDS_CLEAN_COMMAND=false
NEEDS_COPY_DIST=false

# Ensure that distribution folder located in ~/.find-outer.bash
if ! [ "$CURERNTDIR" = "$TARGETDIST" ]; then
    NEEDS_COPY_DIST=true
    if [ -d "$TARGETDIST" ]; then
        NEEDS_CLEAN_TARGETDIST=true
    fi
else
    echo "Distribution location: $CURERNTDIR"
fi

if [ -L "$TARGETSIM" ] || [ -f "$TARGETSIM" ] || [ -d "$TARGETSIM" ]; then
    if ! [ $FORCE ]; then
        clear
        printf "Seems like command ${HL}find-outer${NC} already exists in ${HL}$TARGETSIM${NC}. This program requires that name.\n"
        read -p "Override it?  (y/n)" -n 1 -r
        echo ""
    fi
    if [ $FORCE ] || [[ $REPLY =~ ^[Yy]$ ]]; then
        NEEDS_CLEAN_COMMAND=true
    else
        cancel
        exit 0;
    fi
fi

# Install:
clear
## Intro:
printf "Install ${HL}find-outer.bash${NC} to your machine:\n"

## Cleaning:
printf "Cleaning"
dotEffect
if [ $NEEDS_CLEAN_TARGETDIST = true ]; then
    cleanTargetDist
fi

if [ $NEEDS_CLEAN_COMMAND = true ]; then
    cleanCommand
fi
doneEffect
## done;

## Copy:
printf "Copying"
dotEffect
if [ $NEEDS_COPY_DIST = true ]; then
    copyDist
fi
linkCommand
patchBashrc
doneEffect
## done;

printf "Successful installed"
doneEffect

# Postinstall:
sh "$HOME/.bashrc"
printf "\n"
printf "Command ${HL}find-outer${NC} now aviable in your CLI\n"
printf "\n"
