#!/bin/bash
set -eo pipefail

# Terminal colors for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Progress tracking
STEPS_TOTAL=0
STEPS_COMPLETED=0

# Configuration selections
declare -A SELECTIONS

# Detect system architecture
ARCH=$(uname -m)

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

progress() {
    STEPS_COMPLETED=$((STEPS_COMPLETED + 1))
    echo -e "${CYAN}[${STEPS_COMPLETED}/${STEPS_TOTAL}]${NC} $1"
}

# Check if running in a VM
is_vm() {
    if systemd-detect-virt --quiet; then
        return 0
    fi
    return 1
}

# Check if running on laptop
is_laptop() {
    if [[ -d /sys/class/power_supply/BAT* ]]; then
        return 0
    fi
    return 1
}

# Check if package is installed
is_installed() {
    rpm -q "$1" &>/dev/null
}

# Check if service exists
service_exists() {
    systemctl list-unit-files | grep -q "^$1.service"
}

# Enable and start service if it exists
enable_service() {
    local service=$1
    if service_exists "$service"; then
        if sudo systemctl enable "$service" && sudo systemctl start "$service"; then
            log_success "$service enabled and started"
        else
            log_warning "Failed to enable/start $service"
        fi
    else
        log_info "$service not installed, skipping..."
    fi
}

# Present interactive menu
show_menu() {
    echo
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}       Fedora Post-Setup Configuration${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════${NC}"
    echo
    
    # Detect environment
    local env_type="Desktop"
    is_laptop && env_type="Laptop"
    is_vm && env_type="Virtual Machine"
    log_info "Detected environment: $env_type"
    echo
    
    echo "Select components to install/configure:"
    echo
    echo "  === Browsers ==="
    echo "  1) Brave Browser"
    if [[ "$ARCH" == "x86_64" ]]; then
        echo "  2) Google Chrome"
    else
        echo "  2) Google Chrome (not available for ARM64)"
    fi
    echo "  3) Chromium (open-source Chrome alternative)"
    echo
    echo "  === Development ==="
    echo "  4) Docker & Container Tools"
    echo "  5) Node.js & npm (via NodeSource)"
    echo "  6) Virtualization (KVM/QEMU)"
    echo "  7) Kubernetes (Minikube)"
    echo
    echo "  === System ==="
    echo "  8) Security Hardening (fail2ban, firewall)"
    echo "  9) System Optimizations (SSD, performance)"
    echo "  10) Monitoring Tools (netdata, htop, etc.)"
    echo "  11) Laptop Power Management (TLP, powertop)"
    echo
    echo "  === Desktop Environments ==="
    echo "  12) Sway Window Manager"
    echo "  13) Desktop Applications (variety, rofi)"
    echo
    echo "  === Storage ==="
    echo "  14) OpenZFS Support"
    echo "  15) Backup Tools (btrbk, restic)"
    echo
    echo "  === Presets ==="
    if is_laptop; then
        echo "  R) Recommended (1,3,4,5,8,9,10,11,12,13)"
    else
        echo "  R) Recommended (1,3,4,5,8,9,10,12,13)"
    fi
    echo "  D) Development (4,5,6,7)"
    echo "  A) All (everything)"
    echo
    echo "  Q) Quit"
    echo
    echo -n "Enter your choices (comma-separated, e.g., 1,3,7): "
    read -r choices
    
    # Parse selections
    IFS=',' read -ra ADDR <<< "$choices"
    for choice in "${ADDR[@]}"; do
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
        case $choice in
            1) SELECTIONS["brave"]=1 ;;
            2) [[ "$ARCH" == "x86_64" ]] && SELECTIONS["chrome"]=1 ;;
            3) SELECTIONS["chromium"]=1 ;;
            4) SELECTIONS["docker"]=1 ;;
            5) SELECTIONS["nodejs"]=1 ;;
            6) SELECTIONS["virt"]=1 ;;
            7) SELECTIONS["minikube"]=1 ;;
            8) SELECTIONS["security"]=1 ;;
            9) SELECTIONS["optimization"]=1 ;;
            10) SELECTIONS["monitoring"]=1 ;;
            11) SELECTIONS["laptop"]=1 ;;
            12) SELECTIONS["sway"]=1 ;;
            13) SELECTIONS["desktop_apps"]=1 ;;
            14) SELECTIONS["zfs"]=1 ;;
            15) SELECTIONS["backup"]=1 ;;
            r) 
                SELECTIONS["brave"]=1
                SELECTIONS["chromium"]=1
                SELECTIONS["docker"]=1
                SELECTIONS["nodejs"]=1
                SELECTIONS["security"]=1
                SELECTIONS["optimization"]=1
                SELECTIONS["monitoring"]=1
                is_laptop && SELECTIONS["laptop"]=1
                SELECTIONS["sway"]=1
                SELECTIONS["desktop_apps"]=1
                ;;
            d)
                SELECTIONS["docker"]=1
                SELECTIONS["nodejs"]=1
                SELECTIONS["virt"]=1
                SELECTIONS["minikube"]=1
                ;;
            a)
                SELECTIONS["brave"]=1
                [[ "$ARCH" == "x86_64" ]] && SELECTIONS["chrome"]=1
                SELECTIONS["chromium"]=1
                SELECTIONS["docker"]=1
                SELECTIONS["nodejs"]=1
                SELECTIONS["virt"]=1
                SELECTIONS["minikube"]=1
                SELECTIONS["security"]=1
                SELECTIONS["optimization"]=1
                SELECTIONS["monitoring"]=1
                SELECTIONS["laptop"]=1
                SELECTIONS["sway"]=1
                SELECTIONS["desktop_apps"]=1
                SELECTIONS["zfs"]=1
                SELECTIONS["backup"]=1
                ;;
            q) 
                log_info "Exiting..."
                exit 0
                ;;
        esac
    done
    
    # Count selected items
    STEPS_TOTAL=${#SELECTIONS[@]}
    if [[ $STEPS_TOTAL -eq 0 ]]; then
        log_warning "No components selected. Exiting..."
        exit 0
    fi
    
    echo
    log_info "Selected ${STEPS_TOTAL} components for installation/configuration"
    echo -n "Proceed? [Y/n]: "
    read -r confirm
    if [[ $confirm == "n" || $confirm == "N" ]]; then
        log_info "Cancelled by user"
        exit 0
    fi
}

