import socket

def connect_to_server():
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

