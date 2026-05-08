import { ComponentFixture, TestBed } from '@angular/core/testing';

import { VocadbComponent } from './vocadb.component';

describe('VocadbComponent', () => {
  let component: VocadbComponent;
  let fixture: ComponentFixture<VocadbComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [VocadbComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(VocadbComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