# Setup functions
setup_brave() {
    progress "Installing Brave Browser"
    if ! is_installed brave-browser; then
        # Download and add the repo file directly
        sudo curl -fsSL https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo -o /etc/yum.repos.d/brave-browser.repo
        sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
        if sudo dnf install -y brave-browser; then
            log_success "Brave Browser installed"
        else
            log_warning "Brave Browser installation failed"
        fi
    else
        log_info "Brave Browser already installed"
    fi
}

setup_chrome() {
    progress "Installing Google Chrome"
    
    # Check architecture first
    if [[ "$ARCH" != "x86_64" ]]; then
        log_warning "Google Chrome is not available for ARM64/aarch64"
        log_info "Consider using Chromium instead (option 3)"
        return 1
    fi
    
    if ! is_installed google-chrome-stable; then
        # Create Google Chrome repo directly
        sudo tee /etc/yum.repos.d/google-chrome.repo > /dev/null << 'EOF'
[google-chrome]
name=google-chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF
        
        # Import GPG key
        sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub
        
        if sudo dnf install -y google-chrome-stable; then
            log_success "Google Chrome installed"
        else
            log_warning "Google Chrome installation failed"
        fi
    else
        log_info "Google Chrome already installed"
    fi
}

setup_chromium() {
    progress "Installing Chromium Browser"
    if ! is_installed chromium; then
        if sudo dnf install -y chromium; then
            log_success "Chromium installed"
        else
            log_warning "Chromium installation failed"
        fi
    else
        log_info "Chromium already installed"
    fi
}

setup_docker() {
    progress "Setting up Docker & Container Tools"
    
    # Install Docker
    if ! is_installed docker-ce; then
        # Download Docker repo directly
        sudo curl -fsSL https://download.docker.com/linux/fedora/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
        sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    fi
    
    # Enable service
    enable_service docker
    
    # Add user to docker group
    if getent group docker >/dev/null; then
        sudo usermod -aG docker "$USER"
        log_info "User added to docker group (logout required for changes to take effect)"
    fi
    
    # Install docker-compose standalone
    if ! command -v docker-compose &>/dev/null; then
        log_info "Installing docker-compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi
    
    log_success "Docker setup completed"
}

setup_nodejs() {
    progress "Setting up Node.js & npm"
    
    # Use NodeSource repository for latest LTS
    if ! is_installed nodejs; then
        curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
        sudo dnf install -y nodejs
    fi
    
    # Setup user npm directory
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    
    # Add to PATH if not already there
    if ! grep -q "npm-global/bin" ~/.bashrc 2>/dev/null; then
        echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
    fi
    
    # Install useful global packages
    npm install -g neovim typescript prettier eslint
    
    log_success "Node.js setup completed"
}

