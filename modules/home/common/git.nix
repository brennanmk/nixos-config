{ pkgs, ... }: 
{
  programs.git = {
    enable = true;
    
    settings.user.name = "brennanmk";
    settings.user.email = "brennanmk2200@gmail.com";
    
    settings = { 
      credential.helper = "";
    };
  };
}
