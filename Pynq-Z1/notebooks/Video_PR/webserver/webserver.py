#!/usr/bin/env python3
## coding=utf-8
from pynq.board import Register
from threading import Lock
import argparse
import flask
import re
import os

SECURE = False
SUPPORTED_ERROR_CODES = {428, 429, 400, 401, 403, 404, 405, 406, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418,
                         422, 431, 500, 501, 502, 503, 504, 505}

# Constants that come from the Rect class
y_pos_reg = 1
regs_per_rect = 5
paddle_1_id = 0
paddle_2_id = 1

# Initialize the paddle y coordinate registers
paddle_1 = Register((regs_per_rect * paddle_1_id) + y_pos_reg)
paddle_2 = Register((regs_per_rect * paddle_2_id) + y_pos_reg)
paddle_1_lock = Lock()
paddle_2_lock = Lock()

# Game constants from ipynb
resolution = 3
game_height = 480
if resolution == 1:
	game_height = 600
elif resolution == 2:
	game_height = 720
elif resolution == 3:
	game_height = 720
elif resolution == 4:
	game_height = 1080
deadzone = (8 * resolution) + (1 * resolution)
paddle_height =  65 * resolution
paddle_min = 0 + deadzone
paddle_max = (game_height - paddle_height) - deadzone

# App variables
app = flask.Flask(__name__)

def page_error(error):
    text = "Please try again"
    return flask.render_template('index.html', page_name=str(error), text=text, title="PONQ:Error")


for code in SUPPORTED_ERROR_CODES:
    app.register_error_handler(code, page_error)


@app.route('/favicon.ico')
def favicon():
    return flask.send_from_directory(os.path.join(app.root_path, 'static'),
                                     'favicon.ico', mimetype='image/vnd.microsoft.icon')


@app.route("/")
def index():
    text = "welcome to ponq, choose your player number below"
    return flask.render_template('index.html', page_name="Player Select", text=text, title="PYNQ PONQ")


@app.route("/player_1")
def player_1():
    player = "1"
    return flask.render_template('controls.html', player=player, title="PONQ: Player 1")



@app.route("/player_2")
def player_2():
    player = "2"
    return flask.render_template('controls.html', player=player, title="PONQ: Player 2")


@app.route("/<player>/<direction>")
def move_paddle(player=None, direction=None):
    """
    This is the function that handles paddle movement
    """
    if player == "player_1":
        with paddle_1_lock:
            paddle_pos = paddle_1.read()
            if direction == "down":
                #print("moving player 1 paddle down")
                new_paddle_pos = paddle_pos + (10 * resolution)
                if new_paddle_pos > paddle_max:
                    new_paddle_pos = paddle_max
                paddle_1.write(new_paddle_pos)
            if direction == "up":
                #print("moving player 1 paddle up")
                new_paddle_pos = paddle_pos - (10 * resolution)
                if new_paddle_pos < paddle_min:
                    new_paddle_pos = paddle_min
                paddle_1.write(new_paddle_pos)
            
    elif player == "player_2":
        with paddle_2_lock:
            paddle_pos = paddle_2.read()
            if direction == "down":
                #print("moving player 1 paddle down")
                new_paddle_pos = paddle_pos + (10 * resolution)
                if new_paddle_pos > paddle_max:
                    new_paddle_pos = paddle_max
                paddle_2.write(new_paddle_pos)
            if direction == "up":
                #print("moving player 2 paddle up")
                new_paddle_pos = paddle_pos - (10 * resolution)
                if new_paddle_pos < paddle_min:
                    new_paddle_pos = paddle_min
                paddle_2.write(new_paddle_pos)
            

    return "", 200, {'Content-Type': 'text/plain'}


if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', help='The host name or ip address to run on', type=str, default='0.0.0.0')
    parser.add_argument('--port', help='The port number the web server will use', type=int, default=5000)
    parser.add_argument('--cert', help='The SSL certificate', type=str)
    parser.add_argument('--key', help='The SSL private key', type=str)
    parser.add_argument('-d', '--debug', help='Enable debugging mode', action="store_true")
    parser.add_argument('-v', '--verbose', help='Enable verbose mode', action="store_true")
    args = parser.parse_args()

    # Use SSL if keys were supplied
    global SECURE
    SECURE = bool(args.key) and bool(args.cert)

    # Display basic info based on command line arguments
    if args.verbose: print("Verbose mode activated")
    if args.debug: print("Debug mode activated")
    if bool(args.cert) != bool(args.key):
        print("ERROR! --cert and --key must be used together")
        exit(1)
    if args.verbose or args.debug:
        if SECURE:
            print("Using HTTPS on port %d" % args.port)
        else:
            print("Using HTTP on port %d" % args.port)
    if SECURE:
        try:
            context = (args.cert, args.key)
            if args.debug:
                app.run(port=args.port, debug=True, ssl_context=context, host=args.host)
            else:
                app.run(port=args.port, debug=False, ssl_context=context, host=args.host)
        except Exception as e:
            if args.debug:
                print(e)
                exit(2)
            else:
                print("ERROR! Invalid certificate ,key, or host")
                print("Use --debug for more info")
                exit(2)
    else:
        app.run(port=args.port, debug=args.debug, host=args.host)
