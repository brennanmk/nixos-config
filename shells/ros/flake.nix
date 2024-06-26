{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";  # IMPORTANT!!!
  };
  outputs = { self, nix-ros-overlay, nixpkgs }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };
        pythonPackages = pkgs.python3.withPackages(ps: with ps; [
            numpy
            ray
            pandas
            opencv4
        ]);
      in {
        devShells.default = pkgs.mkShell {
          name = "noetic";
          packages = with pkgs.rosPackages.noetic; [
            rospy
            catkin
            ros-core
            roslaunch
            rosbash
            cv-bridge
            common-msgs
            rviz
            pythonPackages
          ];

        };
      });
}
