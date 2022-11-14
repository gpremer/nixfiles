{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "gpremer";
  home.homeDirectory = "/home/gpremer";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    bat
    curl
    exa
    fd
    htop
    httpie
    jq
    mc
    ncdu
    nload
    nodejs-16_x
    ripgrep
    timewarrior
    visidata
    wget
    zenith
    zenith
    zoxide
  ];

  programs.git = {
    enable = true;
    userName = "Geert Premereur";
    aliases = {
      lg = "lg1";
      lg1 = "lg1-specific --all";
      lg2 = "lg2-specific --all";
      lg3 = "lg3-specific --all";
      lg1-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
      lg2-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'";
      lg3-specific = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset) %C(bold cyan)(committed: %cD)%C(reset) %C(auto)%d%C(reset)%n''          %C(white)%s%C(reset)%n''          %C(dim white)- %an <%ae> %C(reset) %C(dim white)(committer: %cn <%ce>)%C(reset)'";
    };
    extraConfig = {
      pull = { ff = "only"; };
      push.autoSetupRemote = true;
      init = { defaultBranch = "main"; };
      help = { autocorrect = 5; };
    };
    difftastic = {
      enable = true;
    };
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
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
    ];
  };

  programs.zoxide = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" ];
    shellAliases = {
      ls="exa";
      ll="exa -al";
      la="exa -a";
      l="exa -G";
      tw="timew";
      twc="timew cont";
      tws="timew stop";
      # To prevent code to see CTRL+SHIFT+E as emoji start sequence (https://askubuntu.com/questions/1046418/how-do-i-disable-emoji-input-in-ubuntu-mate-18-04)
      code="GTK_IM_MODULE=\"xim\" code";
    };
    sessionVariables = {
      EDITOR = "nvim";
      SBT_CREDENTIALS = "~/.ivy2/.credentials";
      SBT_OPTS = "-Dsbt.override.build.repos=true -Xms1024m -Xmx2048m -XX:MaxPermSize=512m -Xss4m -XX:ReservedCodeCacheSize=64m -XX:+CMSClassUnloadingEnabled -Dfile.encoding=UTF-8 -Dsbt.boot.credentials=$SBT_CREDENTIALS";
      LOCALE_ARCHIVE = /usr/lib/locale/locale-archive; # To get the locales working for nix;
    };
    initExtra = ''
      # To make sure that bash completions are sourced. This is fixed upstream. Available in the next version?
      if [[ ! -v BASH_COMPLETION_VERSINFO ]]; then
        . "${pkgs.bash-completion}/etc/profile.d/bash_completion.sh"
      fi

      # To include personal binaries (not pacakged yet) 
      PATH="$HOME/bin:$PATH"

      # To use the nix-supplied binaries
      . ~/.nix-profile/etc/profile.d/nix.sh

      # For AWV docker-compose
      export DOCKER_OUTER_HOST=$(
        docker ps >/dev/null
        ip a l dev docker0 | grep inet | sed -e 's/.*inet \([^\/]*\).*/\1/'
      )
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
  };

  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 20;
      add_newline = false;

      battery = {
        display = [{
          threshold = 15;
          style = "bold red";
        }
        {
          threshold = 50;
          style = "bold yellow";
          discharging_symbol = "💦";
        }];
      };
    };
  };

  # Raw configuration files
  home.file.".npmrc".source = ../npmrc;

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
