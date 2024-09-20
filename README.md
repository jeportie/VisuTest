# VisuTest Plugin Alpha_version - Comprehensive Project Recap

## Introduction

VisuTest is a Vim plugin designed to enhance the C development workflow by integrating automated testing, real-time feedback, and intelligent test generation directly into the editor. By leveraging existing tools like `vim-dispatch`, `tmux`, and `vim-rooter`, along with future features such as ChatGPT API integration, VisuTest aims to streamline the coding and testing process for developers.

---

## Functionality Description

### Group 1: Project Structure Management

#### 1. Standardized Project Folder Layout

**Purpose**: Enforce a specific project structure for consistency and ease of navigation.

**Project Hierarchy**:

```
└── Project Root
    ├── include/
    │   ├── project.h
    │   └── defines.h
    ├── lib/
    ├── assets/
    ├── main.c
    ├── Makefile
    ├── src/
    │   ├── sub_folder_name1/
    │   │   └── function_name1.c
    │   ├── function_name2.c
    │   ├── function_name3.c
    │   └── [...].c
    ├── test_src/
    │   ├── CMakeLists.txt
    │   ├── sub_folder_name1/
    │   │   └── test_function_name1.c
    │   ├── test_function_name2.c
    │   ├── test_function_name3.c
    │   └── test_[...].c
    ├── .gitignore
    ├── vimspector.json
    └── ycm_extra_conf.py
```

**Explanation**:

