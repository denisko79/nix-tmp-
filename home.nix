{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "denis";
  home.homeDirectory = "/home/denis";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "25.11"; # Укажите версию, соответствующую вашей версии NixOS

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Настройки X11 и оконного менеджера
  services.xserver = {
    enable = true;
    windowManager.bspwm = {
      enable = true;
      # Параметры bspwm можно задать здесь или в ~/.config/bspwm/
    };
  };

  # Для входа через startx
  programs.xinit = {
    enable = true;
    # Указываем, что использовать в качестве сеанса X
    xserverArgs = [ ":0" ]; # Или оставьте пустым для автовыбора
  };

  # Шрифты
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Утилиты X11
    xorg.xinit
    xorg.xrandr
    xorg.xset
    xclip
    # Установка bspwm напрямую
    bspwm
    sxhkd # Горячие клавиши для bspwm
    dmenu # Меню запуска
    feh # Установка обоев
    picom # Композитный менеджер
    nitrogen # Выбор обоев
    rofi # Альтернативное меню запуска
    polybar # Панель задач
    lemonbar # Простая панель
    scrot # Скриншоты
    thunar # Файловый менеджер
    pavucontrol # Контроль громкости PulseAudio
    alacritty # Терминал
    firefox # Браузер
    # и т.д.
  ];

  # Настройка shell (bash)
  programs.bash.enable = true;
  programs.bash.shellOptions = [ "histappend" ];

  # Git
  programs.git = {
    enable = true;
    userName = "Denis";
    userEmail = "your-email@example.com"; # Замените на реальный email
  };

  # SSH клиент
  programs.ssh = {
    enable = true;
  };

  # Редакторы
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  # Системные утилиты
  home.packages = with pkgs; home.packages ++ [
    htop
    btop
    mc
    fastfetch
    bat
    ripgrep
    # и т.д.
  ];

  # Автозагрузка служб
  services.polybar = {
    enable = true;
    script = "polybar example &";
  };

  # Пример настройки polybar
  xdg.configFile."polybar/config.ini".source = pkgs.writeText "polybar-config" ''
    [bar/example]
    width = 100%
    height = 24
    ; ... остальная конфигурация polybar ...
  '';

  # Скрипт xinitrc будет сгенерирован автоматически, если не указан
  # Но если вы хотите свой, можно создать его как файл
  home.file.".xinitrc".text = ''
    #!/bin/sh
    # Загрузка переменных среды
    if [ -f ~/.profile ]; then
        . ~/.profile
    fi

    # Запуск sxhkd
    sxhkd &

    # Установка обоев
    feh --bg-scale /path/to/wallpaper.jpg &

    # Запуск bspwm
    exec bspwm
  '';
  home.file.".xinitrc".executable = true;

  # Скрипт автозапуска для bspwm
  xdg.configFile."bspwm/bspwmrc".source = pkgs.writeScript "bspwmrc" ''
    #!/bin/sh
    bspc monitor -d I II III IV V VI VII VIII IX X
    bspc config border_width         2
    bspc config window_gap          12
    bspc config split_ratio          0.52
    bspc config borderless_monocle   true
    bspc config gapless_monocle      true
    # ... остальные настройки ...
  '';
  xdg.configFile."sxhkd/sxhkdrc".source = pkgs.writeScript "sxhkdrc" ''
    # Пример горячих клавиш
    super + Return
        alacritty

    super + d
        dmenu_run
    # ... остальные настройки ...
  '';
}
