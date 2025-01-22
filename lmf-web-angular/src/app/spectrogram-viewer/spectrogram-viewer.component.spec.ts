import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SpectrogramViewerComponent } from './spectrogram-viewer.component';

describe('SpectrogramViewerComponent', () => {
  let component: SpectrogramViewerComponent;
  let fixture: ComponentFixture<SpectrogramViewerComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SpectrogramViewerComponent]
    })
    .compileComponents();
    
    fixture = TestBed.createComponent(SpectrogramViewerComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
