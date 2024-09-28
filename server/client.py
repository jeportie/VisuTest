import socket
import sys

def main():
    # Define server address and port
    server_address = 'localhost'
    server_port = 9999

    # Create a TCP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((server_address, server_port))

    # Send START_TEST command
    sock.sendall(b'START_TEST\n')

    # Continuously receive data from the server and print it
    try:
        while True:
            data = sock.recv(1024)
            if not data:
                break
            print(data.decode(), end='')
    except KeyboardInterrupt:
        pass
    finally:
        sock.close()

if __name__ == '__main__':
    main()
