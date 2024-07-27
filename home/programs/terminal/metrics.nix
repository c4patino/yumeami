{ pkgs, lib, config, ... }: {
    options = {
        bottom.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable bottom";
        };

        nvtop.enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable nvtop";
        };
    };

    config = {
        home.packages = with pkgs; [ 
            (lib.mkIf config.nvtop.enable nvtopPackages.nvidia)
        ];

        programs.bottom = lib.mkIf config.bottom.enable {
            enable = true;
            settings = {
                flags = {
                    current_usage = true;
                    group_processes = true;
                    case_sensitive = false;
                    mem_as_value = true;
                    enable_gpu = true;
                    disable_advanced_kill = true;
                    unnormalized_cpu = false;
                    temperature_type = "c";
                };
            };
        };
    };
}
