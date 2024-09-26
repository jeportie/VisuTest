import subprocess
import socket
import os
import sys
import time

def run_tests(project_root):
    """
    Run the ctest command in the test_src directory within the provided project root.
    """
    test_src_dir = os.path.join(project_root, "test_src")
    try:
        subprocess.run(["ctest"], cwd=test_src_dir, check=True)
    except subprocess.CalledProcessError as e:
        return f"ERROR: {e}"
    return "SUCCESS"

def monitor_log_and_send_updates(client_socket, project_root):
    """
    Monitor the LastTest.log file in the project_root and send updates to the client.
    """
    log_file = os.path.join(project_root, "test_src", "Testing", "Temporary", "LastTest.log")

    # Check if LastTest.log exists
    if not os.path.exists(log_file):
        client_socket.send("ERROR: LastTest.log not found.".encode())
        return

    # Open the LastTest.log for reading from the beginning
    with open(log_file, "r") as log:
        current_test_suite = []
        test_in_progress = False

        while True:
            new_line = log.readline()

            if new_line:
                # Log the line for debugging purposes (you can remove this later)
                print(f"Read line: {new_line.strip()}")

                # Detect the start of a test suite block (line containing "Testing:")
                if "Testing:" in new_line and "Test:" in new_line:
                    test_name = new_line.split("Testing: ")[-1].strip()

                    # Send the running signal for this test suite
                    client_socket.send(f"RUNNING: {test_name}\n".encode())

                    # Manually add the separator before appending the actual "Testing" line
                    current_test_suite.append("----------------------------------------------------------\n")
                    current_test_suite.append(new_line)

                    test_in_progress = True
                elif test_in_progress:
                    # Continue collecting lines for the current test suite
                    current_test_suite.append(new_line)

                # Detect the end of the test block (Pass or Fail)
                if test_in_progress and ("Test Passed." in new_line or "Test Failed." in new_line):
                    test_result = "PASSED" if "Test Passed." in new_line else "FAILED"
                    client_socket.send(f"{test_result}\n".encode())

                    # Send the full log of the current test suite to Vim
                    full_log = ''.join(current_test_suite)
                    client_socket.send(full_log.encode())

                    # Reset for the next test suite
                    current_test_suite = []
                    test_in_progress = False
            else:
                # For testing, we'll exit the loop after reading the whole file
                # In a real scenario, use `time.sleep(0.1)` to wait for new data
                break

def start_server(project_root):
    """
    Start the server and wait for connections to handle test execution requests.
    """
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    # Allow the socket to be reused
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 9999))
    server_socket.listen(1)

    print("Server is listening on port 9999...")

    while True:
        client_socket, addr = server_socket.accept()
        print(f"Accepted connection from {addr}")
        request = client_socket.recv(1024).decode()

        if request == "START_TEST":
            test_status = run_tests(project_root)

            # If tests ran successfully, start monitoring the log
            if test_status == "SUCCESS":
                monitor_log_and_send_updates(client_socket, project_root)
            else:
                client_socket.send(f"{test_status}\n".encode())  # Send error message to Vim
        else:
            client_socket.send("ERROR: Invalid request.".encode())

        client_socket.close()
        print(f"Connection with {addr} closed.")

if __name__ == "__main__":
    # Ensure the project root is provided as a command-line argument
    if len(sys.argv) < 2:
        print("Usage: python server.py <project_root>")
        sys.exit(1)

    project_root = sys.argv[1]
    
    # Validate if the provided project root is a valid directory
    if not os.path.isdir(project_root):
        print(f"ERROR: The provided project root '{project_root}' is not a valid directory.")
        sys.exit(1)

    start_server(project_root)

