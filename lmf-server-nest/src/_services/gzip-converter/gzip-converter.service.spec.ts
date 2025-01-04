import { Test, TestingModule } from '@nestjs/testing';
import { GzipConverterService } from './gzip-converter.service';

describe('GzipConverterService', () => {
  let service: GzipConverterService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [GzipConverterService],
    }).compile();

    service = module.get<GzipConverterService>(GzipConverterService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
