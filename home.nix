{ config, pkgs, lib, ... }:

{
  home.username = "chills";
  home.homeDirectory = "/home/chills";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    scrot
    xclip
    kitty
    google-chrome
    arandr
    git
    ripgrep
    docker
    postgresql
    rofi
  ];

  programs = {
    home-manager.enable = true;

    emacs = {
      enable = true;
    };

    kitty = {
      enable = true;
      settings = {
        enable_audio_bell = false;
      };
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    i3status = {
      enable = true;
      enableDefault = false;
      modules = {
        "volume master" = {
          position = 1;
          settings = {
            format = "♪ %volume";
            format_muted = "♪ muted (%volume)";
            device = "pulse:1";
          };
        };

        "tztime local" = {
          position = 2;
          settings = {
            format = "%Y-%m-%d %H:%M ";
          };
        };
      };
    };

    rofi = {
      enable = true;
      location = "top";
      theme = {
        "@import" = "${config.xdg.cacheHome}/wal/colors-rofi-dark";
      };
    };

    bash = {
      enable = true;
      bashrcExtra = ''
        (cat ~/.cache/wal/sequences &)
      '';
    };
  };



  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    
    config = with builtins; with lib.attrsets; with lib.trivial;
      let
        alt = "Mod1";
        win = "Mod4";
        combineSets = zipAttrsWith (s: fs: head fs);
        workspaceKeys =
          let workspaceList = genList (x: (x + 1)) 9;
              shiftNum = [
                "parenright"
                "exclam"
                "at"
                "numbersign"
                "dollar"
                "percent"
                "asciicircum"
                "ampersand"
                "asterisk"
                "parenleft"
              ];
              workspaceSwitchKeys = map (ws: nameValuePair (toString ws) "workspace ${toString ws}") workspaceList;
              workspaceMoveKeys = map (ws: nameValuePair "Shift+${elemAt shiftNum ws}" "move container to workspace ${toString ws}") workspaceList;
          in listToAttrs (workspaceSwitchKeys ++ workspaceMoveKeys);
        regularKeys = {
          "h" = "focus left";
          "j" = "focus down";
          "k" = "focus up";
          "l" = "focus right";
          "Shift+H" = "move left";
          "Shift+J" = "move down";
          "Shift+K" = "move up";
          "Shift+L" = "move right";
          "v" = "split v";
          "b" = "split h";
          "f" = "fullscreen";
          "shift+f" = "fullscreen toggle global";
          "w" = "exec ${pkgs.rofi}/bin/rofi -show window";
          "r" = "exec ${pkgs.rofi}/bin/rofi -show run";
          "q" = "kill";
          "Shift+space" = "floating toggle";
          "space" = "focus mode_toggle";
          "g" = "exec ${pkgs.google-chrome}/bin/google-chrome-stable";
          "e" = "exec ${pkgs.emacs}/bin/emacs";
          "t" = "exec ${pkgs.kitty}/bin/kitty";
          "Shift+C" = "reload";
          "Shift+R" = "restart";
          "Shift+Q" = "Quit";
          "Escape" = "mode i3";
          "i" = "mode default";
        };
        stickyKeys = {
          # keys which do not cause i3 mode to revert to default
          "grave" = "mode god";
          "${alt}+h" = "resize shrink width 10 px or 10 ppt";
          "${alt}+j" = "resize grow height 10 px or 10 ppt";
          "${alt}+k" = "resize shrink height 10 px or 10 ppt";
          "${alt}+l" = "resize grow width 10 px or 10 ppt";
        };
        mapSet = fkey: fvalue: set:
          mapAttrs' (name: value: nameValuePair (fkey name) (fvalue value)) set;
        mapKeys = fkey: mapSet fkey id;
        mapValues = fvalue: mapSet id fvalue;
      in {
        terminal = "kitty";
        modifier = win;
        floating.modifier = alt;
        gaps = {
          inner = 10;
          outer = -5;
          top = 0;
          bottom = 0;
        };
        keybindings = combineSets [
          {
            "${alt}+Escape" = "mode i3";
            "${alt}+grave" = "mode god";
          }
          (mapKeys (key: "${win}+${key}") (combineSets [regularKeys stickyKeys workspaceKeys]))
        ];
        modes = {
          i3 = combineSets [
            (mapValues (value: "${value}; mode default") (combineSets [regularKeys workspaceKeys]))
            stickyKeys
          ];
          god = combineSets [
            {
              "grave" = "mode default";
              "Escape" = "mode default";
            }
            regularKeys
            stickyKeys
            workspaceKeys
          ];
        };
        colors = let
          # let colors be managed with xresources
          defcolor = {
            border = "$bg";
            background = "$bg";
            text = "$fg";
            indicator = "$bg";
            childBorder = "$bg";
          };
        in {
          focused = defcolor;
          focusedInactive = defcolor;
          unfocused = defcolor;
          urgent = defcolor;
          placeholder = defcolor;
          background = "$bg";
        };
      };
    extraConfig = ''
        # fake-outputs 1280x1440+0+0,2560x1440+1280+0,1280x1440+3840+0+0

        # Set colors from Xresources
        # Change 'color7' and 'color2' to whatever colors you want i3 to use
        # from the generated scheme.
        # NOTE: The '#f0f0f0' in the lines below is the color i3 will use if
        # it fails to get colors from Xresources.
        set_from_resource $fg i3wm.color7 #f0f0f0
        set_from_resource $bg i3wm.color2 #f0f0f0
      '';
  };
}
