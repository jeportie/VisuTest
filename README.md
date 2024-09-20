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
### **Exec Strategy Recap and Structure with `vim-dispatch`, `tmux`, and `vim-rooter` Integration**

In this enhanced strategy, we will use **vim-dispatch** and **tmux** for asynchronous test execution and monitoring, while **vim-rooter** simplifies the task of locating the project root. These tools will allow us to improve the overall developer experience by running tests asynchronously and updating the Vim plugin window in real-time as tests complete.

#### **Key Features:**
1. **Sequential Execution with Asynchronous Control**:
   - Tests are run one by one asynchronously using `vim-dispatch` and **tmux**, updating the window after each test suite completes.

2. **Real-Time Monitoring**:
   - Monitor the `LastTest.log` file for real-time updates on test suite results using **tmux** windows to capture outputs.
   - Update the state of each test suite in the Vim plugin window asynchronously.

3. **Interactive Features**:
   - **Popup Window**: Display detailed output for a specific test suite in a popup window when pressing **Enter**.
   - **Test Unit States**: Display and update the state of each test unit when pressing **Space**.

4. **Test Suite States**:
   - **Waiting**: Before the test suite starts.
   - **Running**: When the test suite is currently being executed.
   - **Passed**: When the test suite finishes successfully.
   - **Failed**: If the test suite fails.

---

### **High-Level Process Flow with Asynchronous Execution**

| **Step**                    | **Action**                                                   | **Details**                                                  |
|-----------------------------|--------------------------------------------------------------|--------------------------------------------------------------|
| **1. Set Project Root with `vim-rooter`** | `vim-rooter` automatically sets the root directory for the project | Ensures that `CMake`, `Make`, and `CTest` are run in the correct project context |
| **2. Start Test Execution with `vim-dispatch`**  | Run `CMake`, `Make`, and `CTest` sequentially in **tmux** windows via `vim-dispatch` | Asynchronous execution allows tests to run without blocking Vim |
| **3. Monitor `LastTest.log` in a Separate `tmux` Window** | Use **tmux** to monitor the `LastTest.log` file in real time as each test suite finishes | Captures log updates in real time and updates Vim |
| **4. Update Test Suite States** | As results appear in `LastTest.log`, update the Vim window with the test suite's current state | Each test suite moves from "Waiting" → "Running" → "Passed"/"Failed" based on log entries. |
| **5. Show Detailed Output in Popup** | When a user presses **Enter** on a test suite, show its detailed log in a popup | The test suite’s specific output from `LastTest.log` is parsed and displayed. |
| **6. Parse and Show Test Units** | When pressing **Space** on a test suite, show and update the state of each test unit (individual test cases) | Use `LastTest.log` to determine the status of each test unit and display them interactively. |

---

### **Modifications and Enhancements with `vim-dispatch`, `tmux`, and `vim-rooter`**

#### **1. Popup Window with Test Output on Enter**
- **Trigger**: When a user presses **Enter** on a test suite in the vertical window.
- **Action**: Open a buffer (popup window) that displays the **detailed output** of the test suite.
- **Output Example**:
  
  ```
  ----------------------------------------------------------
  1/1 Testing: ft_split_test
  1/1 Test: ft_split_test
  Command: "/home/user/test/test_ft_split"
  Directory: /home/user/test
  "ft_split_test" start time: Sep 20 15:05 CEST
  Output:
  ----------------------------------------------------------
  Running suite(s): ft_split
  100%: Checks: 5, Failures: 0, Errors: 0
  🟢  All tests passed
  <end of output>
  Test time =   0.00 sec
  ----------------------------------------------------------
  ```
  
- **How It Works**:
  - Parse the `LastTest.log` file to extract the detailed output for the corresponding test suite.
  - Display the log inside a new buffer in Vim when triggered by **Enter**.

#### **2. Parsing and Updating Test Unit States**
- **Trigger**: When a user presses **Space** on a test suite in the vertical window.
- **Action**: Display all **test units** (individual test cases) under that test suite and their states.
  
  - **Test Unit States**:
    - **Waiting**: Before the test starts.
    - **Running**: During test execution.
    - **Passed**: When the unit passes.
    - **Failed**: When the unit fails.

