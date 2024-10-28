
![Screenshot from 2024-10-28 10-44-40](https://github.com/user-attachments/assets/42737af8-ea59-4798-af2b-9fb6c631225c)


## Introduction

VisuTest is a Vim plugin designed to optimize the C development workflow by integrating automated testing, real-time feedback, and intelligent test generation directly into the editor. It simplifies the process of developing and testing C functions by enforcing project structure and providing real-time test execution. The plugin operates asynchronously, utilizing a server-based architecture to build and run tests without disrupting the user’s workflow.

This plugin ensures that each function is tested individually, following best practices from extreme programming to improve code quality, maintainability, and collaboration.

![Screenshot from 2024-10-28 10-48-35](https://github.com/user-attachments/assets/f2986fc2-ccd8-42d9-b382-7927af2d64f9)
---

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
### 2. User Interface
![Screenshot from 2024-09-23 00-49-35](https://github.com/user-attachments/assets/0f797f36-b553-4be0-b921-401dd6f13248)

#### 3. Vertical Window for Test Suites

- Displays test suite statuses in a vertical window occupying 1/4 of the screen.
- Test results are updated in real-time with visual feedback:
  - **Waiting**: Before the test starts. -> Blue Icon or Empty Circle
  - **Running**: During test execution. -> Yellow Icon
  - **Passed**: When the unit passes. -> Green Icon
  - **Failed**: When the unit fails. -> Red Icon

![Screenshot from 2024-09-23 00-49-48](https://github.com/user-attachments/assets/ab050bff-95a3-41ce-a75f-ba380f8a6162)


#### 4. Detailed Logs for Each Test

- Users can access detailed logs for individual test suites by pressing **Enter** on a test in the vertical window.
- Logs show:
  - Execution commands and time.
  - Test output and results.
  - Any errors encountered during the test.
    
![Screenshot from 2024-09-23 00-49-19](https://github.com/user-attachments/assets/cd753578-eca0-4f7b-aaa1-f72507dc757e)


#### 5. Test Suite Approval Workflow

- Newly generated tests are marked as **pending approval**.
- Users can approve, edit, or reject tests through the interface, streamlining the test creation and approval process.

---

### Real-Time Test Execution and Status Updates

#### 6. Asynchronous Test Execution

- Automatically runs tests upon exiting insert mode.
- Real-time feedback on the test execution process is provided through dynamic updates to the test window, ensuring that users are always aware of the current test status.

#### 7. Test Unit and Test Suite Parsing

- VisuTest parses test files to extract both test suites and individual test cases (units).
- Displays test suites in the vertical window, allowing users to inspect and manage their test cases easily.

---

### 3. Server-Based Asynchronous Test Execution

VisuTest leverages a server-based system to run tests asynchronously, allowing users to continue working in Vim while tests are executed in the background.

#### **1. Popup Window with Test Output on Enter**
- **Trigger**: When a user presses **Enter** on a test suite in the vertical window.
- **Action**: Open a buffer (popup window) that displays the **detailed output** of the test suite.
  
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
  - The `LastTest.log` file is parsed to extract the detailed output for the corresponding test suite.
  - The log is displayed in a new buffer when triggered by **Enter**.

#### **2. Parsing and Updating Test Unit States**
- **Trigger**: When a user presses **Space** on a test suite in the vertical window.
- **Action**: Display all **test units** (individual test cases) under that test suite and their states.

  **Test Unit States**:
  - **Waiting**: Before the test starts.
  - **Running**: During test execution.
  - **Passed**: When the unit passes.
  - **Failed**: When the unit fails.

---

### 3. Extreme Programming and the Importance of Testing

Extreme programming (XP) advocates for continuous testing and incremental development to deliver high-quality software. By enforcing one function per file and ensuring each function is tested individually, VisuTest aligns with XP principles. Testing each function in isolation ensures that issues are caught early, and the code remains modular, maintainable, and easy to refactor.

**Why This Approach Matters**:
- **Improved Code Quality**: Isolating and testing functions ensures bugs are identified at the source, improving overall code reliability.
- **Rapid Feedback**: Immediate feedback from test results allows for faster iteration and development, reducing the time between writing and verifying code.
- **Simplified Collaboration**: A well-structured project with clear function responsibilities and associated tests enables easier team collaboration and faster integration of new code.

VisuTest streamlines this process by automating test file creation, handling CMakeLists updates, and providing real-time test execution and status updates.
---

## Plugin Features and Commands

### Features Overview

| **Feature**                          | **Description**                                                                                       |
|--------------------------------------|-------------------------------------------------------------------------------------------------------|
| **Standardized Project Structure**   | Enforces a clear folder structure and one function per `.c` file with corresponding tests.             |
| **Server-Based Asynchronous Testing**| Runs tests asynchronously, updating results in real-time without blocking Vim.                         |
| **Automatic Test File Creation**     | Automatically generates test files in `test_src/` when a new source file is created in `src/`.         |
| **CMakeLists.txt Auto-Update**       | Automatically updates `CMakeLists.txt` to include new tests.                                           |
| **Vertical Test Status Window**      | Displays test statuses in a 1/4 vertical window with real-time updates and detailed test logs.          |
| **Test Approval Workflow**           | Users can approve, edit, or reject auto-generated tests before they are run.                           |

### Commands Overview

| **Command**           | **Description**                                 |
|-----------------------|-------------------------------------------------|
| `:VisuTest`           | Opens the VisuTest window.                      |
| `:VisuTestClose`      | Closes the VisuTest window.                     |
| `:VisuTestToggle`     | Toggles the VisuTest window on/off.             |
| `:VisuTestShowUnits`  | Displays the test units for a selected test.    |

---

## Plan for Server-Listening System for Asynchronous Test Execution

### **Overview**

A server-based system manages the execution of commands like `CMake`, `make`, and `CTest`. Vim sends requests to this server for running tests, and the server asynchronously executes the commands, sending results back to Vim for display.

**Components**:
1. **Vim Client**: Vim sends test execution requests to the server using `jobstart()` or `system()` to communicate via sockets or HTTP.
2. **Server Process**: The server (Python or Node.js) listens for requests, executes the tests asynchronously, and sends the results back to Vim.
3. **Real-Time Test Status Updates**: The server sends status updates back to Vim, which updates the vertical window with test progress and logs.

---

## Updated VisuTest Plugin Project Structure

```bash
visutest/
├── autoload/
│   └── visutest.vim            # Core Vim functions for plugin behavior
├── plugin/
│   └── visutest.vim            # Main plugin logic loaded at startup
├── server/
│   ├── server.py               # Python server handling test execution
│   ├── requirements.txt        # Python dependencies (e.g., Flask, socket, etc.)
│   └── utils.py                # Utility functions for server-side tasks
├── scripts/
│   └── client.vim              # Vimscript client for communicating with the server
├── tests/
│   └── test_visutest.vim       # Automated tests for plugin behavior
├── README.md                   # Project documentation
├── LICENSE                     # Licensing information
└── config/
    └── default_config.vim      # Default Vim settings for the plugin
```

---

## Installation and Setup

### Requirements:
- Vim or Neovim
- A server runtime (Python, Node.js, etc.) for asynchronous test execution.
- `CMake` and `CTest` for test management.

### Installation:
1. Clone the VisuTest repository:
   ```
   git clone https://github.com/yourusername/visutest ~/.vim/pack/plugins/start/visutest
   ```

2. Run the setup script to install dependencies:
   ```
   ./setup.sh
   ```

3. Start Vim/Neovim and use `:VisuTest` to launch the plugin window.

---

## Roadmap

1. **Feature Enhancements**:
   - Additional customization options for the user interface.
   - Expanded support for complex CMake structures.

2. **Performance Improvements**:
   - Optimize the server for handling larger test suites.
   - Improve resource management during asynchronous execution.

3. **Robust Error Handling**:
   - Develop enhanced error handling for test failures and communication issues with the server.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

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


Yes, we can replace **tmux** and **vim-dispatch** with a custom server-listening system to run tests asynchronously without blocking Vim. This approach involves creating a separate server process that listens for test execution requests from Vim, runs the tests in the background, and sends results back to Vim for display.

Here’s a high-level plan on how to implement such a system:

---

## **Plan for Server-Listening System for Asynchronous Test Execution**

### **Overview**

The idea is to run a separate server (likely a Python or Node.js process) that will handle the execution of commands like `CMake`, `make`, and `CTest`. Vim will send requests to this server for running tests, and the server will asynchronously execute the commands, sending results back to Vim, which can then update the test status in the vertical window.

### **Key Components of the Server-Listening System**

1. **Vim Client**: 
   - Vim will act as the client, sending test execution requests to the server and receiving responses (e.g., test results or logs).
   - This will be implemented in Vimscript, using Vim’s `jobstart()` or `system()` to communicate with the server via sockets (or potentially HTTP, depending on the server).

2. **Server Process**:
   - The server will be a separate process running in the background.
   - It will listen for requests (e.g., run tests, check test status) and execute the appropriate commands asynchronously.
   - For example, when the server receives a request to run `CTest`, it will execute the test in the background and send back the results when complete.

3. **Communication Protocol**:
   - We will establish a protocol for communication between Vim and the server. This could be:
     - **Sockets**: Using Unix domain sockets or TCP sockets for communication.
     - **HTTP**: Using HTTP for sending requests and responses.
   - The server will send JSON responses with test results, logs, etc., which Vim will parse and display in the appropriate windows.

4. **Real-Time Test Status Updates**:
   - Once the server runs the tests, it will send real-time status updates back to Vim, such as:
     - Test in progress.
     - Test passed/failed.
     - Test log available.
   - Vim will use this information to update the vertical window and show popups with logs.

---

### **Step-by-Step Implementation Plan**

#### **Phase 1: Server Setup and Communication**

1. **Choose Server Language and Framework**:
   - Python with `socket` library or `flask` for HTTP-based communication.
   - Node.js with `express` for HTTP, or native `net` library for socket-based communication.
   
   Example: 
   ```python
   # Python socket server example
   import socket
   import subprocess

   def run_ctest():
       # Replace this with actual command to run CTest
       result = subprocess.run(['ctest'], capture_output=True)
       return result.stdout.decode()

   def start_server():
       server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
       server_socket.bind(('localhost', 9999))  # Bind to localhost:9999
       server_socket.listen(1)

       while True:
           client_socket, addr = server_socket.accept()
           request = client_socket.recv(1024).decode()
           
           if request == "RUN_TEST":
               test_result = run_ctest()
               client_socket.send(test_result.encode())

           client_socket.close()

   start_server()
   ```

2. **Implement Communication from Vim**:
   - Use Vim’s `jobstart()` function to send requests to the server and handle responses.
   - This can be wrapped in Vimscript functions, triggered by user commands or events like exiting insert mode.
   
   Example:
   ```vim
   function! RunTests()
       " Send a request to the server to run the tests
       let job = jobstart(['nc', 'localhost', '9999'], {
           \ 'on_stdout': 'HandleTestResults',
           \ 'on_stderr': 'HandleTestErrors'
       \ })
   endfunction

   function! HandleTestResults(job_id, data, event)
       " Update the vertical window with test results
       let result = join(a:data, "\n")
       call UpdateTestWindow(result)
   endfunction

   function! UpdateTestWindow(result)
       " Custom logic to update the test window with results
       echo "Test results: " . a:result
   endfunction
   ```

3. **Test and Debug**:
   - Ensure that Vim can successfully send requests and receive responses.
   - Test the communication by running simple commands like `ctest` or `make` from the server.

---

#### **Phase 2: Asynchronous Test Execution**

4. **Handle Asynchronous Commands on the Server**:
   - When the server receives a test execution request, it should run the command in a non-blocking way (e.g., using Python’s `subprocess.Popen` or Node.js’s `child_process.spawn`).
   - The server can continue listening for more requests even while tests are running.
   
   Example:
   ```python
   import subprocess

   def run_ctest_async():
       process = subprocess.Popen(['ctest'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
       return process
   ```

5. **Return Real-Time Test Results**:
   - As the server runs tests, it can periodically send updates (e.g., using a progress indicator or partial logs) back to Vim.
   - Vim should handle these updates and refresh the vertical window dynamically.

---

#### **Phase 3: Implement Real-Time Updates in Vim**

6. **Update Vertical Window Dynamically**:
   - Parse the test results and update the vertical window with appropriate icons and status (e.g., running, passed, failed).
   - You can use `vim.schedule()` to ensure that UI updates happen smoothly in asynchronous contexts.

7. **Popup Logs and Details**:
   - When a test suite finishes, Vim can display the detailed logs in a popup or buffer, allowing users to inspect what went wrong.
   - Use the `LastTest.log` or other logs returned by the server for detailed information.

---

#### **Phase 4: Error Handling and Cleanup**

8. **Handle Errors and Timeouts**:
   - Add error handling to manage cases where the server fails or takes too long to respond.
   - Display appropriate messages in Vim when errors occur.

9. **Graceful Shutdown**:
   - Ensure that the server process can be started and stopped gracefully, either through Vim commands or system events.

---

### **Phase 5: Final Enhancements**

10. **User Configuration Options**:
    - Add Vim configuration settings to customize server behavior (e.g., server port, timeout values, etc.).

11. **Testing and Debugging**:
    - Thoroughly test the server-client interaction, ensuring no blocking occurs in Vim.
    - Test various edge cases like large test suites, long-running tests, and network issues.

---

### **File Organization for the Plugin**

```bash
visutest/
├── autoload/
│   └── visutest.vim            # Core Vim functions for plugin behavior
├── plugin/
│   └── visutest.vim            # Main plugin logic loaded at startup
├── server/
│   ├── server.py               # Python server handling test execution
│   ├── requirements.txt        # Python dependencies (e.g., Flask, socket, etc.)
│   └── utils.py                # Utility functions for server-side tasks
├── scripts/
│   └── client.vim              # Vimscript client for communicating with the server
├── tests/
│   └── test_visutest.vim       # Automated tests for plugin behavior
├── README.md                   # Plugin documentation
├── LICENSE                     # Licensing information
└── config/
    └── default_config.vim      # Default Vim settings for the plugin
```

### **Explanation of File Structure**:

- **server/**: Contains the Python or Node.js server code that runs tests asynchronously.
- **scripts/**: Contains Vimscript logic for sending requests to the server and handling responses.
- **autoload/plugin/**: Core Vim plugin logic for managing windows, running tests, and handling real-time updates.

---

## **Next Steps**

1. **Set Up the Server**: Write the server code and ensure it can handle basic test execution requests.
2. **Integrate with Vim**: Implement Vim’s client-side functions to communicate with the server.
3. **Test Asynchronous Execution**: Validate that tests run asynchronously without blocking Vim.
4. **Enhance Real-Time Updates**: Implement logic for updating test statuses and displaying logs in Vim.

This approach will give you a fully asynchronous system to run tests without blocking Vim, providing flexibility and scalability as the project grows. Let me know if you'd like to dive into specific parts of the implementation!
