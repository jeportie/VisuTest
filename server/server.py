import subprocess
import socket
import os
import logging

# Set up logging to capture debug messages
logging.basicConfig(
    filename='/root/.vim/plugged/VisuTest/server/server.log',
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

def run_tests():
    logging.info("Running tests: cmake, make, ctest.")
    try:
        build_dir = os.path.join(os.getcwd(), "test_src", "build")

        if not os.path.exists(build_dir):
            os.makedirs(build_dir)
            logging.debug(f"Created build directory: {build_dir}")

        try:
            cmake_result = subprocess.run(
                ["cmake", ".."],
                cwd=build_dir,
                check=True,
                capture_output=True,
                text=True
            )
            logging.debug(f"CMake output:\n{cmake_result.stdout}")
        except subprocess.CalledProcessError as e:
            error_message = f"CMAKE_ERROR:\n{e.stderr}"
            logging.error(f"Captured CMake error:\n{error_message}")
            return error_message.replace("\n", "<br>")  # To preserve line structure for Vim

        try:
            make_result = subprocess.run(
                ["make"],
                cwd=build_dir,
                check=True,
                capture_output=True,
                text=True
            )
            logging.debug(f"Make output:\n{make_result.stdout}")
        except subprocess.CalledProcessError as e:
            error_message = f"MAKE_ERROR:\n{e.stderr}"
            logging.error(f"Captured Make error:\n{error_message}")
            return error_message.replace("\n", "<br>")  # To preserve line structure for Vim

        # If cmake and make succeed, proceed with ctest
        ctest_result = subprocess.run(
            ["ctest"],
            cwd=build_dir,
            capture_output=True,
            text=True
        )
        logging.debug(f"CTest output:\n{ctest_result.stdout}")

    except Exception as e:
        error_message = f"ERROR: {str(e)}"
        logging.error(f"Unexpected error:\n{error_message}")
        return error_message.replace("\n", "<br>")

    logging.info("Build and tests succeeded.")
    return "SUCCESS"


def monitor_log_and_send_updates(client_socket):
    build_dir = os.path.join(os.getcwd(), "test_src", "build")
    log_file = os.path.join(build_dir, "Testing", "Temporary", "LastTest.log")

    if not os.path.exists(log_file):
        client_socket.send("ERROR: LastTest.log not found.\n".encode())
        logging.error(f"Log file not found: {log_file}")
        return

    with open(log_file, "r") as log:
        current_test_suite = []
        test_in_progress = False
        test_name = ""

        while True:
            new_line = log.readline()

            if new_line:
                logging.debug(f"Read log line: {new_line.strip()}")

                if "Testing:" in new_line:
                    test_name = new_line.split("Testing:")[-1].strip()
                    logging.info(f"Test started: {test_name}")
                    client_socket.send(f"RUNNING: {test_name}\n".encode())
                    current_test_suite.append("----------------------------------------------------------\n")
                    current_test_suite.append(new_line)
                    test_in_progress = True

                if "Command:" in new_line:
                    # Extract the test executable path
                    parts = new_line.split('"')
                    # Expected format:
                    # Command: "/usr/bin/bash" "/path/to/script.sh" "/usr/bin/valgrind" "/path/to/test_executable" "log_file.log" "/path/to/supp_file.supp"
                    # We want the 4th argument (index 7)
                    if len(parts) >= 8:
                        test_executable = parts[7]
                        new_command_line = f'Command: "{test_executable}"\n'
                        client_socket.send(new_command_line.encode())
                        current_test_suite.append(new_command_line)
                        logging.debug(f"Modified Command line: {new_command_line.strip()}")
                    else:
                        # If the expected format is not met, send the original line
                        client_socket.send(new_line.encode())
                        current_test_suite.append(new_line)

                if test_in_progress:
                    current_test_suite.append(new_line)

                if test_in_progress and ("Test Passed." in new_line or "Test Failed." in new_line):
                    test_result = "PASSED" if "Test Passed." in new_line else "FAILED"
                    client_socket.send(f"{test_result}\n".encode())
                    full_log = ''.join(current_test_suite)
                    client_socket.send(full_log.encode())
                    current_test_suite = []
                    test_in_progress = False
                    logging.info(f"Test {test_name} completed with result: {test_result}")

            else:
                break

    logging.info("Finished sending updates to client.")

def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('localhost', 9999))
    server_socket.listen(1)

    logging.info("Server is listening on port 9999.")

    while True:
        client_socket, addr = server_socket.accept()
        logging.info(f"Accepted connection from {addr}")
        request = client_socket.recv(1024).decode()

        # Enhanced logging for request handling
        logging.debug(f"Received request: {request}")

        if request.strip() == "START_TEST":
            logging.info("Processing START_TEST command.")
            test_status = run_tests()

            if test_status == "SUCCESS":
                monitor_log_and_send_updates(client_socket)
            else:
                client_socket.send(f"{test_status}\n".encode())
                logging.error(f"Error running tests: {test_status}")
        else:
            client_socket.send("ERROR: Invalid request.\n".encode())
            logging.error("Invalid request received.")

        client_socket.close()
        logging.info(f"Connection with {addr} closed.")

if __name__ == "__main__":
    start_server()

