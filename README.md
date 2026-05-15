# Goals (or benefits)
Organizing your ZSH Files as mentioned above Let you:
Easily maintain your configuration files.
Share your aliases or cool functions via links in Github.
Port your configuration to other computers (clone the repo)
Backup your settings for the case of disaster.

Many of the scripts are made for mac

# How to
If you want this repo to be used as your Oh My Zsh custom folder, replace the custom folder itself:

ln -fvs ~/repositories/github/myzsh-custom ~/.oh-my-zsh/custom

This is the simplest setup, because Oh My Zsh will then load files from the repo root as the custom folder.

Alternatively, if you want to keep the repo nested under ~/.oh-my-zsh/custom, you must source the files explicitly in ~/.zshrc because Oh My Zsh does not recurse into subdirectories automatically.

# Load repo scripts explicitly from .zshrc
Add lines like these to ~/.zshrc:

source ~/.oh-my-zsh/custom/myzsh-custom/git.zsh
source ~/.oh-my-zsh/custom/myzsh-custom/macos.zsh
source ~/.oh-my-zsh/custom/myzsh-custom/chrome.zsh
source ~/.oh-my-zsh/custom/myzsh-custom/zsh-plugins.zsh

Adjust the file list to match the scripts you want loaded.

# Install missing plugins
If you use `plugins=(git zsh-autosuggestions zsh-syntax-highlighting)` in `~/.zshrc`, you also need the plugin directories installed.

Use Homebrew:

brew install zsh-autosuggestions zsh-syntax-highlighting

Or clone them into your custom plugin folder:

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

If those plugins are not installed, remove them from the `plugins=(...)` line or keep using explicit `source` lines in `~/.zshrc`.
