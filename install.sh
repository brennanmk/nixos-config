#!/usr/bin/env bash

init() {
    # Vars
    CURRENT_USERNAME='brennan'

    # Colors
    NORMAL=$(tput sgr0)
    WHITE=$(tput setaf 7)
    BLACK=$(tput setaf 0)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    MAGENTA=$(tput setaf 5)
    CYAN=$(tput setaf 6)
    BRIGHT=$(tput bold)
    UNDERLINE=$(tput smul)
}

confirm() {
    echo -en "[${GREEN}y${NORMAL}/${RED}n${NORMAL}]: "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        exit 0
    fi
}

print_header() {
    echo -E "$RED 
      ! To make sure everything runs correctly DONT run as root ! $GREEN
                        -> '"./install.sh"' $NORMAL

    "
}

get_username() {
    echo -en "Enter your$GREEN username$NORMAL : $YELLOW"
    read username
    echo -en "$NORMAL"
    echo -en "Use$YELLOW "$username"$NORMAL as ${GREEN}username${NORMAL} ? "
    confirm
}

set_username() {
    sed -i -e "s/${CURRENT_USERNAME}/${username}/g" ./flake.nix
}

get_host() {
    echo -en "Choose a ${GREEN}host${NORMAL}, either [${YELLOW}D${NORMAL}]esktop or [${YELLOW}L${NORMAL}]aptop: "
    read -n 1 -r
    echo

    if [[ $REPLY =~ ^[Dd]$ ]]; then
        HOST='desktop'
    elif [[ $REPLY =~ ^[Ll]$ ]]; then
        HOST='laptop'
    else
        echo "Invalid choice. Please select either 'D' for desktop or 'L' for laptop."
        exit 1
    fi

    echo -en "$NORMAL"
    echo -en "Use the$YELLOW "$HOST"$NORMAL ${GREEN}host${NORMAL} ? "
    confirm
}