setup_virtualization() {
    progress "Setting up Virtualization tools"
    
    if [[ -f fedora/virt.sh ]]; then
        bash -e fedora/virt.sh
    else
        sudo dnf group install -y virtualization
        sudo dnf install -y virt-manager
    fi
    
    # Add user to necessary groups
    sudo usermod -aG kvm,libvirt "$USER"
    
    # Enable services
    enable_service libvirtd
    
    log_success "Virtualization setup completed"
}

setup_minikube() {
    progress "Installing Minikube"
    
    if [[ -f fedora/minikube.sh ]]; then
        bash -e fedora/minikube.sh
    else
        # Install kubectl
        if ! command -v kubectl &>/dev/null; then
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            rm kubectl
        fi
        
        # Install minikube
        if ! command -v minikube &>/dev/null; then
            curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
            sudo install minikube-linux-amd64 /usr/local/bin/minikube
            rm minikube-linux-amd64
        fi
    fi
    
    log_success "Minikube installed"
}

setup_security() {
    progress "Setting up Security Hardening"
    
    # Install security tools
    # Note: firewalld is usually pre-installed, fail2ban is optional
    sudo dnf install -y firewalld rkhunter lynis aide
    
    # Optional: Install and configure fail2ban if user wants it
    read -p "Install fail2ban for brute-force protection? [y/N]: " install_fail2ban
    if [[ $install_fail2ban == "y" || $install_fail2ban == "Y" ]]; then
        sudo dnf install -y fail2ban fail2ban-systemd
        
        # Configure fail2ban to use systemd-journald (not rsyslog)
        if [[ -f fedora/fail2ban/jail.d/99-local.conf ]]; then
            sudo mkdir -p /etc/fail2ban/jail.d
            sudo cp fedora/fail2ban/jail.d/99-local.conf /etc/fail2ban/jail.d/
        fi
        
        # Create systemd backend config for fail2ban
        sudo tee /etc/fail2ban/jail.d/00-systemd.conf > /dev/null << 'EOF'
[DEFAULT]
backend = systemd
EOF
        
        enable_service fail2ban
    fi
    
    # Enable firewalld (usually already enabled)
    enable_service firewalld
    
    # Basic firewall configuration
    if service_exists firewalld; then
        sudo firewall-cmd --permanent --add-service=ssh
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --permanent --add-service=https
        sudo firewall-cmd --reload
        log_info "Firewall configured with basic rules"
    fi
    
    # Enable automatic security updates
    sudo dnf install -y dnf5-plugin-automatic
    
    # Configure automatic updates
    sudo tee /etc/dnf/automatic.conf > /dev/null << 'EOF'
[commands]
upgrade_type = security
apply_updates = yes

[emitters]
emit_via = stdio
system_name = ${hostname}

[command_email]
email_from = root@${hostname}
email_to = root
email_host = localhost

[base]
debuglevel = 1
EOF
    
    # Enable the automatic update timer
    sudo systemctl enable --now dnf5-automatic.timer
    log_info "DNF5 automatic security updates enabled"
    
    log_success "Security hardening completed"
}

setup_optimization() {
    progress "Setting up System Optimizations"
    
    # Apply sysctl optimizations
    if [[ -f fedora/sysctl.d/90-ankur.conf ]]; then
        sudo cp fedora/sysctl.d/90-ankur.conf /etc/sysctl.d/
        sudo sysctl --system
    fi
    
    # SSD optimizations
    if lsblk -d -o name,rota | grep -q " 0$"; then
        log_info "SSD detected, applying optimizations..."
        
        # Enable fstrim timer for SSDs
        sudo systemctl enable --now fstrim.timer
        
        # Add noatime to fstab mounts (backup first)
        sudo cp /etc/fstab /etc/fstab.backup
        log_info "Consider adding 'noatime' to SSD mount options in /etc/fstab"
    fi
    
    # Setup zram for better memory compression
    if ! is_installed zram-generator; then
        sudo dnf install -y zram-generator
        echo "[zram0]" | sudo tee /etc/systemd/zram-generator.conf
        echo "zram-size = min(ram / 2, 4096)" | sudo tee -a /etc/systemd/zram-generator.conf
        sudo systemctl daemon-reload
        sudo systemctl start systemd-zram-setup@zram0.service
    fi
    
    # Optimize boot time
    sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null || true
    
    # Install performance tools
    sudo dnf install -y htop iotop iftop ncdu tldr
    
    log_success "System optimizations completed"
}

