import { TestBed } from '@angular/core/testing';

import { SongFeaturesService } from './song-features.service';

describe('SongFeaturesService', () => {
  let service: SongFeaturesService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SongFeaturesService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