- **include/**: Header files, including `project.h` where functions are declared.
- **lib/**: External libraries or shared code.
- **assets/**: Static assets such as images, icons, or other resources.
- **src/**: Source files, each containing one public function.
  - **sub_folder_name1/**: A subdirectory containing `function_name1.c`.
  - **function_name2.c**, **function_name3.c**, etc.: Source files in the root of `src/`.
- **test_src/**: Test source files corresponding to each function in `src/`, maintaining the same directory structure.
  - **CMakeLists.txt**: Build configuration file, crucial for compiling tests.
  - **sub_folder_name1/**: Mirrors `src/` subdirectories, containing `test_function_name1.c`.
- **.gitignore**: Specifies intentionally untracked files to ignore.
- **vimspector.json**: Configuration file for Vimspector, a Vim plugin for debugging.
- **main.c**: Entry point of the application.
- **Makefile**: For building the project.
- **ycm_extra_conf.py**: Configuration for YouCompleteMe or similar tools.

**Rules**:

- **One Function per File**:
  - Each `.c` file in `src/` contains a single public function, with up to 4 static helper functions.
  - `.c` files are named after their public function.
  - Functions are declared in `project.h`.
- **Test Files**:
  - Located in `test_src/`, mirroring the directory structure of `src/`.
  - Prefixed with `test_` (e.g., `test_function_name1.c`).
  - For example, `src/sub_folder_name1/function_name1.c` has a test file at `test_src/sub_folder_name1/test_function_name1.c`.
- **Directory Hierarchy Management**:
  - The plugin manages folder structures from `src/` to `test_src/`, ensuring test files correspond to their source files.

#### 2. Auto-Creation of Test Files for New Functions

**Purpose**: Streamline the test creation process.

**Behavior**:

- Detects new `.c` files added to `src/`, including subdirectories.
- Automatically creates corresponding test files in `test_src/`, maintaining the same directory structure.
- Updates `CMakeLists.txt` accordingly.
- New test files are in **pending approval** status.

#### 3. Automatic CMakeLists.txt Update for Test Files

**Purpose**: Keep the build configuration up-to-date with new tests.

**Behavior**:

- Updates `CMakeLists.txt` in `test_src/` whenever a new test suite is created or approved.
- Manages the directory hierarchy from `src/` to ensure test files are correctly linked.
- Ensures inclusion of all tests in the build process.

### Group 2: User Interface

#### 4. Vertical Window Display

**Purpose**: Display test suite statuses in a vertical window occupying 1/4 of the Vim window.

**Behavior**:

- Shows test suites with their current state using icons:
  - **Empty circle**: Test not run.
  - **Green circle**: Test passed.
  - **Red circle**: Test failed.
- Updates dynamically based on `LastTest.log`.

#### 5. Popup Window for Test Suite Logs

**Purpose**: Show detailed test logs for a specific test suite.

**Behavior**:

- Press **Enter** on a test suite name in the vertical window to open a popup.
- Displays:
  - Command execution details.
  - Start time.
  - Test output.
  - Results from `LastTest.log`.

#### 6. Test Suite Approval System

**Purpose**: Allow users to approve, edit, or reject auto-generated test suites.

**Behavior**:

- Newly generated tests are marked as **pending approval**.
- User options:
  - **Approve**: Test is added and run.
  - **Edit**: Modify the test before approving.
  - **Reject**: Discard the test if unnecessary.

### Group 3: Test Execution

#### 7. Real-Time Test Execution

**Purpose**: Automatically run tests when exiting insert mode.

**Behavior**:

- Triggers `CTest` upon exiting insert mode.
- Updates test results in real-time.
- Reflects each test suite's status immediately.

#### 8. Real-Time Test Status Update

**Purpose**: Provide immediate feedback on code changes.

**Behavior**:

- Dynamically updates test icons based on the latest test results.
- Parses `LastTest.log` after each test run.
- Reflects pass, fail, or not tested statuses.

### Group 4: Integration with Existing Vim Plugins

#### 9. Integration with Existing Vim Plugins

- **vim-dispatch & tmux**

  - **Purpose**: Run `CMake`, `make`, and `CTest` asynchronously.
  - **Behavior**:
    - Executes build and test commands in the background without interrupting the workflow.
    - Utilizes `vim-dispatch` and `tmux` for seamless asynchronous operations.

- **vim-rooter**

  - **Purpose**: Automatically set the project’s root directory.
  - **Behavior**:
    - Detects the project root based on the standardized folder layout.
    - Ensures smooth access to the CMake build system and source files.

### Group 5: ChatGPT Integration

#### 10. ChatGPT Integration for Test Generation

**Purpose**: Automatically generate C `Check` test suites in real-time.

**Behavior**:

- Analyzes `.h` and `.c` files to detect new functions.
- Proposes a `Check` test suite based on:
  - Function prototype.
  - Existing code context.
- Marks the test as pending until user approval.

*(Note: ChatGPT integration will be implemented at the end, as per the latest instructions.)*

---

## Feature Summary Table

| **Feature Group**               | **Feature**                          | **Description**                                                                                             | **Plugins/Tools Used**             |
|---------------------------------|--------------------------------------|-------------------------------------------------------------------------------------------------------------|------------------------------------|
| **Project Structure Management**| Standardized Project Folder Layout   | Enforce project structure with one function per file and organized test files, including path mirroring.     | Custom Plugin Logic                |
|                                 | Auto-Creation of Test Files          | Automatically create test files in `test_src/` for new source files in `src/`, managing directory hierarchy. | Custom Plugin Logic                |
|                                 | Auto CMakeLists.txt Update for Tests | Automatically update `CMakeLists.txt` when new tests are added or approved, considering folder structure.    | Custom Plugin Logic                |
| **User Interface**              | Vertical Window                      | 1/4 size vertical window displaying test suite statuses with icons.                                          | Vim                                 |
|                                 | Test Suite Logs Popup                | Press **Enter** on a test suite to display detailed test output from `LastTest.log`.                         | Vim                                 |
|                                 | Test Suite Approval System           | Allow user to approve, edit, or reject auto-generated test suites.                                           | Custom Plugin Logic                |
| **Test Execution**              | Real-Time Test Execution on Insert Exit | Automatically run `CTest` upon exiting insert mode and update test results.                                  | Vim, vim-dispatch                  |
|                                 | Real-Time Test Status Update         | Dynamically update test icons based on test results after each run.                                          | Vim, CTest                         |
| **Integration**                 | Integration with Existing Vim Plugins| Run `CMake`, `make`, and `CTest` asynchronously using `vim-dispatch` and `tmux`; auto root detection.        | vim-dispatch, tmux, vim-rooter     |
| **ChatGPT Integration**         | ChatGPT API for Test Generation      | Automatically generate C `Check` test suites for new functions in real-time. *(Implemented at the end)*      | ChatGPT API                        |

---

## VisuTest Plugin Project Structure

```
visutest/
├── autoload/
│   └── visutest.vim            # Core functions loaded on demand
├── plugin/
│   └── visutest.vim            # Main plugin script loaded on startup
├── doc/
│   └── visutest.txt            # Plugin documentation for :help
├── ftplugin/
│   └── c.vim                   # Filetype-specific settings for C files
├── syntax/
│   └── visutest.vim            # Syntax highlighting definitions (if any)
├── scripts/
│   ├── folder_watcher.py       # Monitors src/ directory for new files
│   ├── test_generator.py       # Generates tests via ChatGPT API
│   ├── cmakelists_updater.py   # Updates CMakeLists.txt automatically
│   └── utils.py                # Common utility functions
├── resources/
│   ├── icons/
│   │   ├── empty_circle.png
│   │   ├── green_circle.png
│   │   └── red_circle.png
│   └── assets/                 # Additional assets
├── tests/
│   └── test_visutest.vim       # Automated tests for plugin functionality
├── config/
│   ├── default_config.vim      # Default configuration settings
│   └── vimspector.json         # Vimspector configuration file
├── .gitignore                  # Git ignore file
├── README.md                   # Project overview and instructions
├── LICENSE                     # Licensing information
└── setup.sh                    # Script to install dependencies
```

**Explanation of the File Structure**:

- **autoload/**: Contains deferred-loading Vim functions for efficiency.
- **plugin/**: Main plugin script that initializes VisuTest.
- **doc/**: Help files accessible via `:help visutest`.
- **ftplugin/**: Filetype-specific settings to enhance C file editing.
- **syntax/**: Syntax highlighting definitions if required.
- **scripts/**: External scripts (Python) handling folder watching, test generation, and CMake updates.
- **resources/**:
  - **icons/**: Static icons used in the UI.
  - **assets/**: Additional assets needed by the plugin.
- **tests/**: Contains tests to ensure plugin reliability.
- **config/**:
  - **default_config.vim**: Default settings for the plugin.
  - **vimspector.json**: Configuration for the Vimspector plugin.
- **.gitignore**: Specifies intentionally untracked files to ignore.
- **setup.sh**: Automates the installation of dependencies.

---

## Recap of the Structural Implementation Plan

### Phase 1: Initial Setup and Core Integration

1. **Project Initialization**

   - **Version Control**: Initialize Git repository.
   - **Project Structure**: Establish directory layout, including `lib/` and `assets/` folders.

2. **Integration with Existing Vim Plugins**

   - **vim-rooter**: Ensure automatic project root detection.
   - **vim-dispatch & tmux**: Configure for asynchronous operations.

3. **Standardized Project Folder Layout Enforcement**

   - Implement checks for correct folder structure, including managing directory hierarchy from `src/` to `test_src/`.
   - Enforce naming conventions and path mirroring for test files.

### Phase 2: Documentation and User Guide Development

4. **ReadMe and Documentation Creation**

   - **Purpose**: Build all manuals and documentation before coding.
   - **Tasks**:
     - Create a comprehensive `README.md` covering:
       - Project overview.
       - Installation instructions.
       - Usage guide.
       - Feature descriptions.
     - Develop user manuals and help files (`doc/visutest.txt`).
     - Outline contribution guidelines and code of conduct.

### Phase 3: User Interface Development

5. **Vertical Window Implementation**

   - Create a vertical window to display test suites and statuses.
   - Design iconography for test states.

6. **Popup Window for Test Suite Logs**

   - Implement functionality to display detailed logs on demand.
   - Parse and present data from `LastTest.log`.

7. **Test Suite Approval System**

   - Mark auto-generated tests as pending.
   - Provide user interface for approval, editing, or rejection.

### Phase 4: Test Execution and Status Updates

8. **Real-Time Test Execution on Insert Mode Exit**

   - Detect exit from insert mode.
   - Trigger asynchronous `CTest` execution.

9. **Real-Time Test Status Update**

   - Monitor `LastTest.log` for changes.
   - Update test statuses in the vertical window.

### Phase 5: Automated Test File Management

10. **Auto-Creation of Test Files for New Functions**

    - Implement folder watcher for `src/`, including subdirectories.
    - Generate corresponding test files in `test_src/`, maintaining directory structure.

11. **Automatic CMakeLists.txt Update**

    - Programmatically update `CMakeLists.txt` when new tests are added.
    - Ensure correct linking and inclusion of tests, considering folder hierarchy.

### Phase 6: ChatGPT Integration (Implemented at the End)

12. **Implement ChatGPT API Integration**

    - Set up secure API access.
    - Develop communication module for API interaction.

13. **Automatic Test Generation Logic**

    - Analyze code to detect new functions.
    - Use ChatGPT to generate test suites.

14. **Test Suite Approval System Enhancement**

    - Integrate ChatGPT-generated tests into the approval workflow.

### Phase 7: Enhancements and Optimizations

15. **Performance Optimization**

    - Implement debounce mechanisms to prevent excessive triggers.
    - Optimize code for efficiency.

16. **Error Handling and Notifications**

    - Develop robust error handling.
    - Inform users of issues through notifications.

17. **User Configuration Options**

    - Allow customization via configuration files or Vim settings.
    - Document configurable options.

### Phase 8: Testing and Finalization

18. **Automated Testing of the Plugin**

    - Write tests for plugin features.
    - Set up continuous integration.

19. **Prepare for Release**

    - Versioning and tagging.
    - Compatibility checks across environments.

20. **Community Engagement**

    - Set up channels for feedback and support.
    - Provide contribution guidelines.

---