setup_monitoring() {
    progress "Setting up Monitoring Tools"
    
    # Install monitoring packages
    sudo dnf install -y netdata glances htop btop bpytop iotop iftop nmon
    
    # Setup netdata
    if is_installed netdata; then
        enable_service netdata
        log_info "Netdata available at http://localhost:19999"
    fi
    
    # Install additional system tools
    sudo dnf install -y sysstat lm_sensors
    sudo sensors-detect --auto
    
    log_success "Monitoring tools installed"
}

setup_laptop() {
    progress "Setting up Laptop Power Management"
    
    # Check if this is actually a laptop
    if ! is_laptop; then
        log_warning "This doesn't appear to be a laptop (no battery detected)"
        log_info "Skipping laptop power management setup"
        return 0
    fi
    
    if [[ -f fedora/laptop.sh ]]; then
        bash -e fedora/laptop.sh
    else
        # Install power management tools
        sudo dnf install -y tlp tlp-rdw powertop thermald
        
        # Enable TLP
        sudo systemctl enable --now tlp
        
        # Disable conflicting services
        sudo systemctl mask systemd-rfkill.service
        sudo systemctl mask systemd-rfkill.socket
        
        # Install battery utilities
        sudo dnf install -y acpi
    fi
    
    log_success "Laptop power management configured"
}

setup_sway() {
    progress "Installing Sway Window Manager"
    
    # Check if regular rofi is installed and replace with rofi-wayland
    if is_installed rofi && ! is_installed rofi-wayland; then
        log_info "Replacing rofi with rofi-wayland for better Wayland support"
        sudo dnf swap -y rofi rofi-wayland
    fi
    
    # Install Sway and related packages (skip already installed)
    sudo dnf install -y --skip-broken sway swayidle swaylock swaybg \
        waybar wofi wlogout grim slurp wdisplays \
        network-manager-applet wl-clipboard \
        nwg-launchers nwg-panel rofi-wayland \
        mako kanshi light xdg-desktop-portal-wlr
    
    # Install SwayNotificationCenter
    if ! is_installed SwayNotificationCenter; then
        sudo dnf copr enable -y erikreider/SwayNotificationCenter
        sudo dnf install -y SwayNotificationCenter
    fi
    
    # Setup configuration directories
    mkdir -p ~/.config/{sway,waybar,wofi,swaylock,mako}
    
    # Link configurations if they exist
    PWD=$(pwd)
    [[ -f sway-config ]] && ln -sf "$PWD/sway-config" ~/.config/sway/config
    [[ -f waybar-config ]] && ln -sf "$PWD/waybar-config" ~/.config/waybar/config
    [[ -f waybar-style.css ]] && ln -sf "$PWD/waybar-style.css" ~/.config/waybar/style.css
    [[ -f wofi-styles.css ]] && ln -sf "$PWD/wofi-styles.css" ~/.config/wofi/styles.css
    [[ -f swaylock.conf ]] && ln -sf "$PWD/swaylock.conf" ~/.config/swaylock/config
    
    log_success "Sway window manager installed"
    log_info "To use Sway, logout and select it from the login screen"
}

setup_desktop_apps() {
    progress "Setting up Desktop Applications"
    
    # Flatpak setup
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Install desktop applications
    # Check which rofi variant to install
    local rofi_package=""
    if is_installed rofi-wayland; then
        log_info "rofi-wayland already installed, skipping rofi"
    elif is_installed rofi; then
        log_info "rofi already installed"
    else
        # If neither is installed, prefer rofi-wayland for Wayland compatibility
        rofi_package="rofi-wayland"
    fi
    
    # Install packages, including rofi only if needed
    sudo dnf install -y --skip-broken variety dunst feh picom $rofi_package
    
    # Setup variety wallpaper manager
    if [[ -f variety.conf ]]; then
        mkdir -p ~/.config/variety
        cp variety.conf ~/.config/variety/
    fi
    
    # Setup rofi
    if [[ -f fedora/config.rasi ]]; then
        mkdir -p ~/.config/rofi
        ln -sf "$(pwd)/fedora/config.rasi" ~/.config/rofi/config.rasi
    fi
    
    log_success "Desktop applications configured"
}

