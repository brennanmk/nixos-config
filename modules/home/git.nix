{ pkgs, ... }: 
{
  programs.git = {
    enable = true;
    
    userName = "brennanmk";
    userEmail = "brennanmk2200@gmail.com";
    
    extraConfig = { 
      init.defaultBranch = "main";
      credential.helper = "store";
    };
  };
}
