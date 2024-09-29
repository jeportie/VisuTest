import subprocess
import socket
import os
import logging

# Set up logging to capture debug messages
logging.basicConfig(filename='/root/.vim/plugged/VisuTest/server/server.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def run_tests():
    logging.info("Running tests: cmake, make, ctest.")
    try:
        # Run cmake command
        cmake_result = subprocess.run(["cmake", "."], cwd="test_src", check=True, capture_output=True)
        logging.debug(f"CMake output: {cmake_result.stdout.decode()}")
        
        # Run make command
        make_result = subprocess.run(["make"], cwd="test_src", check=True, capture_output=True)
        logging.debug(f"Make output: {make_result.stdout.decode()}")
        
        # Run ctest command
        ctest_result = subprocess.run(["ctest"], cwd="test_src", check=True, capture_output=True)
        logging.debug(f"CTest output: {ctest_result.stdout.decode()}")
        
    except subprocess.CalledProcessError as e:
        logging.error(f"Test execution failed: {e}")
        return f"ERROR: {e}"
    return "SUCCESS"

def monitor_log_and_send_updates(client_socket):
    log_file = os.path.join(os.getcwd(), "test_src", "Testing", "Temporary", "LastTest.log")

    if not os.path.exists(log_file):
        client_socket.sendall("ERROR: LastTest.log not found.\n".encode())
        logging.error(f"Log file not found: {log_file}")
        return

    with open(log_file, "r") as log:
        current_test_suite = []
        test_in_progress = False

        while True:
            new_line = log.readline()

            if new_line:
                logging.debug(f"Read log line: {new_line.strip()}")

                # Send the line to the client in blocks, not character by character
                client_socket.sendall(new_line.encode('utf-8'))

                if "Testing:" in new_line:
                    test_name = new_line.split("Testing:")[-1].strip()
                    logging.info(f"Test started: {test_name}")
                    client_socket.sendall(f"RUNNING: {test_name}\n".encode())
                    current_test_suite.append("----------------------------------------------------------\n")
                    current_test_suite.append(new_line)
                    test_in_progress = True

                if test_in_progress:
                    current_test_suite.append(new_line)

                if test_in_progress and ("Test Passed." in new_line or "Test Failed." in new_line):
                    test_result = "PASSED" if "Test Passed." in new_line else "FAILED"
                    client_socket.sendall(f"{test_result}\n".encode())
                    full_log = ''.join(current_test_suite)
                    client_socket.sendall(full_log.encode())
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
                client_socket.sendall(f"{test_status}\n".encode())
                logging.error(f"Error running tests: {test_status}")
        else:
            client_socket.sendall("ERROR: Invalid request.\n".encode())
            logging.error("Invalid request received.")

        client_socket.close()
        logging.info(f"Connection with {addr} closed.")

if __name__ == "__main__":
    start_server()
