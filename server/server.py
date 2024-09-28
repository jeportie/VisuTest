import subprocess
import socket
import os
import time
import logging

logging.basicConfig(filename='/root/.vim/plugged/VisuTest/server/server.log', level=logging.DEBUG)

def run_tests():
    # Run ctest command in the test_src directory
    try:
        subprocess.run(["cmake" "."], cwd="test_src", check=True)
        subprocess.run(["make"], cwd="test_src", check=True)
        subprocess.run(["ctest"], cwd="test_src", check=True)
    except subprocess.CalledProcessError as e:
        return f"ERROR: {e}"
    return "SUCCESS"

def monitor_log_and_send_updates(client_socket):
    # Adjust the path to LastTest.log inside test_src/Testing/Temporary/
    log_file = os.path.join(os.getcwd(), "test_src", "Testing", "Temporary", "LastTest.log")

    # Make sure the log file exists
    if not os.path.exists(log_file):
        client_socket.send("ERROR: LastTest.log not found.".encode())
        print("Log file not found:", log_file)  # Debug print
        return
    else:
        print("Log file found:", log_file)  # Debug print

    # Open the LastTest.log for reading from the beginning
    with open(log_file, "r") as log:
        # Start from the beginning of the file
        current_test_suite = []
        test_in_progress = False

        while True:
            new_line = log.readline()

            if new_line:
                print(f"Read line: {new_line.strip()}")  # Debug print

                # Detect the start of a test suite block (line containing "Testing:")
                if "Testing:" in new_line:
                    test_name = new_line.split("Testing:")[-1].strip()
                    print(f"Detected start of test suite: {test_name}")  # Debug print

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
                # Since we're dealing with a static file during testing, break the loop
                break

    print("Finished sending updates to client.")

def start_server():
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
            test_status = run_tests()

            # If tests ran successfully, start monitoring the log
            if test_status == "SUCCESS":
                monitor_log_and_send_updates(client_socket)
            else:
                client_socket.send(f"{test_status}\n".encode())  # Send error message to Vim
        else:
            client_socket.send("ERROR: Invalid request.".encode())

        client_socket.close()
        print(f"Connection with {addr} closed.")

if __name__ == "__main__":
    start_server()

