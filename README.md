
![Screenshot from 2024-10-28 10-44-40](https://github.com/user-attachments/assets/42737af8-ea59-4798-af2b-9fb6c631225c)


Vim plugin designed to streamline the testing process for C projects by displaying test statuses, subtest results, and build error logs directly within Vim. The plugin integrates with CMake, Check framework and CTest, providing a cohesive UI to track test suites and subtests, handle build errors, and quickly access detailed logs.

![Screenshot from 2024-10-28 13-34-39](https://github.com/user-attachments/assets/30562d21-2d0d-4861-8470-ee8d5ac6e3f0)

## Table of Contents

- [Installation](#installation)
- [Key Features](#key-features)
- [Plugin Features](#plugin-features)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Setup and Test Execution](#setup-and-test-execution)
  - [Interacting with Test Results](#interacting-with-test-results)
  - [Viewing Build Errors](#viewing-build-errors)
  - [Navigating the UI](#navigating-the-ui)
- [Customization](#customization)
- [Extrem Programming](#extreme-programming-and-the-importance-of-testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Installation

### Prerequisites

Ensure you have **CMake**, **Make**, and **CTest** installed and configured to run your C project tests. You'll also need **Python 3** for the server handling and Vim 8 or above.

### Install with Vim Plug

Add the following line to your `.vimrc` if you’re using [Vundle](https://github.com/VundleVim/Vundle.vim):

```vim
Plugin 'jeportie/VisuTest'
```

Then, in Vim, run:

```vim
:PlugInstall
```
## Key Features

### 1. Standardized Project Structure

VisuTest enforces a standardized project layout to maintain consistency across projects and ensure smooth navigation and management. The structure allows for multiple header files across the source directory but requires a main header file, named after the project folder, which links all the sub-headers. This approach facilitates clear, organized code and makes it easy to parse and update the CMakeLists.txt file.

**Project Folder Layout**:

```
└── Project Root
    ├── include/
    │   ├── project.h               # Main project header linking all sub-headers
    │   └── defines.h
    ├── lib/
    │   ├── libfoo.a                # Example static library
    │   └── libbar.so               # Example shared library
    ├── assets/
    │   ├── logo.png                # Project logo or image assets
    │   └── config.json             # Configuration files or templates
    ├── main.c
    ├── src/
    │   ├── sub_folder_name1/
    │   │   ├── function_name1.c
    │   │   ├── module1.h           # Additional header in subfolder
    │   └── function_name2.c
    ├── test_src/
    │   ├── CMakeLists.txt          # Managed by VisuTest for test integration
    │   ├── sub_folder_name1/
    │   │   └── test_function_name1.c
    │   ├── test_function_name2.c
    ├── ycm_extra_conf.py           # Configuration for YouCompleteMe plugin
    ├── .vimspector.json            # Configuration file for Vimspector plugin
    ├── Makefile
    └── .gitignore
```
**Key Rules**:
- **Single Function per `.c` File**: Each `.c` file in `src/` contains only one public function, with helper functions permitted. The file is named after the public function it implements.
- **Multiple Header Files**: Header files (`.h`) can exist in different subdirectories but must all be linked to the main project header for clarity and ease of compilation.
- **Test Files**: Located in `test_src/`, each test file mirrors the structure of its corresponding source file in `src/` and is prefixed with `test_`.

---
## Plugin Features

- **Test Suite Display**: Lists all test suites and their status in a dedicated vertical split in Vim.
- **Subtest Status Tracking**: Displays individual subtests under each test suite with real-time pass/fail icons.
- **Build Error Detection**: Automatically detects and displays errors from CMake or Make, avoiding CTest execution if build errors occur.
- **Popup Logs**: Provides detailed logs for test suites, subtests, or build errors in popup windows.
- **Key Mappings**: Customizable shortcuts to run tests, toggle test units, open logs, and navigate the UI.

## Configuration

No specific configuration is required to get started, but you can customize the UI split dimensions and default key mappings in the source files or add new key mappings as needed.

## Usage

### Setup and Test Execution

1. **Start VisuTest** by running `:VisuTestRun`. This will:
   - Run `cmake ..` and `make` commands to configure and build your tests.
   - If successful, start `ctest` to execute the tests.
   - Display real-time updates of test suite and subtest statuses.

2. **Running Individual Test Suites**: When a test suite is listed, you can press `<CR>` (Enter) on its name to view the test log in a popup window.

3. **Error Handling**: If there’s a build error during `cmake ..` or `make`, VisuTest will skip `ctest` execution and display the build error log in a popup.

### Interacting with Test Results

- **Subtest Visibility**: Use `P` to toggle the display of subtests under each test suite.
- **Icons**:
  - **Test Suite**:
    - `🟢`: All subtests passed.
    - `🔴`: One or more subtests failed or there’s a memory leak detected.
    - `⚪`: Test not yet executed or running.
  - **Subtests**:
    - `🟢`: Passed.
    - `🔴`: Failed.
    - `⚪`: Not executed.

![Screenshot from 2024-10-28 16-48-04](https://github.com/user-attachments/assets/2b38de5b-9e1f-4979-9da5-4d70b816a484)

### Viewing Build Errors

1. If a build error is detected during `cmake ..` or `make`, the error will appear in a popup.
2. Press `<Esc>` to close the popup and return to the test UI.

### Navigating the UI

- `q`: Close the VisuTest window and return to the editor.
- `<Esc>`: Close the currently open popup window.
- `r`: Re-run tests.
- `P`: Toggle visibility of subtests within test suites.
- `<CR>` (Enter): Open test suite logs or subtest details in a popup.

## Customization

To customize the UI further or add new key mappings, open the following files and modify as needed:

- `autoload/visutest_ui.vim`:
  - Update syntax highlighting for test icons or adjust the popup display settings.
- `autoload/visutest_client.vim`:
  - Adjust the logic for test suite and subtest updates, or customize log processing.

## Extreme Programming and the Importance of Testing

Extreme programming (XP) advocates for continuous testing and incremental development to deliver high-quality software. By enforcing one function per file and ensuring each function is tested individually, VisuTest aligns with XP principles. Testing each function in isolation ensures that issues are caught early, and the code remains modular, maintainable, and easy to refactor.

**Why This Approach Matters**:
- **Improved Code Quality**: Isolating and testing functions ensures bugs are identified at the source, improving overall code reliability.
- **Rapid Feedback**: Immediate feedback from test results allows for faster iteration and development, reducing the time between writing and verifying code.
- **Simplified Collaboration**: A well-structured project with clear function responsibilities and associated tests enables easier team collaboration and faster integration of new code.

VisuTest streamlines this process by automating test file creation, handling CMakeLists updates, and providing real-time test execution and status updates.

## Troubleshooting

- **Icons Not Updating**: Ensure your test log format matches the regex patterns in `ParseSubTestResults`.
- **Build Errors Not Displaying**: Verify the error message format is correctly matched by `CMAKE_ERROR` or `MAKE_ERROR`.
- **Test Suite Names Not Detected**: Confirm the test naming conventions align with `RUNNING` or `FAILED` markers in the logs.

## Contributing

Contributions are welcome! For major changes, please open an issue to discuss what you’d like to add. Feel free to submit a pull request, and check out our [contribution guide](CONTRIBUTING.md) for more information.

---

With VisuTest, you have all the essential details of your test executions integrated directly into Vim, allowing you to focus on developing and debugging efficiently. Enjoy testing! 🚀

## Languages and Tools:

<p align="left">
  <img src="https://github.com/devicons/devicon/blob/master/icons/vim/vim-original.svg" height="40" alt="Vim" />
  <img width="12" />
  <img src="https://github.com/devicons/devicon/blob/master/icons/bash/bash-original.svg" height="40" alt="Bash" />
  <img width="12" />
  <img src="https://github.com/devicons/devicon/blob/master/icons/git/git-original.svg" height="40" alt="Git" />
  <img width="12" />
</p>

## Connect with Me 🤝

<p align="left">
  <a href="https://profile.intra.42.fr/users/jeportie">
    <img src="https://badge.mediaplus.ma/greenbinary/jeportie?1337Badge=off&UM6P=off" alt="Jerome's 42 Badge" />
  </a>
</p>

- [Jerome's GitHub Profile](https://github.com/jeportie)

<div>
  <img height="150" src="https://github-readme-stats.vercel.app/api?username=jeportie&show_icons=true&theme=default" alt="Jerome's GitHub stats" />
</div>
