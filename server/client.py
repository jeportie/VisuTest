import socket
import sys
import logging

# Set up logging for the client
logging.basicConfig(filename='/root/.vim/plugged/VisuTest/server/client.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    server_address = 'localhost'
    server_port = 9999

    # Create a TCP socket
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((server_address, server_port))

    # Send START_TEST command to the server
    sock.sendall(b'START_TEST\n')
    logging.info("Sent START_TEST command to the server.")

    # Continuously receive data from the server
    try:
        while True:
            data = sock.recv(1024)
            if not data:
                break
            logging.debug(f"Received data: {data.decode().strip()}")
            print(data.decode(), end='')
    except Exception as e:
        logging.error(f"Error in client communication: {e}")
    finally:
        logging.info("Closing client socket.")
        sock.close()

if __name__ == '__main__':
    main()
