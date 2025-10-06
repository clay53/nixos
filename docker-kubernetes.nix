{ pkgs, ... }: {
    virtualisation = {
        docker = {
          enable = true;
          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };
        # For kubernetes
        containerd = {
          enable = true;
        };
    };

    environment.systemPackages = with pkgs; [
        # For pennlabs
        kind
        kubectl
        awscli2
        k9s
    ];

    environment.sessionVariables = {
        CONTAINERD_ENABLE_DEPRECATED_PULL_SCHEMA_1_IMAGE = 1;
    };
}