- **How It Works**:
  - As `CTest` writes each test unit's result into `LastTest.log`, capture the state changes for each test unit.
  - Display each test unit name and its state (Waiting, Running, Passed, Failed) in the Vim window.
  - Pressing **Space** again on a test unit can show more detailed logs or re-run that unit test.

#### **Detailed Steps for Test Unit Parsing**:
1. **Identify Test Unit Start**:
   - Test units are logged one by one in `LastTest.log`. The start of each test unit might look like this:
     ```
     Test #1: ft_split_test ... Passed
     ```
   
2. **Capture Unit Result**:
   - Each test unit finishes with a **Passed** or **Failed** status. Parse these lines from the log to update the state of the test units in the Vim window.
  
3. **Update Test Unit Display**:
   - Update the state of each test unit in the vertical window.
   - Example:
     ```
     Test Suites:
       ft_split_test
         - test_case1_function_name1 🟢 Passed
         - test_case2_function_name2 🟢 Passed
     ```

---

### **Enhanced Real-Time Update Strategy with `vim-dispatch` and `tmux`**

| **Step**                  | **Action**                                                   | **Details**                                                  |
|---------------------------|--------------------------------------------------------------|--------------------------------------------------------------|
| **1. Set Project Root with `vim-rooter`** | Automatically set the project root directory based on the project folder layout | Ensures correct working directory for build and test execution |
| **2. Start Test Execution with `vim-dispatch`** | Use `vim-dispatch` to run `CMake`, `Make`, and `CTest` in **tmux** windows asynchronously | Allows tests to run without blocking Vim, keeping the editor responsive |
| **3. Monitor `LastTest.log` in Real-Time** | Use a **tmux** window to continuously tail `LastTest.log` and capture real-time updates | Provides immediate feedback for each test suite as it finishes |
| **4. Update Suite States**  | As `LastTest.log` is updated, extract test suite results and update their states in the vertical window | Display **Waiting**, **Running**, **Passed**, **Failed** for each suite |
| **5. Popup on Enter**       | When a user presses **Enter** on a test suite, display its detailed output in a popup | Parse and format the test suite log for better readability |
| **6. Parse and Show Test Units** | When pressing **Space** on a test suite, display the state of each test unit in the vertical window | Extract test unit results from `LastTest.log` and show **Passed**, **Failed**, etc. |
| **7. Update Test Unit States** | As each test unit is executed, update the vertical window with real-time status of test units | States: **Waiting**, **Running**, **Passed**, **Failed** |

---

### **Integration of `vim-dispatch`, `tmux`, and `vim-rooter` into the Process**

#### **Using `vim-rooter` for Simplifying Project Navigation**:
- **Purpose**: `vim-rooter` automatically sets the working directory to the project root based on the folder structure.
- **Impact**: This ensures that when we run `CMake`, `Make`, and `CTest`, they are executed in the correct project context, simplifying the build and test process.
  
#### **Using `vim-dispatch` and `tmux` for Asynchronous Execution**:
- **vim-dispatch**:
  - Allows Vim to trigger external commands asynchronously, meaning `CMake`, `Make`, and `CTest` can run without blocking Vim. This enables developers to continue working while tests are being executed in the background.
  
- **tmux**:
  - **Why use tmux?**: Each test suite runs in its own **tmux** window (triggered by `vim-dispatch`). `tmux` sessions allow us to:
    1. **Run multiple commands in parallel**.
    2. **Monitor the output of `LastTest.log` in real-time** in a separate pane or window.
  - **Monitor Output**: Using a separate `tmux` window, we can run a `tail -f` command on the `LastTest.log` file, capturing test results as they are written. This allows us to provide **real-time updates** to the Vim window.

#### **Workflow with `vim-dispatch` and `tmux`**:
1. **vim-dispatch** starts the `CMake`, `Make`, and `CTest` commands asynchronously in **tmux** windows.
2. A separate `tmux` pane tails the `LastTest.log`

 file for real-time updates.
3. As each test suite finishes, the results are written to `LastTest.log`, and we parse them to update the Vim window with the new state (Running → Passed/Failed).
4. Developers can continue working in Vim while the tests are running asynchronously.

---
