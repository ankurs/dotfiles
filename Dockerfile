FROM fedora:42

# Install core system and CLI tools
RUN dnf install -y --setopt=install_weak_deps=False \
    zsh tmux neovim git wget unzip \
    bat fzf ripgrep zoxide git-delta difftastic most jq fd-find \
    gcc gcc-c++ make cmake cargo rust \
    nodejs python3 python3-pip \
    util-linux-user \
    && dnf clean all

# Install eza and yazi from GitHub releases (not in Fedora repos)
RUN ARCH=$(uname -m) \
    && curl -fsSL "https://github.com/eza-community/eza/releases/latest/download/eza_${ARCH}-unknown-linux-gnu.tar.gz" \
       | tar xz -C /usr/local/bin \
    && curl -fsSL "https://github.com/sxyazi/yazi/releases/latest/download/yazi-${ARCH}-unknown-linux-gnu.zip" \
       -o /tmp/yazi.zip \
    && unzip -o /tmp/yazi.zip -d /tmp/yazi \
    && mv /tmp/yazi/yazi-${ARCH}-unknown-linux-gnu/yazi /usr/local/bin/ \
    && rm -rf /tmp/yazi /tmp/yazi.zip

# Create non-root user
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN dnf install -y sudo && dnf clean all \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

# Copy neovim config
COPY --chown=$USERNAME:$USERNAME nvim/ .config/nvim/

# Copy shell config
COPY --chown=$USERNAME:$USERNAME dot-zshrc .zshrc
COPY --chown=$USERNAME:$USERNAME dot-gitignore .gitignore
COPY --chown=$USERNAME:$USERNAME dot-mostrc .mostrc

# Create a container-friendly gitconfig (no SSH insteadOf, no work config)
# Git user name/email will be prompted on first shell start
RUN printf '%s\n' \
    '[core]' \
    '	excludesfile = ~/.gitignore' \
    '	pager = delta' \
    '' \
    '[interactive]' \
    '	diffFilter = delta --color-only' \
    '' \
    '[delta]' \
    '	navigate = true' \
    '	line-numbers = true' \
    '	side-by-side = false' \
    '	syntax-theme = Dracula' \
    '' \
    '[diff]' \
    '	algorithm = histogram' \
    '' \
    '[merge]' \
    '	conflictstyle = zdiff3' \
    '' \
    '[pull]' \
    '	rebase = false' \
    '' \
    '[init]' \
    '	defaultBranch = main' \
    > .gitconfig

# First-run git identity setup script
RUN printf '%s\n' \
    '#!/bin/zsh' \
    'if [[ -z "$(git config --global user.name)" ]]; then' \
    '    echo "Git identity not configured."' \
    '    read "name?Git name: "' \
    '    read "email?Git email: "' \
    '    git config --global user.name "$name"' \
    '    git config --global user.email "$email"' \
    '    echo "Git identity set to: $name <$email>"' \
    'fi' \
    > .git-setup.sh \
    && chmod +x .git-setup.sh \
    && echo 'source ~/.git-setup.sh' >> .zshrc

# Install Zinit and pre-load plugins/snippets
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" -- --skip-compdump
RUN zsh -ic 'source ~/.zshrc; exit' 2>/dev/null || true

# Pre-install Lazy plugins
RUN nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

# Build blink.cmp fuzzy matching library
RUN cd ~/.local/share/nvim/lazy/blink.cmp && cargo build --release 2>/dev/null || true

# Pre-install treesitter parsers (use lua to wait for completion)
RUN nvim --headless -c 'lua require("nvim-treesitter.install").install({"bash","c","clojure","cmake","comment","cpp","go","gomod","gosum","gotmpl","groovy","hcl","java","javascript","json","kotlin","latex","lua","make","perl","python","ruby","rust","scala","sql","terraform","todotxt","typescript","vue","vim","yaml"}):wait()' -c 'qa' 2>/dev/null || true

# Pre-install Mason tools
RUN nvim --headless "+MasonToolsInstall" +qa 2>/dev/null || true

CMD ["zsh"]
