{
  inputs = {
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";  
  };
  outputs = { self, nix-ros-overlay, nixpkgs }:
    nix-ros-overlay.inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nix-ros-overlay.overlays.default ];
        };

        python = with pkgs; [
          zlib
          python3
        ];

        rosPackages =  with pkgs.rosPackages.noetic; [
          rospy
          catkin
          ros-core
          roslaunch
          rosbash
          cv-bridge
          common-msgs
          ur-gazebo
          rviz
          rqt-gui-py
        ];

      in {
        devShells.default = pkgs.mkShell {
          name = "noetic";
          packages = with pkgs; [
            rosPackages
            python
          ];

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath python}:$LD_LIBRARY_PATH"
            export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib.outPath}/lib:$LD_LIBRARY_PATH"
            alias rsrc="source ~/ros_noetic/devel/setup.zsh"
          '';
      };
  });
}
