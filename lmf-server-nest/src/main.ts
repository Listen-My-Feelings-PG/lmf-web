import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { LogMiddleware } from './_middlewares/log.middleware';
import * as bodyParser from 'body-parser';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({
    origin: '*',
    methods: 'GET,POST,PUT,DELETE,PATCH',
    allowedHeaders: 'Content-Type,Authorization,Accept',
  });

  app.use(bodyParser.json({ limit: '100mb' }));
  app.use(bodyParser.urlencoded({ limit: '100mb', extended: true }));

  app.use(new LogMiddleware().use);
  await app.listen(process.env.TS_PORT || 3002);
}
bootstrap();