install_desktop() {
    echo -e "\n${RED}START INSTALL PHASE${NORMAL}\n"
    sleep 0.2

    # Create basic directories
    echo -e "Creating folders:"
    echo -e "    - ${MAGENTA}~/Music${NORMAL}"
    echo -e "    - ${MAGENTA}~/Documents${NORMAL}"
    echo -e "    - ${MAGENTA}~/Pictures/wallpapers/others${NORMAL}"
    mkdir -p ~/Music
    mkdir -p ~/Documents
    mkdir -p ~/Pictures/wallpapers/others
    sleep 0.2

    echo -e "Copying ${MAGENTA}i3 config${NORMAL}"
    mkdir ~/.config/i3
    cp configs/desktop/i3 ~/.config/i3/config
    sleep 0.2

    echo -e "Copying ${MAGENTA}wallpapers${NORMAL}"
    cp -r wallpapers/desktop/ ~/Pictures/wallpapers/
    sleep 0.2

    echo -e "Installing ${MAGENTA}polybar${NORMAL}"
    git clone --depth=1 https://github.com/adi1090x/polybar-themes.git ~/Downloads/polybar-themes
    chmod +x ~/Downloads/setup.sh
    ~/Downloads/polybar-themes/setup.sh

    echo -e "Copying ${MAGENTA}polybar config${NORMAL}"
    rm ~/.config/polybar/hack/config.ini
    rm ~/.config/polybar/hack/colors.ini
    rm ~/.config/polybar/hack/modules.ini
    rm ~/.config/polybar/hack/user_modules.ini
    rm ~/.config/polybar/hack/scripts/rofi/colors.rasi
    cp configs/desktop/polybar/config.ini ~/.config/polybar/hack/config.ini
    cp configs/desktop/polybar/colors.ini ~/.config/polybar/hack/colors.ini
    cp configs/desktop/polybar/modules.ini ~/.config/polybar/hack/modules.ini
    cp configs/desktop/polybar/user_modules.ini ~/.config/polybar/hack/user_modules.ini
    cp configs/desktop/polybar/colors.rasi ~/.config/polybar/hack/scripts/rofi/colors.rasi
    sleep 0.2

    echo -e "Copying ${MAGENTA}scripts${NORMAL}"
    mkdir ~/.local/bin
    cp scripts/* ~/.local/bin
    sleep 0.2

    echo -e "Copying all ${MAGENTA}doom config${NORMAL}"
    cp -r configs/desktop/doom/ ~/.config/doom
    sleep 0.2

    echo -e "Installing ${MAGENTA}doom${NORMAL}"
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
    rm -rf ~/emacs.d

    # Get the hardware configuration
    echo -e "Copying ${MAGENTA}/etc/nixos/hardware-configuration.nix${NORMAL} to ${MAGENTA}./hosts/${HOST}/${NORMAL}\n"
    cp /etc/nixos/hardware-configuration.nix hosts/${HOST}/hardware-configuration.nix
    sleep 0.2

    # Last Confirmation
    echo -en "You are about to start the system build, do you want to process ? "
    confirm

    # Build the system (flakes + home manager)
    echo -e "\nBuilding the system...\n"
    sudo nixos-rebuild switch --flake .#${HOST}
}

install_laptop() {
    echo -e "\n${RED}START INSTALL PHASE${NORMAL}\n"
    sleep 0.2

    # Create basic directories
    echo -e "Creating folders:"
    echo -e "    - ${MAGENTA}~/Music${NORMAL}"
    echo -e "    - ${MAGENTA}~/Documents${NORMAL}"
    echo -e "    - ${MAGENTA}~/Pictures/wallpapers/others${NORMAL}"
    mkdir -p ~/Music
    mkdir -p ~/Documents
    mkdir -p ~/Pictures/wallpapers/others
    sleep 0.2

    echo -e "Copying ${MAGENTA}i3 config${NORMAL}"
    mkdir ~/.config/i3
    cp configs/laptop/i3 ~/.config/i3/config
    sleep 0.2

    echo -e "Copying ${MAGENTA}wallpapers${NORMAL}"
    cp -r wallpapers/laptop/ ~/Pictures/wallpapers/
    sleep 0.2

    echo -e "Installing ${MAGENTA}polybar${NORMAL}"
    git clone --depth=1 https://github.com/adi1090x/polybar-themes.git ~/Downloads/polybar-themes
    chmod +x ~/Downloads/setup.sh
    ~/Downloads/polybar-themes/setup.sh

    echo -e "Copying ${MAGENTA}polybar config${NORMAL}"
    rm ~/.config/polybar/hack/config.ini
    rm ~/.config/polybar/hack/colors.ini
    rm ~/.config/polybar/hack/modules.ini
    rm ~/.config/polybar/hack/user_modules.ini
    rm ~/.config/polybar/hack/scripts/rofi/colors.rasi
    cp configs/laptop/polybar/config.ini ~/.config/polybar/hack/config.ini
    cp configs/laptop/polybar/colors.ini ~/.config/polybar/hack/colors.ini
    cp configs/laptop/polybar/modules.ini ~/.config/polybar/hack/modules.ini
    cp configs/laptop/polybar/user_modules.ini ~/.config/polybar/hack/user_modules.ini
    cp configs/laptop/polybar/colors.rasi ~/.config/polybar/hack/scripts/rofi/colors.rasi
    sleep 0.2

    echo -e "Copying ${MAGENTA}scripts${NORMAL}"
    mkdir ~/.local/bin
    cp scripts/* ~/.local/bin
    sleep 0.2

    echo -e "Copying all ${MAGENTA}doom config${NORMAL}"
    cp -r configs/laptop/doom/ ~/.config/doom
    sleep 0.2

    echo -e "Installing ${MAGENTA}doom${NORMAL}"
    git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
    ~/.config/emacs/bin/doom install
    rm -rf ~/emacs.d

    # Get the hardware configuration
    echo -e "Copying ${MAGENTA}/etc/nixos/hardware-configuration.nix${NORMAL} to ${MAGENTA}./hosts/${HOST}/${NORMAL}\n"
    cp /etc/nixos/hardware-configuration.nix hosts/${HOST}/hardware-configuration.nix
    sleep 0.2

    # Last Confirmation
    echo -en "You are about to start the system build, do you want to process ? "
    confirm

    # Build the system (flakes + home manager)
    echo -e "\nBuilding the system...\n"
    sudo nixos-rebuild switch --flake .#${HOST}
}

main() {
    init

    print_header

    get_username
    set_username
    get_host

    if [[ "$HOST" == "laptop" ]]; then
       install_laptop
    elif [host == 'desktop']; then
        install_desktop
    fi
}

main && exit 0
