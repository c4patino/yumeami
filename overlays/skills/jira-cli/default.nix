{...}: final: prev: {
  # The official jira-cli skill lives in the upstream repo's skills/ dir, but
  # it was added after v1.7.0 (what nixpkgs packages), so fetch the SKILL.md
  # directly, pinned to a commit. Drop this once a release ships the skill.
  jira-cli-skill = prev.runCommand "jira-cli-skill" {} ''
    install -Dm444 ${prev.fetchurl {
      name = "jira-cli-SKILL.md";
      url = "https://raw.githubusercontent.com/ankitpokhrel/jira-cli/9b593fd47518d207897878cc31ac3000231151f1/skills/jira-cli/SKILL.md";
      hash = "sha256-P0DbR8XMFEnKPd4tnItMc5ybueNe7Txu933HYWLHbwg=";
    }} $out/SKILL.md
  '';
}
