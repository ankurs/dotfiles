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
    echo "  === Development ==="
    echo "  1) Docker (service + group)"
    echo "  2) Virtualization (KVM/QEMU)"
    echo "  3) Kubernetes (Minikube)"
    echo
    echo "  === System ==="
    echo "  4) Security Hardening (fail2ban, firewall)"
    echo "  5) System Optimizations (SSD, zram, sysctl)"
    echo "  6) Laptop Power Management (TLP, powertop)"
    echo
    echo "  === Storage ==="
    echo "  7) Backup Tools (restic, borg, duplicity)"
    echo
    echo "  === Presets ==="
    if is_laptop; then
        echo "  R) Recommended (1,4,5,6)"
    else
        echo "  R) Recommended (1,4,5)"
    fi
    echo "  D) Development (1,2,3)"
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
            1) SELECTIONS["docker"]=1 ;;
            2) SELECTIONS["virt"]=1 ;;
            3) SELECTIONS["minikube"]=1 ;;
            4) SELECTIONS["security"]=1 ;;
            5) SELECTIONS["optimization"]=1 ;;
            6) SELECTIONS["laptop"]=1 ;;
            7) SELECTIONS["backup"]=1 ;;
            r)
                SELECTIONS["docker"]=1
                SELECTIONS["security"]=1
                SELECTIONS["optimization"]=1
                is_laptop && SELECTIONS["laptop"]=1
                ;;
            d)
                SELECTIONS["docker"]=1
                SELECTIONS["virt"]=1
                SELECTIONS["minikube"]=1
                ;;
            a)
                SELECTIONS["docker"]=1
                SELECTIONS["virt"]=1
                SELECTIONS["minikube"]=1
                SELECTIONS["security"]=1
                SELECTIONS["optimization"]=1
                SELECTIONS["laptop"]=1
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
setup_docker() {
    progress "Setting up Docker (service + group)"

    # moby-engine and docker-compose are installed by dnf_list; this option
    # only handles the service-enable and user-group bits.
    enable_service docker

    if getent group docker >/dev/null; then
        sudo usermod -aG docker "$USER"
        log_info "User added to docker group (logout required for changes to take effect)"
    fi

    log_success "Docker setup completed"
}

setup_virtualization() {
    progress "Setting up Virtualization tools"

    sudo dnf group install -y virtualization
    sudo dnf install -y virt-manager

    # Add user to necessary groups
    sudo usermod -aG kvm,libvirt "$USER"

    # Enable services
    enable_service libvirtd

    log_success "Virtualization setup completed"
}

setup_minikube() {
    progress "Installing Minikube"

    # Map uname -m to the names kubernetes/minikube release URLs use.
    local arch
    case "$ARCH" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        *)
            log_warning "Unsupported architecture for Minikube: $ARCH"
            return 1
            ;;
    esac

    # Install kubectl
    if ! command -v kubectl &>/dev/null; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${arch}/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi

    # Install minikube
    if ! command -v minikube &>/dev/null; then
        curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${arch}"
        sudo install "minikube-linux-${arch}" /usr/local/bin/minikube
        rm "minikube-linux-${arch}"
    fi

    log_success "Minikube installed"
}

setup_security() {
    progress "Setting up Security Hardening"
    
    # Install security tools
    # Note: firewalld is usually pre-installed, fail2ban is optional
    sudo dnf install -y firewalld

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

    log_success "System optimizations completed"
}

setup_laptop() {
    progress "Setting up Laptop Power Management"

    # Check if this is actually a laptop
    if ! is_laptop; then
        log_warning "This doesn't appear to be a laptop (no battery detected)"
        log_info "Skipping laptop power management setup"
        return 0
    fi

    # Install power management tools
    sudo dnf install -y tlp tlp-rdw powertop thermald

    # Enable TLP
    sudo systemctl enable --now tlp

    # Disable conflicting services
    sudo systemctl mask systemd-rfkill.service
    sudo systemctl mask systemd-rfkill.socket

    # Install battery utilities
    sudo dnf install -y acpi

    log_success "Laptop power management configured"
}

setup_backup() {
    progress "Setting up Backup Tools"

    # btrbk and rclone come from dnf_list; this option ships the rest.
    sudo dnf install -y restic borgbackup duplicity

    if mount | grep -q btrfs && [[ -f fedora/btrbk/btrbk.conf ]]; then
        sudo install -Dm 644 fedora/btrbk/btrbk.conf /etc/btrbk/btrbk.conf
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
    [[ ${SELECTIONS["docker"]} ]] && setup_docker
    [[ ${SELECTIONS["virt"]} ]] && setup_virtualization
    [[ ${SELECTIONS["minikube"]} ]] && setup_minikube
    [[ ${SELECTIONS["security"]} ]] && setup_security
    [[ ${SELECTIONS["optimization"]} ]] && setup_optimization
    [[ ${SELECTIONS["laptop"]} ]] && setup_laptop
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
        echo "  • Docker service enabled, user added to docker group"
        echo "    - Logout required for docker group membership"
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

    echo
    log_warning "Some changes require logout/reboot to take effect:"
    echo "  • Shell change to zsh"
    echo "  • Docker group membership"
    echo "  • Kernel modules (virtualization)"
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