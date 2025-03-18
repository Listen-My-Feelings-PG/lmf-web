import {
  Body,
  Controller,
  HttpException,
  HttpStatus,
  Post,
  UploadedFile,
  UseInterceptors
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { diskStorage } from 'multer';
import { SongEntity } from 'src/_entities/song.entity';
import {  Repository } from 'typeorm';
import { Mp3ValidationPipe } from 'src/_pipes/mp3-validation.pipe';
import * as fs from 'fs';
import * as path from 'path';
import { ConfigService } from '@nestjs/config';
import { SongsPlaylistsEntity } from 'src/_entities/songs-playlists.entity';
import { PlaylistEntity } from 'src/_entities/playlist.entity';
import { writeFile } from 'fs/promises';
import * as zlib from 'zlib';
import { promisify } from 'util';
import { ModelEntity } from 'src/_entities/model.entity';


@Controller('upload')
export class UploadController {
  constructor(
    @InjectRepository(SongEntity) private readonly songsTable: Repository<SongEntity>,
    @InjectRepository(SongsPlaylistsEntity) private readonly songsPlaylistsTable: Repository<SongsPlaylistsEntity>,
    @InjectRepository(ModelEntity) private readonly modelTable: Repository<ModelEntity>,
    @InjectRepository(PlaylistEntity) private readonly playlistTable: Repository<PlaylistEntity>,
    private readonly cf: ConfigService
  ) { }

  @Post('file')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: (req, file, cb) => {
        const cf: ConfigService = new ConfigService();
        cb(null, cf.get<string>('TS_PATH_UPLOADS'))
      },
      filename: ((req, file, cb) => {
        const uniqueSuffix = new Date().getTime();
        const sanitizedFilename = Buffer.from(file.originalname, 'latin1').toString('utf8');
        cb(null, `${uniqueSuffix}_${sanitizedFilename}`);
      })
    })
  }))
  async uploadHandler(
    @UploadedFile(new Mp3ValidationPipe()) file: Express.Multer.File,
    @Body() body: any
  ) {
    const idExistingSong = await this.songsTable.findOne({
      select: ['id'],
      where: {
        name: body.name,
        fileSize: file.size,
        active: true
      }
    });

    const filePath = path.resolve(this.cf.get<string>('TS_PATH_UPLOADS'), file.filename);
    if (idExistingSong) {
      if (fs.existsSync(filePath))
        await fs.unlinkSync(filePath);
      console.info('Canción duplicada. Borrada del servidor:', file.filename, new Date().toLocaleString());

      const plsRow = await this.songsPlaylistsTable.findOne({
        where: { idSong: { id: idExistingSong.id }, idPlaylist: { id: body.idPlaylist } }
      });

      if (!plsRow) {
        await this.songsPlaylistsTable.save(
          this.songsPlaylistsTable.create({
            idSong: { id: idExistingSong.id } as SongEntity,
            idPlaylist: { id: body.idPlaylist } as PlaylistEntity
          })
        );

        return {
          message: 'song added to playlist',
          data: {
            sRow: { id: idExistingSong.id },
          }
        }

      } else {
        console.error('Canción duplicada en playlist:', idExistingSong.id, body.idPlaylist);
        throw new HttpException('Duplicated song', HttpStatus.FORBIDDEN);
      }
    } else {
      const name = body.name;
      try {
        const sRow = await this.songsTable.save(this.songsTable.create({
          name: name,
          idDataType: 1,
          tsStatus: null,
          tsInitStatus: body.tsInitStatus,
          fileSize: file.size,
          fileName: file.filename,
          userScore: body.userScore !== undefined ? body.userScore : null,
          tsPrediction: body.tsPrediction !== undefined ? body.tsPrediction : null
        }));/*Regla: Todo lo que sea 'undefined' es porque en el front es NULL (un valor 0 es válido). 
       Cuando sea necesario en la operación, este debe permitir nulos, o tener un valor por default*/
        const plsRow = await this.songsPlaylistsTable.save(this.songsPlaylistsTable.create({
          idSong: { id: sRow.id } as SongEntity,
          idPlaylist: { id: body.idPlaylist } as PlaylistEntity
        }));
        return {
          message: 'uploaded successful',
          data: {
            sRow,
            plsRow
          }
        }
      } catch (error) {
        await fs.unlinkSync(filePath);
        console.error('Error en inserción SQL:', error);
        throw new HttpException('Error in SQL insertion', HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
  }

  @Post('model-weights')
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
      destination: (req, file, cb) => {
        const cf: ConfigService = new ConfigService();
        cb(null, cf.get<string>('TS_PATH_MODELS'))
      },
      filename: ((req, file, cb) => {
        const uniqueSuffix = new Date().getTime();
        const sanitizedFilename = Buffer.from(file.originalname, 'latin1').toString('utf8');
        cb(null, `${uniqueSuffix}_${sanitizedFilename}`);
      })
    })
  }))
  async setModelWeights(@UploadedFile() file: Express.Multer.File, @Body() body: any) {
    const gzip = promisify(zlib.gzip);
    const filePath = path.resolve(this.cf.get<string>('TS_PATH_MODELS'), file.filename);
    const gzipFilePath = `${filePath}.gz`;
    try {
      const fileContent = await fs.promises.readFile(filePath);
      const compressedContent = await gzip(fileContent);
      await writeFile(gzipFilePath, compressedContent);
      console.info('Compressed file:', gzipFilePath);
      await fs.unlinkSync(filePath);
      const globalModel = await this.modelTable.findOne({ where: { isGlobal: true } }); //Modelo global para one_user (un único modelo en la base de datos)
      if (globalModel) {
        const oldFilePath = path.resolve(this.cf.get<string>('TS_PATH_MODELS'), globalModel.fileName) + '.gz';
        const trainCount = globalModel.trainCount + 1;
        await fs.unlinkSync(oldFilePath);
        await this.modelTable.update(globalModel.id, { fileName: file.filename, trainCount });
        return updatePlayListModel(this, compressedContent);
      } else {
        const newGlobalModel = await this.modelTable.save(this.modelTable.create({
          fileName: file.filename,
          trainCount: 1,
          isGlobal: true
        }));
        console.info('Global model created:', newGlobalModel, new Date().toLocaleString());
        return updatePlayListModel(this, compressedContent);
      }
    } catch (error) {
      console.error('Error al comprimir el archivo:', error);
      throw new HttpException('Error al comprimir el archivo', HttpStatus.INTERNAL_SERVER_ERROR);
    }

    async function updatePlayListModel(that, compressedContent) {
      const playlist = await that.playlistTable.findOne({ where: { id: body.playList.id, isGlobal: false }, relations: ['idModel'] });
      if (playlist) {
        if (playlist.idModel) {
          const model = await that.modelTable.findOne({ where: { id: playlist.idModel.id } });
          const trainCount = model.trainCount + 1;
          const oldFilePath = path.resolve(that.cf.get('TS_PATH_MODELS'), model.fileName) + '.gz';
          await fs.unlinkSync(oldFilePath);
          const defaultModelFilePath = filePath.replace('.json', '-default.json');
          const defaultModelFileName = file.filename.replace('.json', '-default.json');
          await writeFile(defaultModelFilePath + '.gz', compressedContent);
          await that.modelTable.update(model.id, { fileName: defaultModelFileName, trainCount });
        } else {
          const defaultModelFilePath = filePath.replace('.json', '-default.json');
          const defaultModelFileName = file.filename.replace('.json', '-default.json');
          await writeFile(defaultModelFilePath + '.gz', compressedContent);
          const newModel = await that.modelTable.save(that.modelTable.create({
            fileName: defaultModelFileName,
            trainCount: 1,
            isGlobal: false
          }));
          await that.playlistTable.update(playlist.id, { idModel: newModel });
        }

        return {
          message: 'Modelos actualizados existosamente'
        };
      } else {
        console.error('Error al extraer los datos de la lista de reproducción');
        throw new HttpException('Error al obtener la información de la playlist', HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
  }

}
