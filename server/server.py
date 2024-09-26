
import subprocess
import socket
import os
import time

def run_tests():
    # Run cmake, make, and ctest commands with error handling
    try:
        subprocess.run(["cmake", "."], check=True)
        subprocess.run(["make"], check=True)
        subprocess.run(["ctest"], check=True)
    except subprocess.CalledProcessError as e:
        return f"ERROR: {e}"

    return "SUCCESS"

def monitor_log_and_send_updates(client_socket):
    log_file = os.path.join(os.getcwd(), "LastTest.log")

    # Make sure the log file exists
    if not os.path.exists(log_file):
        client_socket.send("ERROR: LastTest.log not found.".encode())
        return

    # Open the LastTest.log for reading in real-time
    with open(log_file, "r") as log:
        log.seek(0, os.SEEK_END)  # Move to the end of the file
        current_test_suite = []
        test_in_progress = False

        while True:
            new_line = log.readline()

            if new_line:
                # Detect the start of a test suite block (line containing "Testing:")
                if "Testing:" in new_line and "Test:" in new_line:
                    test_name = new_line.split("Testing: ")[-1].strip()

                    # Send the running signal for this test suite
                    client_socket.send(f"RUNNING: {test_name}".encode())

                    # Manually add the separator before appending the actual "Testing" line
                    current_test_suite.append("----------------------------------------------------------\n")
                    current_test_suite.append(new_line)

                    test_in_progress = True

                # Continue collecting lines for the current test suite
                if test_in_progress:
                    current_test_suite.append(new_line)

                # Detect the end of the test block (Pass or Fail)
                if "Test Passed" in new_line or "Test Failed" in new_line:
                    test_result = "PASSED" if "Test Passed" in new_line else "FAILED"
                    client_socket.send(f"{test_result}".encode())

                    # Send the full log of the current test suite to Vim
                    full_log = ''.join(current_test_suite)
                    client_socket.send(full_log.encode())

                    # Reset for the next test suite
                    current_test_suite = []
                    test_in_progress = False
            else:
                time.sleep(0.1)  # Wait before checking again


def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('localhost', 9999))
    server_socket.listen(1)

    while True:
        client_socket, addr = server_socket.accept()
        request = client_socket.recv(1024).decode()

        if request == "START_TEST":
            test_status = run_tests()

            # If tests ran successfully, start monitoring the log
            if test_status == "SUCCESS":
                monitor_log_and_send_updates(client_socket)
            else:
                client_socket.send(test_status.encode())  # Send error message to Vim

        client_socket.close()

if __name__ == "__main__":
    start_server()
