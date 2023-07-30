{
  description = "Carnap Core Libraries";

  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

  outputs = { self, nixpkgs }: 
  let
    compiler = "ghc945";
    name = "Carnap";
    system = "x86_64-linux"; 
    carnapOverride = final: prev: {
        ${name} = prev.callCabal2nix name ./. { };
    };
    overlay = final: prev: {
      haskell = prev.haskell // {
        packageOverrides = final.lib.composeExtensions
          (prev.haskell.packageOverrides or (_:_: {}))
          carnapOverride;
      };
    };
    overlays = [overlay];
    pkgs = import nixpkgs { inherit system overlays; };
  in
  {
    packages.${system}.default = pkgs.haskell.packages.${compiler}.${name};

    overlays.default = overlay;
  };
}
