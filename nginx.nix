{ pkgs, dockerTools, buildEnv, ... }:

let
  conf = pkgs.writeText "nginx.conf" ''
    daemon off;

    pid /dev/null;

    events {
    }

    http {
      access_log off;
      server {
        listen       80;
        server_name  localhost;
        location / {
            root   ${pkgs.nginx}/html;
            index  index.html;
        }
      }
    }

  '';
in dockerTools.buildImage {
  name = "nginx";
  tag = "latest";
  created = "now";

  copyToRoot = buildEnv {
    name = "env";
    ignoreCollisions = true;
    paths = [
      dockerTools.fakeNss
      pkgs.busybox
      pkgs.bash
      pkgs.nginx
    ];
    pathsToLink = [ "/bin" "/etc" ];
  };

  extraCommands = ''
    mkdir tmp
    chmod a+w tmp
  '';

  config = {
    Cmd = [
      "${pkgs.nginx}/bin/nginx"
      "-c" "${conf}"
      "-e" "/dev/null"
      "-q"
    ];
    User = "nobody";
    Group = "nogroup";
  };
}
