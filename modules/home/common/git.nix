{ pkgs, ... }: 
{
  programs.git = {
    enable = true;
    
    userName = "brennanmk";
    userEmail = "brennanmk2200@gmail.com";
    
    extraConfig = { 
      credential.helper = "";
    };
  };
}
