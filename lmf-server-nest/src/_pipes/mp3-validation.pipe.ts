import { ArgumentMetadata, BadRequestException, Injectable, PipeTransform } from '@nestjs/common';

@Injectable()
export class Mp3ValidationPipe implements PipeTransform {
  private readonly allowedMimeTypes = ['audio/mpeg'];
  private readonly maxFileSize = 20 * 1024 * 1024;
  transform(file: any, metadata: ArgumentMetadata) {
    if (!file)
      throw new BadRequestException('No file provided');

    if (!this.allowedMimeTypes.includes(file.mimetype))
      throw new BadRequestException(`Invalid file type. Only MP3 files are allowed.`);

    if (file.size > this.maxFileSize)
      throw new BadRequestException(`File size exceeds the limit of 20 MB.`);

    return file;
  }
}
