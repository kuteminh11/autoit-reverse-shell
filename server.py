#todo non blocking I/O

from socket import *
import thread

HOST = '127.0.0.1'
PORT = 8888
MAX_CONNECTION = 1024
client_list = [] #list of accepted connection

s = socket()
s.bind((HOST, PORT))
s.listen(MAX_CONNECTION)

def wait_for_connection():
    while 1:
        (conn, addr) = s.accept()
        client_list.append((conn, addr))
        print '#connection from', addr

thread.start_new_thread(wait_for_connection, ()) #seperate thread for accepting connection
print '#waiting for connection'

idx = 0
while 1:
    if len(client_list) != 0:
        cmd = raw_input('> ')
        if cmd.startswith('switch'):
            try:
                idx = int(cmd[7: ])
                print '#change to', client_list[idx][1]
            except:
                print 'can\'t switch'
        else:
            conn = client_list[idx][0]
            conn.send(cmd)
            print conn.recv(1024)
