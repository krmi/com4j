# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with this repository.

## Environment

- **Java**: `c:\toolbase\openjdk\1.8.0.412` (set `JAVA_HOME` before building)
- **Maven**: `c:\toolbase-jre17\mvn\3.8.6`
- **Native toolchain**: Visual Studio 2022 (MSVC v143), Windows SDK 10.0.26100.0
- **JDK headers for native build**: `3rdparty/jdk/include` and `3rdparty/jdk/include/win32`

## Development Commands

### Building

- **Java only (no native DLL)**: Set `JAVA_HOME` to `c:\toolbase\openjdk\1.8.0.412`, then run `mvn clean install` from the root directory.
- **Full build with native DLL**: Run from a **Visual Studio Developer Command Prompt** (or after `call vcvars64.bat`):
  ```
  mvn clean install -Pnative-build
  ```
  This invokes `msbuild` via `exec-maven-plugin` to build `com4j.sln` (libffi, jnitl, com4j.dll), then copies the DLLs into the runtime JAR. The `com4j.tlb` is generated automatically by `midl.exe` as a pre-build step in `com4j.vcxproj`.
- **Custom MSBuild path**: Override with `-Dmsbuild.exe="C:\full\path\to\MSBuild.exe"`.
- **Debug native build**: Use `-DnativeBuildMode=Debug`.
- **Sync JNI headers**: Run `native/run_javah.bat` to regenerate header files from Java classes with native methods.

### Testing

- **Run all tests**: Run `mvn test` from the root directory.
- **Run a single test**: Tests use JUnit 4 and some have `main` methods — run them directly or via `mvn test -Dtest=ClassName`.
- The `test/` module is skipped by default (requires `com4j.dll` registered via `regsvr32`). Enable with `-Dcom4j.test.skip=false`.

### Tools

- **Type Library Importer (`tlbimp`)**:
  - Can be used as an Ant task.
  - Can be run as a JAR: `java -jar tlbimp.jar -o <output> -p <package> "<path_to_exe>"`.
- **Maven Mojo**: The `maven-com4j-plugin` provides a `gen` goal to automate code generation from COM type libraries.

## Architecture and Structure

This project is a Java/COM bridge that provides type-safe interaction with COM components.

- `runtime`: The core library containing the Java classes for COM object handling, variant types, and dispatch logic.
- `tlbimp`: A tool for importing COM Type Libraries and generating the corresponding Java definitions.
- `native`: Contains the C/C++ source and VS2022 project files for the native DLL used by `runtime`.
- `libffi`: Contains the Foreign Function Interface library (built as a static lib by the VS solution).
- `jnitl`: JNI Template Library — a small static library for JNI helper operations.
- `maven-com4j-plugin`: A Maven plugin that integrates the `tlbimp` functionality into the Maven build lifecycle.
- `distribution`: Contains artifacts for distribution.
- `samples`: A collection of examples demonstrating how to use `com4j` with various technologies like Excel, iTunes, Word, and WMI.

## Key Files and Directories

- `pom.xml`: Main Maven configuration for the multi-module project (version 2.2-SNAPSHOT). No parent POM, Java 1.8 target.
- `com4j.sln`: VS2022 solution building libffi, jnitl, and com4j.dll.
- `native/com4j.vcxproj`: Main native DLL project. Depends on `libffi.lib` and `jnitl-dll.lib`. Pre-build step generates `com4j.tlb` from `com4j.idl` via `midl.exe`.
- `native/com4j.idl`: IDL file defining COM interfaces. Compiled automatically by the vcxproj pre-build step.
- `native/safearray.h`: SAFEARRAY conversion between Java arrays and COM SAFEARRAYs. Contains RAII-based marshalling classes.
- `native/variant.cpp`: VARIANT conversion logic. `convertToVariant()` returns `new VARIANT()` or NULL on failure — callers must check for NULL.
- `native/xducer2.h`: Transducers for VARIANT and COM object conversion. `VariantXducer::toNative` returns an initialized VT_EMPTY VARIANT when conversion fails.
- `jnitl/include/jnitl.h`: JNI template library header. Uses `#pragma comment(lib, ...)` for linking (selects `jnitl-dll.lib` in Release with `/MD`).
- `src/site`: Contains documentation and tutorial materials.
- `samples/<sample_name>/build.xml`: Ant files for building and running individual samples.
