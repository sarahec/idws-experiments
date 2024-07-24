{
  description = "Small experiments to determine if an dhow to use LLMs to aid in designing learning experiences";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    inputs@{ flake-parts, devenv-root, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = [
        "x86_64-linux"
        # "i686-linux"
        "x86_64-darwin"
        # "aarch64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          ...
        }:
        {
          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.

          devenv.shells.default = {
            devenv.root =
              let
                devenvRootFileContent = builtins.readFile devenv-root.outPath;
              in
              pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

            name = "Jupyter-id-tests";

            imports = [
              # This is just like the imports in devenv.nix.
              # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
              # ./devenv-foo.nix
            ];

            dotenv.disableHint = true; # Using dotenvx instead and there's no integration

            languages.nix.enable = true;

            languages.python = {
              enable = true;
              venv = {
                enable = true;
                quiet = false;
                requirements = ''
                  jupyterlab
                  voila
                  langchain
                  langgraph
                  langchain-groq
                '';
              };
            };

            # https://devenv.sh/reference/options/
            packages = [ pkgs.dotenvx ];

            processes.juypter.exec = "dotenvx run -f .env -- jupyter-lab";

	    enterShell = ''
    	      # fixes libstdc++ issues and libgl.so issues
       	      export LD_LIBRARY_PATH=${pkgs.stdenv.cc.cc.lib}/lib/
	    '';
          };
        };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
