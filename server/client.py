import socket
import sys
import logging

# Set up logging for the client
logging.basicConfig(filename='/root/.vim/plugged/VisuTest/server/client.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

def send_data(sock, message):
    """Send a message to the server with proper encoding."""
    try:
        # Send the data, ensuring it's in UTF-8 and adding a newline at the end
        sock.sendall((message + "\n").encode('utf-8'))
    except socket.error as e:
        logging.error(f"Failed to send message: {e}")

def receive_data(sock):
    """Receive data from the server in chunks, handling it as complete messages."""
    buffer = ""
    try:
        while True:
            data = sock.recv(1024).decode('utf-8')  # Ensure UTF-8 decoding
            if not data:
                break  # No more data, connection closed

            buffer += data  # Accumulate received data into a buffer

            # Process complete messages (when a newline is encountered)
            if "\n" in buffer:
                lines = buffer.split("\n")
                for line in lines[:-1]:  # Process all complete lines
                    logging.debug(f"Received data: {line}")
                    print(f"Client received data: {line}")
                buffer = lines[-1]  # Keep the incomplete part for the next recv()

    except socket.error as e:
        logging.error(f"Error receiving data: {e}")

def main():
    server_address = 'localhost'
    server_port = 9999

    try:
        # Create a TCP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((server_address, server_port))
        logging.info("Connected to the server.")

        # Send START_TEST command to the server
        send_data(sock, "START_TEST")
        logging.info("Sent START_TEST command to the server.")

        # Receive and handle data from the server asynchronously
        receive_data(sock)

    except socket.error as e:
        logging.error(f"Socket error: {e}")
    except Exception as e:
        logging.error(f"Error in client: {e}")
    finally:
        logging.info("Closing client socket.")
        sock.close()

if __name__ == '__main__':
    main()
