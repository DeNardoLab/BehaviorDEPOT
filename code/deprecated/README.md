# Deprecated MATLAB utilities

This folder contains legacy utilities that are no longer called by the
BehaviorDEPOT app or analysis pipeline.

- `convertHumanAnnotations.m` is superseded by the app-accessible
  `convertHumanAnnotations_BD.m`.
- `saveAnalysis.m` is superseded by `saveDataPrep.m` and `saveBehAnalysis.m`.
- `polygeom.m` is superseded by the local implementation in
  `calculateExploration.m`.

The app adds the code folder recursively to the MATLAB path, so these utilities
remain available for existing command-line workflows. New code should not call them.
