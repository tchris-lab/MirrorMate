#!/bin/bash
clear

# =====================================================
#  MirrorMate - Dynamic Open Source Mirror Switcher
#  github: https://github.com/free-programmers/MirrorMate   
# =====================================================

cat <<'EOF'
/*
  _____                                                             
 |  ___| __ ___  ___                                                
 | |_ | '__/ _ \/ _ \                                               
 |  _|| | |  __/  __/                                               
 |_|__|_|  \___|\___|                                               
 |  _ \ _ __ ___   __ _ _ __ __ _ _ __ ___  _ __ ___   ___ _ __ ___ 
 | |_) | '__/ _ \ / _` | '__/ _` | '_ ` _ \| '_ ` _ \ / _ \ '__/ __|
 |  __/| | | (_) | (_| | | | (_| | | | | | | | | | | |  __/ |  \__ \
 |_|__ |_|  \___/ \__, |_|  \__,_|_| |_| |_|_| |_| |_|\___|_|  |___/
  / _ \ _ __ __ _ |___/                                             
 | | | | '__/ _` |                                                  
 | |_| | | | (_| |                                                  
  \___/|_|  \__, |                                                  
            |___/                                                  
github: https://github.com/free-programmers/MirrorMate                                 
*/
EOF

sleep 2

if [[ $EUID -ne 0 ]]; then
   echo "❌ Please run with sudo"
   exit 1
fi

BACKUP_DIR="$HOME/.mirror_backup"
mkdir -p "$BACKUP_DIR"

if ! command -v whiptail &>/dev/null; then
    echo "Installing whiptail..."
    sleep 1
    apt-get update && apt-get install -y whiptail
fi

# =====================================================
# Mirror list
# Format: category|display name|mirror URL
# =====================================================
MIRRORS=(
    # Python
    "Python|PyPI - Runflare (Iran)|https://mirror-pypi.runflare.com/simple"
    "Python|PyPI - Mecan (AhmadRafiee)(Iran)|https://repo.mecan.ir/repository/pypi/"
    "Python|PyPI - Tsinghua (China)|https://pypi.tuna.tsinghua.edu.cn/simple"
    "Python|PyPI - Aliyun (China)|https://mirrors.aliyun.com/pypi/simple/"

    # Node.js
    "Node.js|NPM - RunFlare (Iran)|https://mirror-npm.runflare.com"
    "Node.js|NPM - Tsinghua (China)|https://registry.npmmirror.com"
    "Node.js|NPM - Aliyun (China)|https://registry.npm.taobao.org"

    # Docker
    "Docker|Docker Hub - Runflare (Iran)|https://mirror-docker.runflare.com"
    "Docker|Docker Hub - ArvanCloud (Iran)|https://docker.arvancloud.ir/"
    "Docker|Docker Hub - Hamravesh (Iran)|https://hub.hamdocker.ir/"
    "Docker|Docker Hub - IranServer (Iran)|https://docker.iranserver.com/"
    "Docker|Docker Hub - USTC (China)|https://docker.mirrors.ustc.edu.cn/"

    # Go
    "Go|GoProxy - goproxy.cn (China)|https://goproxy.cn,direct"

    # APT
    "APT|Ubuntu 24.04 - Tsinghua (China)|deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-updates main restricted universe multiverse\ndeb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ noble-security main restricted universe multiverse"
)

# =====================================================
# Generic backup
# =====================================================
backup_config() {
    case "$1" in
        Python) pip config get global.index-url > "$BACKUP_DIR/pip_index_url" 2>/dev/null ;;
        Node.js) npm config get registry > "$BACKUP_DIR/npm_registry" 2>/dev/null ;;
        Docker) cp /etc/docker/daemon.json "$BACKUP_DIR/docker_daemon.json" 2>/dev/null ;;
        Go) go env GOPROXY > "$BACKUP_DIR/go_proxy" 2>/dev/null ;;
        APT) cp /etc/apt/sources.list "$BACKUP_DIR/sources.list" 2>/dev/null ;;
    esac
}

# =====================================================
# Generic apply
# =====================================================
apply_mirror() {
    category="$1"
    url="$2"
    case "$category" in
        Python)
            pip config set global.break-system-packages true
            pip config set global.index-url "$url"
            ;;
        Node.js)
            npm config set registry "$url"
            ;;
        Docker)
            mkdir -p /etc/docker
            echo "{\"registry-mirrors\": [\"$url\"]}" > /etc/docker/daemon.json
            systemctl restart docker
            ;;
        Go)
            go env -w GOPROXY="$url"
            ;;
        APT)
            echo -e "$url" > /etc/apt/sources.list
            apt-get update
            ;;
    esac
}

