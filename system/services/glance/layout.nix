{
  lib,
  config,
  secrets,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glance;
in {
  config = mkIf cfg.enable {
    services.glance.settings = {
      branding = {
        custom-footer = "<p><b>[ゆめあみ]</b></p>";
        logo-text = "夢";
      };

      theme = {
        contrast-multiplier = 1.2;
        background-color = "240 21 15";
        primary-color = "217 92 83";
        positive-color = "115 54 76";
        negative-color = "347 70 65";
      };

      pages = let
        searchWidget = {
          type = "search";
          search-engine = "google";
          bangs = [
            {
              title = "youtube";
              shortcut = "!yt";
              url = "https://www.youtube.com/results?search_query={QUERY}";
            }
            {
              title = "nixpkgs";
              shortcut = "!np";
              url = "https://search.nixos.org/packages?channel=unstable&query={QUERY}";
            }
            {
              title = "nixopts";
              shortcut = "!no";
              url = "https://search.nixos.org/options?channel=unstable&query={QUERY}";
            }
            {
              title = "arxiv";
              shortcut = "!ar";
              url = "https://arxiv.org/search/?query=thing&searchtype=all&abstracts=show&order=-announced_date_first&size=50";
            }
          ];
        };
        sidebar = {
          size = "small";
          widgets = [
            {
              type = "clock";
              hour-format = "24h";
              timezones = [
                {
                  timezone = "America/New_York";
                  label = "New York";
                }
                {
                  timezone = "Asia/Tokyo";
                  label = "Tokyo";
                }
                {
                  timezone = "Asia/Singapore";
                  label = "Singapore";
                }
              ];
            }
            {
              type = "weather";
              location = "Lincoln, Nebraska, United States";
              hour-format = "24h";
            }
            {
              type = "markets";
              hide-header = true;
              markets = [
                {
                  symbol = "VEA";
                  name = "International";
                }
                {
                  symbol = "VTI";
                  name = "US";
                }
                {
                  symbol = "SPY";
                  name = "S&P 500";
                }
              ];
            }
            {
              type = "twitch-channels";
              collapse-after = 3;
              sort-by = "viewers";
              channels = [
                "theprimeagen"
                "theo"
                "lowleveltv"
                "piratesoftware"
                "dylanbeattie"
              ];
            }
          ];
        };
      in [
        ### --------------- HOME ---------------
        {
          name = "home";
          columns = [
            # sidebar
            sidebar

            # main column
            {
              size = "full";
              widgets = [
                searchWidget
                {
                  type = "split-column";
                  widgets = [
                    {
                      type = "group";
                      collapse-after = 5;
                      widgets = [
                        {
                          type = "reddit";
                          subreddit = "nixos";
                          collapse-after = 8;
                          show-thumbnails = true;
                        }
                        {
                          type = "reddit";
                          subreddit = "ProgrammerHumor";
                          collapse-after = 8;
                          show-thumbnails = true;
                        }
                        {
                          type = "reddit";
                          subreddit = "selfhosted";
                          collapse-after = 8;
                          show-thumbnails = true;
                        }
                        {
                          type = "reddit";
                          subreddit = "PoliticalHumor";
                          collapse-after = 8;
                          show-thumbnails = true;
                        }
                        {
                          type = "reddit";
                          subreddit = "Bogleheads";
                          collapse-after = 8;
                          show-thumbnails = true;
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "videos";
                  include-shorts = false;
                  channels = [
                    "UCYO_jab_esuFRV4b17AJtAw" # 3Blue1Brown
                    "UC7kIy8fZavEni8Gzl8NLjOQ" # Alex O'Connor
                    "UCkbwOi_U5CBkevtlVhuzWnA" # Backend Banter
                    "UC5--wS0Ljbin1TjWQX6eafA" # bigboxSWE
                    "UC9Z1XWw1kmnvOOFsj6Bzy2g" # Blackthornprod
                    "UC415bOPUcGSamy543abLmRA" # Cleo Abram
                    "UC0e3QhIYukixgh5VVpKHH9Q" # CodeBullet
                    "UCaSCt8s_4nfkRglWCvNSDrg" # CodeAesthetic
                    "UC9-y-6csu5WGm29I7JiwpnA" # Computerphile
                    "UCiGFu5PErgAg07tUHTLd7Xw" # Daily Dose Of Neuro & Vedal
                    "UCjJjavV8vOmu49a3vxPaWtQ" # Dylan Beattie
                    "UCODHrzPMGbNv67e84WDZhQQ" # fern
                    "UCsBjURrPoezykLs9EqgamOA" # Fireship
                    "UCqJ-Xo29CKyLTjn6z2XwYAw" # Game Maker's Toolkit
                    "UCG1uayRlzz3ahT8ISRdyw7Q" # Genetically Modified Skeptic
                    "UClHVl2N3jPEbkNJVx-ItQIQ" # HealthyGamerGG
                    "UCsXVk37bltHxD1rDPwtNM8Q" # Kurzgesagt – In a Nutshell
                    "UCpa-Zb0ZcQjTCPP1Dx_1M8Q" # LegalEagle
                    "UC6biysICWOJ-C3P4Tyeggzg" # Low Level
                    "UCYqsJbDDngvxb_rbHzHpYGA" # Magic The Noah
                    "UCLDnEn-TxejaDB8qm2AUhHQ" # Marcus Hutchins
                    "UCtHaxi4GTYDpJgMSGy7AeSw" # Michael Reeves
                    "UCTdw38Cw6jcm0atBPA39a0Q" # NDC Conferences
                    "UCLHmLrj4pHHg3-iBJn_CqxA" # Neuro-sama
                    "UCftyIWbjCPJs4KSrFciMqkA" # NintendoBlackCrisis
                    "UCMnULQ6F6kLDAHxofDWIbrw" # Pirate Software
                    "UC0VTA6PQH7nKKgRO8ptMatQ" # PoliticsGirl
                    "UCMOqf8ab-42UUQIdVoKwjlQ" # Practical Engineering
                    "UC1yNl2E66ZzKApQdRuTQ4tw" # Sabine Hossenfelder
                    "UCC9EjyMN_hx5NdctLBx5X7w" # Scammer Payback
                    "UCSju5G2aFaWMqn-_0YBtq5A" # Stand-up Maths
                    "UCEIwxahdLz7bap-VDs9h35A" # Steve Mould
                    "UCIxwcmTDBLniq6m7T3p_30Q" # Storytime With Jeff
                    "UCusb0SpT8elBJdbcEJS_l2A" # Tale Foundry
                    "UCFAiFyGs6oDiF1Nf-rRJpZA" # Technoblade
                    "UCxVPH8W2ayMey1-b0SY8rBQ" # The Coding Sloth
                    "UCRHXUZ0BxbkU2MYZgsuFgkQ" # The Spiffing Brit
                    "UCbRP3c757lWg9M-U7TyEkXA" # Theo - t3․gg
                    "UCtuO2h6OwDueF7h3p8DYYjQ" # Theo Rants
                    "UC8ENHE5xdFSwx71u3fDH5Xw" # ThePrimeagen
                    "UCUyeluBRhGPCW4rPe_UvBZQ" # ThePrimeTime
                    "UCVk4b-svNJoeytrrlOixebQ" # TheVimeagen
                    "UCbfYPyITQ-7l4upoX8nvctg" # Two Minute Papers
                    "UCHnyfMqiRRG1u-2MsSQLbXA" # Veritasium
                    "UCudx6plmpbs5WtWvsvu-EdQ" # Zeltik
                  ];
                }
              ];
            }
          ];
        }

        ### --------------- DEV ---------------
        {
          name = "dev";
          columns = [
            # sidebar
            sidebar

            # main content
            {
              size = "full";
              widgets = [
                searchWidget
                {
                  type = "group";
                  collapse-after = 5;
                  widgets = [
                    {
                      type = "hacker-news";
                      sort-by = "top";
                      extra-sort-by = "engagement";
                    }
                    {
                      type = "rss";
                      feeds = [
                        {
                          title = "New York Times";
                          url = "https://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml";
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "group";
                  collapse-after = 5;
                  widgets = [
                    {
                      type = "repository";
                      title = "yumeami";
                      repository = "c4patino/yumeami";
                      token = secrets.github.glance;
                      commits-limit = 8;
                    }
                    {
                      type = "repository";
                      title = "oasys-experiments";
                      repository = "c4patino/oasys-experiments";
                      token = secrets.github.glance;
                      commits-limit = 8;
                    }
                    {
                      type = "repository";
                      title = "free-range-zoo";
                      repository = "oasys-mas/free-range-zoo";
                      token = secrets.github.glance-oasys;
                      commits-limit = 3;
                    }
                    {
                      type = "repository";
                      title = "nixpkgs";
                      repository = "nixos/nixpkgs";
                      token = secrets.github.glance;
                    }
                  ];
                }
                {
                  type = "group";
                  widgets = [
                    {
                      type = "monitor";
                      sites = [
                        {
                          title = "forgejo";
                          icon = "si:forgejo";
                          url = "https://git.yumeami.sh";
                        }
                        {
                          title = "vaultwarden";
                          icon = "si:vaultwarden";
                          url = "https://vault.yumeami.sh";
                        }
                        {
                          title = "rustypaste";
                          icon = "si:pastebin";
                          url = "https://paste.yumeami.sh";
                        }
                        {
                          title = "uptime-kuma";
                          icon = "si:uptimekuma";
                          url = "https://monitor.yumeami.sh";
                        }
                        {
                          title = "ntfy";
                          icon = "si:ntfy";
                          url = "https://ntfy.yumeami.sh";
                        }
                        {
                          title = "grafana";
                          icon = "si:grafana";
                          url = "https://grafana.yumeami.sh";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
