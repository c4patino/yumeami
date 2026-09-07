{...}: final: prev: let
  pinnedXmlschema = prev.python3Packages.xmlschema.overridePythonAttrs (old: {
    version = "2.5.1";
    src = prev.fetchPypi {
      pname = "xmlschema";
      version = "2.5.1";
      hash = "sha256-OjxVFIYxf+k1Xoj90alXHmLQUokEmEXOJI9xzU9FWhw=";
    };

    build-system = [
      prev.python3Packages.setuptools
    ];

    pyproject = false;
  });
in {
  python3 = prev.python3.override {
    packageOverrides = pythonFinal: pythonPrev: {
      pysaml2 = pythonPrev.pysaml2.overridePythonAttrs (old: {
        doCheck = false;
        propagatedBuildInputs = map (
          dep:
            if (dep.pname or "") == "xmlschema"
            then pinnedXmlschema
            else dep
        ) (old.propagatedBuildInputs or []);
      });
    };
  };
}
