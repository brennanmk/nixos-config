{ config, lib, pkgs, ... }:

{
   home.packages = (with pkgs; [
    (aspellWithDicts (dicts: with dicts; [
      fr
      en
      en-computers
      en-science
    ]))
   ]);
}
