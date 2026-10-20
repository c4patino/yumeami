{...}: final: prev: {
  gh-skill = prev.runCommand "gh-skill-${prev.gh.version}" {} ''
    install -Dm444 ${prev.gh.src}/skills/gh/SKILL.md $out/SKILL.md
  '';
}
