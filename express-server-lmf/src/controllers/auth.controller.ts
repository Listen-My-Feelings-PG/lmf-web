import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import { psql } from '../main';
import { encode } from '../services/jwt.service';

export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      res.status(400).json({ success: false, message: 'Usuario y contraseña son requeridos' });
      return;
    }

    // Buscar el usuario en la BD
    const users = await psql`
      SELECT us_id, us_username, us_password, us_activo 
      FROM public.usuarios 
      WHERE us_username = ${username} AND us_activo = B'1'
    `;

    if (users.length === 0) {
      res.status(401).json({ success: false, message: 'Credenciales inválidas' });
      return;
    }

    const user = users[0];

    // Verificar la contraseña con bcrypt
    const isMatch = await bcrypt.compare(password, user.us_password);
    if (!isMatch) {
      res.status(401).json({ success: false, message: 'Credenciales inválidas' });
      return;
    }

    // Generar el token (válido por 1 día)
    const payload = {
      us_id: user.us_id,
      username: user.us_username
    };

    encode(payload, '1d', (token: string) => {
      res.status(200).json({
        success: true,
        token,
        user: {
          id: user.us_id,
          username: user.us_username
        }
      });
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ success: false, message: 'Error interno del servidor' });
  }
};
