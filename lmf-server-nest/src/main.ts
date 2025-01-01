import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as fileUpload from 'express-fileupload';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: 'http://localhost:4200',
    methods: 'GET,POST,PUT,DELETE,PATCH,OPTIONS',
    allowedHeaders: 'Content-Type,Authorization',
  });

  app.use(
    fileUpload({
      limits: { fileSize: 100 * 1024 * 1024 }, // 100 MB
      useTempFiles: true,
      tempFileDir: '/tmp/',
    }),
  );

  
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
