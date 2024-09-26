import socket
import os
import subprocess
import time

def start_server():
    """Start the server and pass the project root as an argument."""
    project_root = os.getcwd()  # Get the current working directory (or specify a path)
    
    # Path to the server script
    server_script = os.path.join(os.path.dirname(__file__), 'server.py')

    # Start the server process
    server_process = subprocess.Popen(['python3', server_script, project_root], stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    # Give the server some time to start up
    time.sleep(1)
    
    return server_process

def connect_to_server():
    """Simulate Vim connecting to the server and receiving output."""
    
    # Start the server
    server_process = start_server()

    # Connect to the server
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect(('localhost', 9999))
    
    # Send the START_TEST request to simulate running tests
    client_socket.sendall("START_TEST".encode())

    # Receive and print the output from the server
    while True:
        data = client_socket.recv(4096)
        if not data:
            break
        print(data.decode())

    client_socket.close()

    # Terminate the server process after the tests
    server_process.terminate()
    server_process.wait()

if __name__ == "__main__":
    connect_to_server()

