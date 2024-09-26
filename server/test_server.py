
import socket
import os

def mock_last_test_log():
    """Create a mock LastTest.log file with the provided content."""
    log_content = """\
Total Test time (real) =   0.00 sec
Start testing: Sep 26 11:45 UTC
----------------------------------------------------------
1/2 Testing: test_ms_get_user_input
1/2 Test: test_ms_get_user_input
Command: "/root/projects/minishell/test_src/test_ms_get_user_input"
Directory: /root/projects/minishell/test_src
"test_ms_get_user_input" start time: Sep 26 11:45 UTC
Output:
----------------------------------------------------------
Running suite(s): Minishell
100%: Checks: 3, Failures: 0, Errors: 0
<end of output>
Test time =   0.00 sec
----------------------------------------------------------
Test Passed.
"test_ms_get_user_input" end time: Sep 26 11:45 UTC
"test_ms_get_user_input" time elapsed: 00:00:00
----------------------------------------------------------

2/2 Testing: test_ms_init_shell
2/2 Test: test_ms_init_shell
Command: "/root/projects/minishell/test_src/test_ms_init_shell"
Directory: /root/projects/minishell/test_src
"test_ms_init_shell" start time: Sep 26 11:45 UTC
Output:
----------------------------------------------------------
Running suite(s): Minishell
100%: Checks: 1, Failures: 0, Errors: 0
<end of output>
Test time =   0.00 sec
----------------------------------------------------------
Test Passed.
"test_ms_init_shell" end time: Sep 26 11:45 UTC
"test_ms_init_shell" time elapsed: 00:00:00
----------------------------------------------------------
End testing: Sep 26 11:45 UTC
"""
    with open("LastTest.log", "w") as f:
        f.write(log_content)

def connect_to_server():
    """Simulate Vim connecting to the server and receiving output."""
    mock_last_test_log()  # Create the mock LastTest.log for the server to read

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

if __name__ == "__main__":
    connect_to_server()
