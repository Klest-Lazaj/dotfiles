{ pkgs, inputs, ... }:
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true; # vscode

  # HP 255 G10's Realtek RTL8852BE Wi-Fi hard-freezes without these (ArchWiki: HP_255_G10).
  boot.kernelParams = [
    "rtw89_pci.disable_aspm_l1=1"
    "rtw89_pci.disable_aspm_l1ss=1"
  ];

  programs.hyprland.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.thunar.enable = true;
  programs.xfconf.enable = true; # Thunar saves its preferences here
  services.gvfs.enable = true; # trash and USB drives in Thunar
  services.tumbler.enable = true; # thumbnails

  services.gnome.gnome-keyring.enable = true; # VS Code stores logins here
  programs.nix-ld.enable = true; # lets nvm's node and other downloaded binaries run

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.sessionVariables.NIXOS_OZONE_WL = "1"; # VS Code runs natively on Wayland

  fonts.packages = [ pkgs.meslo-lgs-nf ];

  environment.systemPackages = with pkgs; [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    vscode
    ghostty
    fuzzel
    waybar
    brightnessctl
    git

    # What home/.zshrc expects
    starship
    zoxide
    fzf
    fd
    bat
    direnv
    diff-so-fancy
    nnn
    btop
  ];
}
