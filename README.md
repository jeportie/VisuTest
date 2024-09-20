# VisuTest Plugin Alpha_version - Project Start Recap

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
    │   ├── libfoo.a           # Example static library
    │   └── libbar.so          # Example shared library
    ├── assets/
    │   ├── logo.png           # Project logo or image assets
    │   └── config.json        # Configuration files or templates
    ├── main.c
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
    ├── ycm_extra_conf.py      # Configuration for YouCompleteMe plugin
    ├── .vimspector.json       # Configuration file for Vimspector plugin
    ├── Makefile
    └── .gitignore
```

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
- Press **Space** on a test suite name to display individual test units state using icons.
- Updates dynamically based on `LastTest.log`.
<img width="327" alt="Screenshot 2024-09-20 at 22 53 05" src="https://github.com/user-attachments/assets/ae9bb0f2-726c-477b-80ae-86e3f619f7b5">

#### 5. Popup Window for Test Suite Logs

**Purpose**: Show detailed test logs for a specific test suite.

**Behavior**:

- Press **Enter** on a test suite name in the vertical window to open a popup.
- Displays:
  - Command execution details.
  - Start time.
  - Test output.
  - Results from `LastTest.log`.
<img width="776" alt="Screenshot 2024-09-20 at 22 59 54" src="https://github.com/user-attachments/assets/bdf67cce-dfa6-4d75-af04-063235bd6f8d">

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

## Notes

### **Window init Strategy Overview**

1. **Test Suite Names Extraction**:
   - **Source**: `test_src/` directory.
   - **Approach**: Extract the test suite names from the `.c` files in `test_src/`.
     - Each `.c` file in `test_src/` represents a test suite.
     - The file name (e.g., `test_function_name1.c`) corresponds to the test suite name.

2. **Test Unit Function Names Extraction**:
   - **Source**: Individual test suite files (i.e., `.c` files in `test_src/`).
   - **Approach**: Parse each test suite `.c` file to extract function names prefixed with `test_`, which typically represent individual test cases.
     - Scan for functions in the test suite that match the pattern `void test_*()` (or similar).

---
### **Detailed Steps**

#### **1. Load Test Suite Names**

- **Step 1.1**: Navigate through the `test_src/` directory and gather all `.c` files.
- **Step 1.2**: Strip the `test_` prefix from the filenames to get the corresponding test suite names.
  
**Example**:
- `test_function_name1.c` -> `function_name1`
- `test_function_name2.c` -> `function_name2`

#### **2. Parse Test Suite Files for Test Units**

- **Step 2.1**: For each `.c` file in `test_src/`, open the file and scan for functions that represent test units. These typically have the prefix `test_` and follow a naming convention.
- **Step 2.2**: Collect all function names that match the `test_*` pattern, and list them under their respective test suite in the vertical window.

**Example**:
- File: `test_function_name1.c`
  - Test Units:
    - `void test_case1_function_name1()`
    - `void test_case2_function_name1()`

#### **3. Display in Vertical Window**

- **Step 3.1**: Use a Vim window (1/4 size vertical window as planned) to display the test suites and their corresponding test units.
- **Step 3.2**: Format the window such that each test suite is listed, followed by an indented list of its test units.

**Example Display**:

```
Test Suites:
  function_name1
    - test_case1_function_name1
    - test_case2_function_name1
  function_name2
    - test_case1_function_name2
```

---

### **Implementation Thoughts**

1. **Efficiency**:
   - You only need to scan the `test_src/` directory and `.c` files once when opening Vim or refreshing the test window. A function can handle this and update the vertical window accordingly.

2. **Regular Expression for Test Functions**:
   - You can use a regex pattern like `void\s+test_\w+\s*\(` to match the function declarations inside the `.c` test files. This pattern will find all test units and is highly adaptable for different function naming conventions.

3. **Handling Edge Cases**:
   - **Empty Test Suites**: Handle cases where a `test_*.c` file might not have any test functions.
   - **Subdirectories**: If the `test_src/` directory contains subdirectories, ensure the parser handles them recursively.

4. **Real-Time Updates**:
   - Implement a refresh command that users can trigger to update the list if they add new tests while Vim is running.

5. **Visual Enhancements**:
   - You could further enhance the visual display by using icons (e.g., pass/fail symbols next to the test units once executed).

---

### **Tools to Use**

- **Vimscript**:
  - Use `globpath()` to list files in the `test_src/` directory.
  - Use `readfile()` to read the content of the `.c` files and `matchlist()` or `substitute()` with regex to extract function names.
  
- **External Scripts (Optional)**:
  - If performance becomes an issue with large test suites, you might consider using an external script (e.g., Python) to parse the files and return the results to Vim.

---

### **Potential Enhancements**

- **Sorting or Filtering**: Allow the user to filter or sort the test units displayed in the vertical window by status (e.g., passed, failed) or test name.
- **Interactive Execution**: Make the test suite and test unit names clickable, allowing users to trigger the execution of individual test units directly from the vertical window.

---
