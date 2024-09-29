import socket
import sys
import logging

# Set up logging for the client
logging.basicConfig(filename='/root/.vim/plugged/VisuTest/server/client.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def main():
    server_address = 'localhost'
    server_port = 9999

    try:
        # Create a TCP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((server_address, server_port))
        logging.info("Connected to the server.")
        
        # Send START_TEST command to the server
        sock.sendall(b'START_TEST\n')
        logging.info("Sent START_TEST command to the server.")

        # Buffer to accumulate data
        buffer = ""

        # Receive data from the server
        while True:
            data = sock.recv(1024)
            if not data:
                break

            # Decode received data and accumulate it in the buffer
            buffer += data.decode()

            # Look for completed blocks in the buffer (assuming each block ends with '\n')
            while '\n' in buffer:
                line, buffer = buffer.split('\n', 1)
                logging.debug(f"Received data block: {line.strip()}")
                print(line.strip())  # Send entire line to Vim

    except socket.error as e:
        logging.error(f"Socket error: {e}")
    except Exception as e:
        logging.error(f"Error in client: {e}")
    finally:
        logging.info("Closing client socket.")
        sock.close()

if __name__ == '__main__':
    main()

