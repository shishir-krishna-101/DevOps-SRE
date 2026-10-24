import logging
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

# Configure logging to output to stdout
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    stream=sys.stdout,
)
logger = logging.getLogger("memory-app")


class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/healthcheck':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "healthy"}')
        else:
            self.send_response(404)
            self.end_headers()

    # Suppress default HTTP logging to keep our application logs clean
    def log_message(self, format, *args):
        pass


def run_server():
    server = HTTPServer(('0.0.0.0', 8080), HealthCheckHandler)
    logger.info("Starting HTTP server on port 8080 for health checks...")
    server.serve_forever()


def main():
    logger.info("Application starting...")

    # Start HTTP server in a daemon thread so it runs in the background
    server_thread = threading.Thread(target=run_server, daemon=True)
    server_thread.start()

    data = []

    # Allocate 100MB initially
    try:
        data.append(bytearray(100 * 1024 * 1024))
        logger.info("Allocated initial 100MB")
    except MemoryError:
        logger.exception("Failed to allocate initial memory: insufficient memory.")
        return

    # Increase to 500MB in 2 minutes (120 seconds)
    # Target increase: 400MB
    # Per second increase: 400 / 120 = ~3.33MB/s
    mb_increment_float = 400 / 120.0
    total_mb_float = 100.0

    while True:
        try:
            # Allocate the increment for this second
            increment_bytes = int(mb_increment_float * 1024 * 1024)
            data.append(bytearray(increment_bytes))

            total_mb_float += mb_increment_float
            current_mb = int(total_mb_float)

            # Log periodically to avoid excessive spam but keep generating logs
            if current_mb % 25 == 0 or current_mb % 25 < 4:
                logger.info("Memory check. Current memory allocated: ~%sMB", current_mb)

            time.sleep(1)
        except MemoryError:
            logger.error("OOM limits exceeded or MemoryError caught.")
            break


if __name__ == "__main__":
    main()
