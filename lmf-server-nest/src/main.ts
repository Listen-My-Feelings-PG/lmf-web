import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { LogMiddleware } from './_middlewares/log.middleware';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    origin: '*',
    methods: 'GET,POST,PUT,DELETE,PATCH',
    allowedHeaders: 'Content-Type,Authorization,Accept',
  });
  app.use(new LogMiddleware().use);
  await app.listen(process.env.TS_PORT || 3000);
}
bootstrap();
