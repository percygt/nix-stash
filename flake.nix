{
  description = "My stash of nix overlays";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    codeium.url = "github:Exafunction/codeium.nvim";
    codeium.inputs.nixpkgs.follows = "nixpkgs-stable";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:guibou/nixgl";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    tmuxinoicer.url = "github:percygt/tmuxinoicer";

    wezterm.url = "github:wez/wezterm?dir=nix";
    wezterm.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    yazi.url = "github:sxyazi/yazi";
    yazi.inputs.nixpkgs.follows = "nixpkgs";

    yaml2nix.url = "github:euank/yaml2nix";
    yaml2nix.inputs.nixpkgs.follows = "nixpkgs";
    firefox-ui-fix = {
      url = "github.com:black7375/Firefox-UI-Fix";
      flake = false;
    };
    tmuxst = {
      url = "github:percygt/tmuxst";
      flake = false;
    };
    fzf-url = {
      url = "github:wfxr/tmux-fzf-url";
      flake = false;
    };
    hmts = {
      url = "github:calops/hmts.nvim";
      flake = false;
    };
    neovim-session-manager = {
      url = "github:Shatur/neovim-session-manager";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:percygt/nvim-web-devicons";
      flake = false;
    };
    better-escape = {
      url = "github:max397574/better-escape.nvim";
      flake = false;
    };
    vim-maximizer = {
      url = "github:szw/vim-maximizer";
      flake = false;
    };
  };
  outputs = {
    nixpkgs,
    self,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = ["aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin"];
    forEachSystem = inputs.nixpkgs.lib.genAttrs systems;
  in {
    packages = forEachSystem (system: (import ./packages {
      pkgs = nixpkgs.legacyPackages.${system};
      inherit system inputs;
    }));
    formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs outputs;};
    pkgLib = import ./packages/lib.nix {inherit inputs;};
  };
}
