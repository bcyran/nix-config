# Helpers for running rootless podman containers via
# `virtualisation.oci-containers` (with backend set to "podman").
{
  # mkLoopbackNetworkOptions :: [int] -> [string]
  #
  # Returns the `--network` option for a rootless container that needs access
  # to the given TCP ports of the host's loopback interface. The ports are
  # reachable only through the container's own 127.0.0.1. With an empty list
  # no option is returned, so Podman's default network (pasta) is used, which
  # has no access to the host's loopback.
  mkLoopbackNetworkOptions = allowedLoopbackPorts:
    if allowedLoopbackPorts == []
    then []
    else [
      ("--network=pasta:"
        + builtins.concatStringsSep ","
        (builtins.concatMap (port: ["-T" (toString port)]) allowedLoopbackPorts))
    ];

  # mkRootlessPodmanUser :: {user, group, home, uid} -> <config>
  #
  # Returns a config fragment that creates the system user `user` and the
  # matching group `group` used to run a rootless podman container, together
  # with the tmpfiles rule for the user's rootless container storage.
  mkRootlessPodmanUser = {
    user,
    group,
    home,
    uid,
  }: {
    users = {
      users.${user} = {
        inherit home uid group;
        createHome = true;
        isSystemUser = true;
        autoSubUidGidRange = true;
        linger = true;
      };
      groups.${group}.gid = uid;
    };

    systemd.tmpfiles.rules = [
      "d '/var/lib/containers/rootless/${toString uid}' 0700 ${user} ${group} - -"
    ];
  };
}
