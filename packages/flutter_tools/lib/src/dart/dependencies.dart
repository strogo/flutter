// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import '../artifacts.dart';
import '../base/file_system.dart';
import '../base/process.dart';

class DartDependencySetBuilder {
  DartDependencySetBuilder(this.mainScriptPath,
                           this.projectRootPath,
                           this.packagesFilePath);

  final String mainScriptPath;
  final String projectRootPath;
  final String packagesFilePath;

  Set<String> build() {
    final String skySnapshotPath =
        Artifacts.instance.getArtifactPath(Artifact.skySnapshot);

    final List<String> args = <String>[
      skySnapshotPath,
      '--packages=$packagesFilePath',
      '--print-deps',
      mainScriptPath
    ];

    String output = runSyncAndThrowStdErrOnError(args);

    final List<String> lines = LineSplitter.split(output).toList();
    final Set<String> minimalDependencies = new Set<String>();
    for (String line in lines) {
      if (!line.startsWith('package:')) {
        // We convert the uris so that they are relative to the project
        // root.
        line = fs.path.relative(line, from: projectRootPath);
      }
      minimalDependencies.add(line);
    }
    return minimalDependencies;
  }
}
