import { Server as HttpServer } from 'http';
import { Server as SocketIOServer, Socket } from 'socket.io';
import { checkTokenSocket } from './jwt.service';

let io: SocketIOServer;
const listConnected: { id: string, user: any }[] = [];

/**
 * Servicio: Inicializa el servidor de WebSockets (Socket.IO) y maneja las conexiones.
 * Se encarga de la validación del JWT en cada conexión entrante para asegurar
 * que solo usuarios autenticados puedan suscribirse a la sala principal y recibir
 * los eventos en tiempo real (ej: progreso de entrenamiento, extracción).
 * 
 * @param server Instancia del servidor HTTP nativo de Node.js donde se monta Express
 */
export const initSocket = (server: HttpServer): void => {
  io = new SocketIOServer(server, {
    cors: {
      origin: ['http://localhost:4200', 'http://localhost:5173'],
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      credentials: true
    }
  });

  io.use((socket: Socket, next) => {
    const handshakeData = socket.handshake || socket.request;
    const token = handshakeData.headers['authorization'] as string;
    checkTokenSocket(token, socket, next);
  }).on('connection', (socket: any) => {
    console.info('SOCKET CONNECTED <=', socket.id, new Date().toLocaleString());
    
    const user = socket.user;
    if (user) {
      delete user.exp;
      delete user.iat;
    }
    
    const room = 'main_room';
    socket.join(room);
    listConnected.push({ id: socket.id, user });

    socket.on('disconnect', () => {
      const index = listConnected.findIndex(obj => obj.id === socket.id);
      if (index !== -1) {
        listConnected.splice(index, 1);
      }
      console.info('SOCKET DISCONNECTED <=', socket.id, new Date().toLocaleString());
    });
  });
};

/**
 * Emite un evento de inicio de tarea
 */
export const emitTaskExec = (message: any): void => {
  if (io) {
    io.to('main_room').emit('task-exec', message);
    console.info('SOCKET EMMITING => task-exec', message);
  }
};

/**
 * Emite un evento de finalización de tarea
 */
export const emitTaskFinish = (message: any): void => {
  if (io) {
    io.to('main_room').emit('task-finish', message);
    console.info('SOCKET EMMITING => task-finish', message);
  }
};
