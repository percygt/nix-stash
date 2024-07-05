{
  description = "My stash of nix overlays";
  nixConfig = {
    extra-substituters = ["https://nix-community.cachix.org"];
    extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  };

  inputs = {
    nix-sources.url = "github:percygt/nix-sources";
    nixpkgs.follows = "nix-sources/nixpkgs";
    nixpkgs-stable.follows = "nix-sources/nixpkgs-stable";
    flake-utils.url = "github:numtide/flake-utils";

    keepmenu.url = "github:percygt/keepmenu";
    keepmenu.inputs.nixpkgs.follows = "nixpkgs";

    # aagl.url = "github:ezKEa/aagl-gtk-on-nix";
    # aagl.inputs.nixpkgs.follows = "nixpkgs";

    codeium.url = "github:Exafunction/codeium.nvim";
    codeium.inputs.nixpkgs.follows = "nixpkgs-stable";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:guibou/nixgl";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    tmuxinoicer.url = "github:percygt/tmuxinoicer";

    wezterm.url = "github:wez/wezterm?dir=nix";

    waybar.url = "github:Alexays/Waybar";
    waybar.inputs.nixpkgs.follows = "nixpkgs";

    yazi.url = "github:sxyazi/yazi";
    yazi.inputs.nixpkgs.follows = "nixpkgs";

    yaml2nix.url = "github:euank/yaml2nix";
    yaml2nix.inputs.nixpkgs.follows = "nixpkgs";
    firefox-ui-fix = {
      url = "github:black7375/Firefox-UI-Fix";
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
    garbage-day-nvim = {
      url = "github:zeioth/garbage-day.nvim";
      flake = false;
    };
    git-worktree-nvim = {
      url = "github:awerebea/git-worktree.nvim/handle_changes_in_telescope_api";
      flake = false;
    };
    code-runner-nvim = {
      url = "github:CRAG666/code_runner.nvim";
      flake = false;
    };
    better-escape = {
      url = "github:max397574/better-escape.nvim";
      flake = false;
    };
    mini-nvim = {
      url = "github:echasnovski/mini.nvim";
      flake = false;
    };
    multicursors-nvim = {
      url = "github:smoka7/multicursors.nvim";
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
    overlays = {
      nix-vscode-extensions = inputs.nix-vscode-extensions.overlays.default;
    };
    legacyPackages = forEachSystem (
      system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues overlays;
          config.allowUnfree = true;
        }
    );
  in {
    vscodeExtensions = forEachSystem (system:
      import ./packages/vscode_extensions.nix {
        pkgs = legacyPackages.${system};
      });
    packages = forEachSystem (system: (import ./packages {
      pkgs = legacyPackages.${system};
      inherit system inputs;
    }));
    formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
    overlays = import ./overlays {inherit inputs outputs;};
    pkgLib = import ./packages/lib.nix {inherit inputs;};
  };
}
