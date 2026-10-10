# Helpers for running rootless podman containers via
# `virtualisation.oci-containers` (with backend set to "podman").
{
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
