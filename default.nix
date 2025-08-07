let

  pkgs = import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2025-08-04.tar.gz") {};

  rpkgs = builtins.attrValues {
   inherit (pkgs.rPackages)
     quarto
     reticulate
     rix
     ;
  };

  pyconf = builtins.attrValues {
    inherit (pkgs.python313Packages) 
      pandas
      pip
      polars
      pyarrow
      pytest
      scikit-learn
      ;
  };

  tex = (pkgs.texlive.combine {
   inherit (pkgs.texlive)
     scheme-small
     amsmath
     framed
     fvextra
     environ
     fontawesome5
     orcidlink
     pdfcol
     tcolorbox
     tikzfill
     ;
  });

  system_packages = builtins.attrValues {
   inherit (pkgs)
     R
     glibcLocalesUtf8
     quarto
     uv
     ;
  };

  github_pkgs = [

   (pkgs.rPackages.buildRPackage {
     name = "myPackage";
     src = pkgs.fetchgit {
       url = "https://github.com/b-rodrigues/myPackage";
       branchName = "master";
       rev = "e9d9129de3047c1ecce26d09dff429ec078d4dae";
       sha256 = "sha256-u/tIo9L+S12ssGNlQu7AVHG5W5OTpXZ+rHn1Pz6RIKs=";
     };
     propagatedBuildInputs = builtins.attrValues {
       inherit (pkgs.rPackages) 
         dplyr
         janitor
         rlang;
         };
     })

  ];

  pyclean = pkgs.python313Packages.buildPythonPackage rec {
    pname = "pyclean";
    version = "0.1.0";
    src = pkgs.fetchgit {
      url = "https://github.com/b-rodrigues/pyclean";
      rev = "174d4d482d400536bb0d987a3e25ae80cd81ef3c";
      sha256 = "sha256-xTYydkuduPpZsCXE2fv5qZCnYYCRoNFpV7lQBM3LMSg=";
    };
    pyproject = true;
    propagatedBuildInputs = [ pkgs.python313Packages.pandas pkgs.python313Packages.setuptools ];
    # Add more dependencies to propagatedBuildInputs as needed
  };

in
  pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then  "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";

    buildInputs = [ rpkgs pyconf pyclean tex system_packages github_pkgs ];

  shellHook = ''
    export PYTHONPATH=$PWD/pyclean/src:$PYTHONPATH
  '';
      
  }
