import { Injectable, NestMiddleware } from '@nestjs/common';

@Injectable()
export class LogMiddleware implements NestMiddleware {
  use(req: any, res: any, next: () => void) {
    console.log(`${req.url} ${req.method} ${new Date().toLocaleString()}`);
    next();
  }
}