setup_zfs() {
    progress "Installing OpenZFS"
    
    if [[ -f fedora/openzfs.sh ]]; then
        bash -e fedora/openzfs.sh
    else
        # Install ZFS repository
        sudo dnf install -y "https://zfsonlinux.org/epel/zfs-release-2-3.el$(rpm -E %rhel).noarch.rpm"
        sudo dnf install -y kernel-devel zfs
        sudo modprobe zfs
        
        # Enable ZFS services
        sudo systemctl enable --now zfs-import-cache
        sudo systemctl enable --now zfs-mount
        sudo systemctl enable --now zfs-zed
    fi
    
    log_success "OpenZFS installed"
}

setup_backup() {
    progress "Setting up Backup Tools"
    
    # Install backup tools
    sudo dnf install -y restic borgbackup duplicity rclone
    
    # Setup btrbk if using btrfs
    if mount | grep -q btrfs; then
        sudo dnf install -y btrbk
        if [[ -f fedora/btrbk/btrbk.conf ]]; then
            sudo cp fedora/btrbk/btrbk.conf /etc/btrbk/
        fi
    fi
    
    log_success "Backup tools installed"
}

# Update shell to zsh
update_shell() {
    if [[ "$SHELL" != *"zsh" ]]; then
        log_info "Updating default shell to zsh..."
        chsh -s "$(which zsh)"
        log_info "Shell changed to zsh (logout required)"
    fi
}

# Main execution
main() {
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
    
    # Ensure we're in the dotfiles directory
    if [[ ! -f setup.sh ]]; then
        log_error "Please run this script from the dotfiles directory"
        exit 1
    fi
    
    # Show menu and get selections
    show_menu
    
    echo
    log_info "Starting Fedora post-setup configuration..."
    echo
    
    # Execute selected setups
    [[ ${SELECTIONS["brave"]} ]] && setup_brave
    [[ ${SELECTIONS["chrome"]} ]] && setup_chrome
    [[ ${SELECTIONS["chromium"]} ]] && setup_chromium
    [[ ${SELECTIONS["docker"]} ]] && setup_docker
    [[ ${SELECTIONS["nodejs"]} ]] && setup_nodejs
    [[ ${SELECTIONS["virt"]} ]] && setup_virtualization
    [[ ${SELECTIONS["minikube"]} ]] && setup_minikube
    [[ ${SELECTIONS["security"]} ]] && setup_security
    [[ ${SELECTIONS["optimization"]} ]] && setup_optimization
    [[ ${SELECTIONS["monitoring"]} ]] && setup_monitoring
    [[ ${SELECTIONS["laptop"]} ]] && setup_laptop
    [[ ${SELECTIONS["sway"]} ]] && setup_sway
    [[ ${SELECTIONS["desktop_apps"]} ]] && setup_desktop_apps
    [[ ${SELECTIONS["zfs"]} ]] && setup_zfs
    [[ ${SELECTIONS["backup"]} ]] && setup_backup
    
    # Always update shell to zsh
    update_shell
    
    echo
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}       Post-Setup Configuration Complete!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════${NC}"
    echo
    
    # Show summary of changes
    log_info "Summary of changes:"
    
    if [[ ${SELECTIONS["docker"]} ]]; then
        echo "  • Docker installed and configured"
        echo "    - Logout required for docker group membership"
    fi
    
    if [[ ${SELECTIONS["nodejs"]} ]]; then
        echo "  • Node.js LTS installed with npm"
        echo "    - Global packages in ~/.npm-global"
    fi
    
    if [[ ${SELECTIONS["security"]} ]]; then
        echo "  • Security hardening applied"
        echo "    - Firewall enabled with basic rules"
        echo "    - Automatic updates configured"
    fi
    
    if [[ ${SELECTIONS["optimization"]} ]]; then
        echo "  • System optimizations applied"
        echo "    - SSD optimizations (if applicable)"
        echo "    - Memory compression with zram"
    fi
    
    if [[ ${SELECTIONS["monitoring"]} ]]; then
        echo "  • Monitoring tools installed"
        echo "    - Netdata available at http://localhost:19999"
    fi
    
    if [[ ${SELECTIONS["sway"]} ]]; then
        echo "  • Sway window manager installed"
        echo "    - Select from login screen after logout"
    fi
    
    echo
    log_warning "Some changes require logout/reboot to take effect:"
    echo "  • Shell change to zsh"
    echo "  • Docker group membership"
    echo "  • Kernel modules (ZFS, virtualization)"
    echo
    
    echo -n "Would you like to reboot now? [y/N]: "
    read -r reboot_now
    if [[ $reboot_now == "y" || $reboot_now == "Y" ]]; then
        log_info "Rebooting..."
        sudo reboot
    else
        log_info "Please reboot when convenient to apply all changes"
    fi
}

# Run main function
main "$@"