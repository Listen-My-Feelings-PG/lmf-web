import jwt, { SignOptions } from 'jsonwebtoken';
import { Request, Response, NextFunction } from 'express';

/**
 * Interface para decodificar JWT (puede ampliarse según lo que se guarde)
 */
export interface JwtPayload {
  username: string;
  [key: string]: any;
}

// Extender el Request de Express para incluir 'user'
declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload | string;
    }
  }
}

/**
 * Codifica datos en un token JWT
 * @param data - Datos para codificar dentro del token
 * @param expiresIn - Tiempo de expiración del token (ej: '1d', '2h'). Si es null, el token jamás va a expirar
 * @param cb - Función callback con el token
 */
export const encode = (data: any, expiresIn: string | null, cb: (token: string) => void): void => {
  const key = process.env.JWTKEY || 'secret_fallback_key';
  const options: SignOptions = expiresIn ? { expiresIn: expiresIn as any } : {};
  const token = jwt.sign(JSON.parse(JSON.stringify(data)), key, options);
  cb(token);
};

/**
 * Decodifica y verifica un token JWT
 * @param token - Token codificado
 * @param cb - Función callback con (error, decode)
 */
export const decode = (token: string, cb: (error: any, decode: any) => void): void => {
  const key = process.env.JWTKEY || 'secret_fallback_key';
  jwt.verify(token, key, (error, decode) => {
    cb(
      error ? (error.name === 'TokenExpiredError' ? 'Token expired' : error) : decode,
      error ? null : decode
    );
  });
};

/**
 * Middleware para verificar tokens JWT en peticiones HTTP
 * @param req - Request
 * @param res - Response
 * @param next - NextFunction
 */
export const checkToken = (req: Request, res: Response, next: NextFunction): void => {
  const key = process.env.JWTKEY || 'secret_fallback_key';
  
  // Excluir la ruta de login de la validación
  if (req.originalUrl.includes('/api/v1/auth/login')) {
    next();
    return;
  }

  let token = req.headers.authorization;
  if (token) {
    token = token.replace('Bearer ', '');
    jwt.verify(token, key, (error, decoded) => {
      if (error) {
        if (error.name === 'TokenExpiredError') {
          console.info('Token expired', new Date().toLocaleString());
          res.status(401).json({
            success: false,
            expiredTime: true,
            message: 'Token expired'
          });
        } else {
          console.error('Error in token:', error);
          res.status(401).json({
            success: false,
            message: 'Invalid token'
          });
        }
      } else {
        req.user = decoded as JwtPayload;
        next();
      }
    });
  } else {
    res.status(403).json({
      success: false,
      message: 'Forbidden: No token provided'
    });
  }
};
