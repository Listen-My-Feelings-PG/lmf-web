import { Injectable } from '@nestjs/common';
import { Type } from 'class-transformer';
import { IsInt } from 'class-validator';

@Injectable()
export class IntegerDto {
  @Type(() => Number) // Transforma el string recibido en un número
  @IsInt({ message: 'El parámetro debe ser un número entero' }) // Valida que sea un entero
  value: number;
}

@Injectable()
export class BooleanDto {
  @Type(() => Boolean)
  value: boolean;
}
