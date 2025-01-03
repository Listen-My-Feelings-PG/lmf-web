import { Test, TestingModule } from '@nestjs/testing';
import { TsFeatureExtractorService } from './ts-feature-extractor.service';

describe('TsFeatureExtractorService', () => {
  let service: TsFeatureExtractorService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [TsFeatureExtractorService],
    }).compile();

    service = module.get<TsFeatureExtractorService>(TsFeatureExtractorService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