# =====================================================
# Generic restore
# =====================================================
restore_config() {
    case "$1" in
        Python) [[ -f "$BACKUP_DIR/pip_index_url" ]] && pip config set global.index-url "$(cat "$BACKUP_DIR/pip_index_url")" ;;
        Node.js) [[ -f "$BACKUP_DIR/npm_registry" ]] && npm config set registry "$(cat "$BACKUP_DIR/npm_registry")" ;;
        Docker) [[ -f "$BACKUP_DIR/docker_daemon.json" ]] && cp "$BACKUP_DIR/docker_daemon.json" /etc/docker/daemon.json && systemctl restart docker ;;
        Go) [[ -f "$BACKUP_DIR/go_proxy" ]] && go env -w GOPROXY="$(cat "$BACKUP_DIR/go_proxy")" ;;
        APT) [[ -f "$BACKUP_DIR/sources.list" ]] && cp "$BACKUP_DIR/sources.list" /etc/apt/sources.list && apt-get update ;;
    esac
}

# =====================================================
# Menus
# =====================================================
main_menu() {
    local categories=()
    local seen=()
    for entry in "${MIRRORS[@]}"; do
        IFS='|' read -r category _ _ <<< "$entry"
        if [[ ! " ${seen[*]} " =~ " ${category} " ]]; then
            categories+=("$category" "$category mirrors")
            seen+=("$category")
        fi
    done
    categories+=("restore" "Restore previous settings")
    categories+=("quit" "Exit")
    whiptail --title "MirrorMate - Open Source Mirror Switcher" --menu "Select a category:" 20 70 10 "${categories[@]}" 3>&1 1>&2 2>&3
}

mirror_menu() {
    local category="$1"
    local items=()
    for entry in "${MIRRORS[@]}"; do
        IFS='|' read -r cat name _ <<< "$entry"
        if [[ "$cat" == "$category" ]]; then
            items+=("$name" "$name")
        fi
    done
    items+=("back" "Go Back")
    whiptail --title "$category Mirrors" --menu "Select a mirror:" 20 70 10 "${items[@]}" 3>&1 1>&2 2>&3
}

restore_menu() {
    local items=()
    local seen=()
    for entry in "${MIRRORS[@]}"; do
        IFS='|' read -r category _ _ <<< "$entry"
        if [[ ! " ${seen[*]} " =~ " ${category} " ]]; then
            items+=("$category" "Restore $category settings")
            seen+=("$category")
        fi
    done
    items+=("all" "Restore All")
    items+=("back" "Go Back")
    whiptail --title "Restore Settings" --menu "Select to restore:" 20 70 10 "${items[@]}" 3>&1 1>&2 2>&3
}

# =====================================================
# Main loop
# =====================================================
while true; do
    choice=$(main_menu) || exit 0
    case "$choice" in
        quit) exit 0 ;;
        restore)
            rchoice=$(restore_menu)
            case "$rchoice" in
                all)
                    for entry in "${MIRRORS[@]}"; do
                        IFS='|' read -r category _ _ <<< "$entry"
                        restore_config "$category"
                    done
                    whiptail --msgbox "✅ All settings restored from backup." 8 60
                    ;;
                back) continue ;;
                *)
                    restore_config "$rchoice"
                    whiptail --msgbox "✅ $rchoice settings restored from backup." 8 60
                    ;;
            esac
            ;;
        *)
            while true; do
                mchoice=$(mirror_menu "$choice")
                [[ "$mchoice" == "back" ]] && break
                for entry in "${MIRRORS[@]}"; do
                    IFS='|' read -r category name url <<< "$entry"
                    if [[ "$category" == "$choice" && "$name" == "$mchoice" ]]; then
                        backup_config "$category"
                        apply_mirror "$category" "$url"

                        # Confirmation menu
                        next_action=$(whiptail --title "Mirror Set" --menu "✅ Mirror set successfully!\nWhat do you want to do next?" 10 60 2 \
                        "1" "Exit" \
                        "2" "Back to Main Menu" 3>&1 1>&2 2>&3)

                        case "$next_action" in
                          1) echo "👋 Goodbye!"; exit 0 ;;
                          2) break 2 ;; # break inner and outer loop, back to main menu
                          *) break 2 ;;
                        esac
                    fi
                done
            done
            ;;
    esac
done
