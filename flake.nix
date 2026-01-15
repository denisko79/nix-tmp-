{
  description = "NixOS configuration with Home Manager and BSPWM";

  inputs = {
    # Официальные NixOS репозитории
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Необязательно: дополнительные утилиты
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # NixOS конфигурация
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Основная конфигурация системы
        ./configuration.nix
        
        # Home Manager модуль
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.denis = import ./home-manager/home.nix;
            
            # Дополнительные настройки Home Manager
            extraSpecialArgs = { inherit inputs; };
          };
        }
      ];
    };
  };
}
