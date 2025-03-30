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
import { Repository } from 'typeorm';
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

  @Post('song')
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
        let plsRowGlobal;
        const plsRow = await this.songsPlaylistsTable.save(this.songsPlaylistsTable.create({
          idSong: { id: sRow.id } as SongEntity,
          idPlaylist: { id: body.idPlaylist } as PlaylistEntity
        }));
        if (body.idPlayList != body.idPlayListGlobal)
          plsRowGlobal = await this.songsPlaylistsTable.save(this.songsPlaylistsTable.create({
            idSong: { id: sRow.id } as SongEntity,
            idPlaylist: { id: body.idPlaylistGlobal } as PlaylistEntity
          }));
        return {
          message: 'uploaded successful',
          data: {
            sRow,
            plsRow,
            plsRowGlobal: plsRowGlobal ? plsRowGlobal : null
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
    const gzipFileName = path.basename(gzipFilePath);
    try {
      const fileContent = await fs.promises.readFile(filePath);
      const compressedContent = await gzip(fileContent);
      await writeFile(gzipFilePath, compressedContent);
      await fs.unlinkSync(filePath);

      const data: {
        playlist: {
          idSelected: number,
          idGlobal: number
        },
        models: {
          idSelected: number,
          idGlobal: number
        }
      } = JSON.parse(body.data);

      if (Object.keys(data.models).length > 0) { //Significa que al menos uno de los dos modelos ya existe
        if (data.models.idGlobal) { //Si existe un modelo global...
          const idGlobalModel = data.models.idGlobal;
          const globalModel = await this.modelTable.findOne({ where: { isGlobal: true } }); //Modelo global para one_user (un único modelo en la base de datos)
          if (globalModel.id != idGlobalModel) //Validación de seguridad si existe un modelo global en la base de datos
            throw new HttpException('Error de seguridad: el id del modelo de la playlist global obtenido no coincide con el modelo de la playlist de la base de datos', HttpStatus.FORBIDDEN);
          const oldFilePath = path.resolve(this.cf.get<string>('TS_PATH_MODELS'), globalModel.fileName);
          const trainCount = globalModel.trainCount + 1;
          await fs.unlinkSync(oldFilePath);
          await this.modelTable.update(globalModel.id, { fileName: file.filename, trainCount });
          if (data.models.idSelected) { //Si existe un modelo para la playlist actual...
            const idPlayList = data.models.idSelected;
            const playlistModel = await this.modelTable.findOne({ where: { id: data.models.idSelected } });
            if (playlistModel.id != idPlayList)
              throw new HttpException('Error de seguridad: el id del modelo de la playlist actual obtenido no coincide con el modelo de la playlist de la base de datos', HttpStatus.FORBIDDEN);
            if (idPlayList != idGlobalModel) { //Si el id de la playlist no es el mismo que el del modelo global significa que hay que actualizar el modelo de la playlist
              const oldFilePath = path.resolve(this.cf.get<string>('TS_PATH_MODELS'), playlistModel.fileName) + '.gz';
              const trainCount = playlistModel.trainCount + 1;
              await fs.unlinkSync(oldFilePath);
              await this.modelTable.update(playlistModel.id, { fileName: file.filename, trainCount });
            } //Ya que si son iguales, nos estamos refiriendo únicamente al modelo global
          } else {
            const idSelectedPlaylist = data.models.idSelected;
            const newPlaylistModel = await this.modelTable.save(this.modelTable.create({
              fileName: gzipFileName,
              trainCount: 1,
              isGlobal: false
            }));
            await this.playlistTable.update(idSelectedPlaylist, { idModel: { id: newPlaylistModel.id } });
          }
        } else
          throw new HttpException('Error de seguridad: el id del modelo global es obligatorio', HttpStatus.FORBIDDEN);
        return { message: 'Modelos actualizados exitosamente' };
      } else { //Significa que no hay ningun modelo existente
        const idGlobalPlaylist = data.playlist.idGlobal;
        const idSelectedPlaylist = data.playlist.idSelected;
        let idPlaylistModel = null;
        if (idGlobalPlaylist != idSelectedPlaylist) { //Significa que la lista seleccionada es diferente a la lista global, por lo cual, este bloque se dedicará a crear un modelo para la lista seleccionada, pero aun asi, es necesario crear un modelo global y entrenarlo con el modelo de la lista seleccionada
          const newPlaylistModel = await this.modelTable.save(this.modelTable.create({
            fileName: gzipFileName,
            trainCount: 1,
            isGlobal: false
          }));
          await this.playlistTable.update(idSelectedPlaylist, { idModel: { id: newPlaylistModel.id } });
          idPlaylistModel = newPlaylistModel.id;
        }

        const newGlobalModel = await this.modelTable.save(this.modelTable.create({
          fileName: gzipFileName,
          trainCount: 1,
          isGlobal: true
        }));
        await this.playlistTable.update(idGlobalPlaylist, { idModel: { id: newGlobalModel.id } });

        return { message: 'Modelos actualizados exitosamente', data: { idGlobalModel: newGlobalModel.id, idPlaylistModel } };
      }
    } catch (error) {
      console.error('Error al comprimir el archivo:', error);
      throw new HttpException('Error al comprimir el archivo', HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }

}
