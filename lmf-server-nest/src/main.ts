import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as fileUpload from 'express-fileupload';
import { LogMiddleware } from './_middlewares/log.middleware';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    origin: 'http://localhost:4200',
    methods: 'GET,POST,PUT,DELETE,PATCH,OPTIONS',
    allowedHeaders: 'Content-Type,Authorization,Accept',
  });
  app.use(new LogMiddleware().use);
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
