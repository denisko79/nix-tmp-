{ config, pkgs, lib, inputs, ... }:

{
  # Let Home Manager install and manage itself
  home.stateVersion = "25.11";
  
  # Укажите домашний каталог
  home.username = "denis";
  home.homeDirectory = "/home/denis";
  
  # Установка bspwm и сопутствующих пакетов
  home.packages = with pkgs; [
    # BSPWM окружение
    bspwm
    sxhkd
    polybar
    rofi
    dunst
    picom
    feh
    nitrogen
    arandr
    
    # Шрифты для окружения
    (nerd-fonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" ]; })
    
    # Утилиты для работы
    alacritty  # Терминал
    firefox
    thunar     # Файловый менеджер
    pavucontrol # Управление звуком
    flameshot  # Скриншоты
    
    # Дополнительные утилиты
    lxappearance  # Темы GTK
    qt5ct         # Темы QT
    
    # Программы из вашей оригинальной конфигурации
    lazygit
    gh
    git-crypt
    neofetch
    fastfetch
  ];
  
  # Конфигурация BSPWM
  xsession = {
    enable = true;
    windowManager.bspwm = {
      enable = true;
      
      # Конфиг BSPWM
      config = {
        borderWidth = 2;
        windowGap = 10;
        borderlessMonocle = true;
        gaplessMonocle = true;
        splitRatio = 0.5;
        initialMonitor = "HDMI-1";
        focusFollowsPointer = true;
        
        # Правила для окон
        rules = {
          "Alacritty" = {
            state = "floating";
            sticky = true;
          };
        };
      };
      
      # Настройки sxhkd (горячие клавиши)
      sxhkd = {
        enable = true;
        keybindings = {
          # Запуск терминала
          "super + Return" = "alacritty";
          
          # Закрыть окно
          "super + q" = "bspc node -c";
          
          # Изменение раскладки окон
          "super + m" = "bspc desktop -l next";
          
          # Переключение между окнами
          "super + {_,shift + }Tab" = "bspc node -f {next,prev}.local";
          
          # Перемещение окон
          "super + shift + {h,j,k,l}" = "bspc node -v {-20 0,0 20,0 -20,20 0}";
          "super + ctrl + {h,j,k,l}" = "bspc node -s {west,south,north,east}";
          
          # Изменение размера окон
          "super + alt + {h,j,k,l}" = "bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}";
          "super + alt + shift + {h,j,k,l}" = "bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}";
          
          # Рабочие столы
          "super + {1-9}" = "bspc desktop -f '^{1-9}'";
          "super + shift + {1-9}" = "bspc node -d '^{1-9}'";
          
          # Запуск Rofi
          "super + d" = "rofi -show drun -show-icons";
          "super + shift + d" = "rofi -show run";
          
          # Скриншоты
          "Print" = "flameshot gui";
          "shift + Print" = "flameshot full";
          
          # Перезагрузка BSPWM
          "super + alt + r" = "bspc wm -r";
          
          # Блокировка экрана
          "super + x" = "${pkgs.i3lock}/bin/i3lock -c 000000";
          
          # Перезапуск Polybar
          "super + shift + r" = "pkill -USR1 polybar";
        };
      };
    };
  };
  
  # Конфигурация Polybar
  services.polybar = {
    enable = true;
    script = "polybar main &";
    config = {
      "bar/main" = {
        monitor = "\${env:MONITOR:eDP-1}";
        width = "100%";
        height = "27";
        radius = 0;
        fixed-center = true;
        
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        
        line-size = 3;
        line-color = "#f5c2e7";
        
        border-size = 4;
        border-color = "#00000000";
        
        padding-left = 0;
        padding-right = 2;
        
        module-margin-left = 1;
        module-margin-right = 2;
        
        font-0 = "JetBrainsMono Nerd Font:size=10;3";
        font-1 = "Font Awesome 6 Free Solid:size=10;3";
        font-2 = "Font Awesome 6 Brands:size=10;3";
        
        modules-left = "bspwm xwindow";
        modules-center = "date";
        modules-right = "cpu memory pulseaudio backlight battery wlan";
        
        tray-position = "right";
        tray-padding = 2;
        tray-background = "#1e1e2e";
        
        wm-restack = "bspwm";
        override-redirect = true;
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
      };
      
      "module/bspwm" = {
        type = "internal/bspwm";
        label-focused = "%index%";
        label-focused-background = "#89b4fa";
        label-focused-foreground = "#1e1e2e";
        label-focused-padding = 2;
        
        label-occupied = "%index%";
        label-occupied-padding = 2;
        
        label-urgent = "%index%";
        label-urgent-background = "#f38ba8";
        label-urgent-padding = 2;
        
        label-empty = "%index%";
        label-empty-foreground = "#6c7086";
        label-empty-padding = 2;
      };
      
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:30:...%";
      };
      
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = " ";
        format-prefix-foreground = "#89b4fa";
        label = "%percentage:2%%";
      };
      
      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = " ";
        format-prefix-foreground = "#a6e3a1";
        label = "%percentage_used%%";
      };
      
      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%H:%M";
        date-alt = "%Y-%m-%d %H:%M:%S";
        label = "%date%";
        format-prefix = " ";
        format-prefix-foreground = "#fab387";
      };
      
      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume = "<ramp-volume> <label-volume>";
        label-volume = "%percentage%%";
        label-volume-foreground = "#f9e2af";
        format-muted-prefix = " ";
        format-muted-foreground = "#6c7086";
        ramp-volume-0 = "";
        ramp-volume-1 = "";
        ramp-volume-2 = "";
        click-right = "pavucontrol";
      };
      
      "module/backlight" = {
        type = "internal/backlight";
        card = "intel_backlight";
        format = "<ramp> <label>";
        label = "%percentage%%";
        ramp-0 = "";
        ramp-1 = "";
        ramp-2 = "";
        ramp-foreground = "#f9e2af";
      };
    };
  };
  
  # Конфигурация Picom (композитный менеджер)
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
    settings = {
      blur = {
        method = "dual_kawase";
        strength = 5;
      };
      corner-radius = 10;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      animations = true;
      animation-stiffness = 300.0;
      animation-window-mass = 0.5;
      animation-dampening = 25.0;
      animation-clamping = false;
      animation-for-open-window = "zoom";
      animation-for-unmap-window = "slide-down";
    };
  };
  
  # Конфигурация Dunst (уведомления)
  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = 100;
        offset = "30x50";
        origin = "top-right";
        transparency = 20;
        frame_color = "#89b4fa";
        separator_color = "frame";
        font = "JetBrainsMono Nerd Font 10";
      };
      
      urgency_low = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 5;
      };
      
      urgency_normal = {
        background = "#1e1e2e";
        foreground = "#cdd6f4";
        timeout = 10;
      };
      
      urgency_critical = {
        background = "#f38ba8";
        foreground = "#1e1e2e";
        timeout = 0;
      };
    };
  };
  
  # Конфигурация Rofi
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    extraConfig = {
      modi = "run,drun,window";
      show-icons = true;
      terminal = "alacritty";
      drun-display-format = "{icon} {name}";
      disable-history = false;
      hide-scrollbar = true;
      sidebar-mode = true;
    };
  };
  
  # Конфигурация Alacritty (терминал)
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 12.0;
      };
      colors = {
        primary = {
          background = "#1e1e2e";
          foreground = "#cdd6f4";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
      };
      window = {
        opacity = 0.95;
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "full";
      };
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
    };
  };
  
  # Конфигурация Git
  programs.git = {
    enable = true;
    userName = "denis";
    userEmail = "denis@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";
    };
  };
  
  # Конфигурация Bash
  programs.bash = {
    enable = true;
    shellAliases = {
      cat = "bat";
      ls = "ls --color=auto";
      ll = "ls -la";
      nix-update = "sudo nixos-rebuild switch --flake /etc/nixos";
      nix-gc = "sudo nix-collect-garbage --delete-older-than 14d";
      hm-switch = "home-manager switch --flake /etc/nixos";
      bspc-restart = "bspc wm -r";
    };
    initExtra = ''
      # Показать состояние flake
      nix-info() {
        echo "NixOS Configuration:"
        cd /etc/nixos && nix flake show
      }
      
      # Быстрый запуск bspwm
      startxbspwm() {
        startx $HOME/.xsession
      }
      
      # Приветствие
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        fastfetch
        echo "Для запуска bspwm выполните: startx"
      fi
    '';
  };
  
  # Конфигурация Firefox (опционально)
  programs.firefox = {
    enable = true;
    profiles.denis = {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        darkreader
        tridactyl
      ];
      settings = {
        "browser.startup.homepage" = "about:blank";
        "browser.search.defaultenginename" = "Google";
      };
    };
  };
  
  # GTK тема
  gtk = {
    enable = true;
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };
  
  # QT тема
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  
  # xinitrc для запуска bspwm через startx
  home.file = {
    # .xinitrc
    ".xinitrc".text = ''
      #!/bin/sh
      
      # Запуск композитного менеджера
      picom --config $HOME/.config/picom/picom.conf &
      
      # Системный трей
      if [ -x /usr/bin/trayer ]; then
        trayer --edge top --align right --widthtype request --padding 6 --SetDockType true --SetPartialStrut true --expand true --monitor 1 --transparent true --alpha 0 --tint 0x1e1e2e --height 22 &
      fi
      
      # Запуск sxhkd (горячие клавиши)
      sxhkd &
      
      # Запуск полибара
      $HOME/.config/polybar/launch.sh &
      
      # Запуск Dunst (уведомления)
      dunst &
      
      # Автозапуск приложений
      nitrogen --restore &
      
      # Запуск bspwm
      exec bspwm
    '';
    
    # Скрипт запуска полибара
    ".config/polybar/launch.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        pkill polybar
        polybar main &
      '';
    };
  };
  
  # Автозапуск Home Manager при входе
  home.activation = {
    reloadBspwm = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD bspc wm -r
    '';
  };
}
