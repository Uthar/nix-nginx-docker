{ pkgs, dockerTools, buildEnv, ... }:

let
  mkdir = name: pkgs.runCommand name { inherit name; } ''
    mkdir -p $out/$name
    chmod a+w $out/$name
  '';
  conf = pkgs.writeText "nginx.conf" ''
    worker_processes  1;

    daemon off;

    error_log /dev/null;

    pid /dev/null;

    events {
      worker_connections  1024;
    }

    http {
      access_log /dev/null;
      server {
        listen       80;
        server_name  localhost;
        location / {
            root   ${pkgs.nginx}/html;
            index  index.html index.htm;
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
    mkdir tmp var
    chmod a+w tmp var
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
