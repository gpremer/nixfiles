{ config, pkgs, ... }: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gpremer";
  home.homeDirectory = "/home/gpremer";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    bat
    byobu
    curl
    exa
    fd
    htop
    httpie
    jless
    jq
    lnav
    mc
    mitmproxy
    ncdu
    nixfmt
    nload
    nodejs-16_x
    ripgrep
    rsync
    sqlite
    tokei
    timewarrior
    tmux
    visidata
    wget
    xsel
    zenith
    zoxide

    chromium
    darktable
    geeqie
    gimp
    inkscape
    keepassx2
    speedcrunch
    gnome.vinagre

    awscli2
    k9s
    bsdgames

  ];

  programs.git = {
    enable = true;
    userName = "Geert Premereur";
    aliases = {
      lg = "lg1";
      lg1 = "lg1-specific --all";
      lg2 = "lg2-specific --all";
      lg3 = "lg3-specific --all";
      lg1-specific =
        "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
      lg2-specific =
        "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
      lg3-specific =
        "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n          %C(white)%s%C(reset)%n          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'";
    };
    extraConfig = {
      pull = { ff = "only"; };
      push.autoSetupRemote = true;
      init = { defaultBranch = "main"; };
      help = { autocorrect = 30; };
      user.useConfigOnly = true;
      "includeIf \"gitdir:~/src/**/awv/\"" = { path = "./awv_config"; };
    };
    difftastic = { enable = true; };
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
      # enableFlakes = true; # std in 22.05
    };
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [ epkgs.nix-mode epkgs.magit ];
  };

  programs.zoxide = { enable = true; };

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" ];
    shellAliases = {
      ls = "exa";
      ll = "exa -al";
      la = "exa -a";
      l = "exa -G";
      tw = "timew";
      twc = "timew cont";
      tws = "timew stop";
      # To prevent code to see CTRL+SHIFT+E as emoji start sequence (https://askubuntu.com/questions/1046418/how-do-i-disable-emoji-input-in-ubuntu-mate-18-04)
      code = ''GTK_IM_MODULE="xim" NODE_OPTIONS="" code'';
    };
    sessionVariables = {
      EDITOR = "nvim";
      SBT_CREDENTIALS = "~/.ivy2/.credentials";
      SBT_OPTS =
        "-Dsbt.override.build.repos=true -Xms1024m -Xmx2048m -XX:MaxPermSize=512m -Xss4m -XX:ReservedCodeCacheSize=64m -XX:+CMSClassUnloadingEnabled -Dfile.encoding=UTF-8 -Dsbt.boot.credentials=$SBT_CREDENTIALS";
      LOCALE_ARCHIVE =
        "/usr/lib/locale/locale-archive"; # To get the locales working for nix;
      NODE_OPTIONS =
        "--openssl-legacy-provider"; # The nix-supplied node 16 links with a newer openssl version than the webpack of Angular 12 expects. See https://cardano.stackexchange.com/questions/6286/nix-is-building-ghc-during-on-nix-build-command-how-to-fix-the-cache. TODO move to dev env
    };
    initExtra = ''
      # To make sure that bash completions are sourced. This is fixed upstream. Available in the next version?
      if [[ ! -v BASH_COMPLETION_VERSINFO ]]; then
        . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
      fi

      # To include personal binaries (not pacakged with nix yet)
      # set PATH so it includes user's private bin if it exists
      if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
      fi

      # set PATH so it includes user's private bin if it exists
      if [ -d "$HOME/.local/bin" ] ; then
          PATH="$HOME/.local/bin:$PATH"
      fi

      # To use the nix-supplied binaries for a single-user installation
      if [[ -f ~/.nix-profile/etc/profile.d/nix.sh ]]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
      fi

      # For AWV docker-compose
      export DOCKER_OUTER_HOST=$(
        docker ps >/dev/null
        ip a l dev docker0 | grep inet | sed -e 's/.*inet \([^\/]*\).*/\1/'
      )

      # AWV cli completion (TODO package in nix)
      eval "$(/home/gpremer/bin/awv completion)"
    '';
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;
    #extraConfig = builtins.readFile ./home/extraConfig.vim;
    plugins = with pkgs.vimPlugins; [
      auto-pairs
      fzf-vim
      lightline-vim
      vim-addon-nix
      vim-nix
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    defaultCommand =
      "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 50%"
      "-1"
      "--reverse"
      "--multi"
      "--inline-info"
      "--preview='[[ \\$(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2>/dev/null | head -300' "
      "--preview-window='right:hidden:wrap'"
      "--bind='f3:execute(bat --style=numbers {} || less -f {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+} | xsel --clipboard --input)' "
    ];
    fileWidgetCommand =
      "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --strip-cwd-prefix --hidden --follow";
  };

  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 20;
      add_newline = false;

      battery = {
        display = [
          {
            threshold = 15;
            style = "bold red";
            discharging_symbol = "🔥";
          }
          {
            threshold = 50;
            style = "bold yellow";
            discharging_symbol = "💦";
          }
        ];
      };
    };
  };

  programs.vscode = {
    enable = true;
  };

  programs.java = {
    enable = true;
    package = pkgs.openjdk;
  };

  # Raw configuration files
  home.file.".npmrc".source = ../npmrc;
  home.file.".config/git/awv_config" = {
    text = ''
      [user]
      email = "geert.premereur@mow.vlaanderen.be"
    '';
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # work-around for https://github.com/NixOS/nixpkgs/issues/196651
  manual.manpages.enable = false;
}
