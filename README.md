## Quickstart

```
# NOTE: you must have virtualenv installed for the quickstart option,
# otherwise you can follow the manual steps in the next section
./quickstart.sh
```

## Manual Start
```
cd <REPO_ROOT_DIR>/server
pip install flask
python server.py &
open <REPO_ROOT_DIR>/index.html
```

## Dev Workflow
First: [Download and install Elm](http://elm-lang.org/install)
```
./build_dev.sh
# NOTE: Elm-CSS changes must be manually recompiled:
#       elm css StyleSheets.elm

```

### Solution Commentary
- Basic web knowledge (html/js/css)
- Framework experience + choices
  - Elm is a reactive programming framework (e.g. React/Redux stack), but it has a number of unique features and advantages that made it a compelling choice for this project:
    - type system
    - compiler to catch bugs before runtime
    - immutable data structures
    - performant (virtual DOM)
    - Elm CSS preprocessor
    - easy to use build/package system (updates elm-package.json whenever a new package is installed)
    - fun to use
- UI architecture + design approach
  - stub out models/views
  - add Actions
  - make models/views real
  - hack together a simple server
  - TODO unify naming conventions
  - TODO consider folder systems
- API design, requirements and usage
  - one JSON file per user (currently only supports "library" user)
  - TODO parameterize the server endpoint
- Security considerations
  - TODO
- Use of tooling
  - elm-package.json, elm live, elm package install, elm css
