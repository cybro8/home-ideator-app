import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormsModule } from '@angular/forms';
import { RouterTestingModule } from '@angular/router/testing';
import { DeviceDataComponent } from './device-data.component';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';
import { SidebarComponent } from '../../shared/sidebar/sidebar.component';
import { of } from 'rxjs';

const mockReadings = [
  { device_id:'d1', timestamp:'2025-01-01T00:00:00', Voltage:230, Current:1.0, Power:230, temperature_C:40, status:'Active', fault_score:0.01, is_anomaly:0 },
];

describe('DeviceDataComponent', () => {
  let component: DeviceDataComponent;
  let fixture: ComponentFixture<DeviceDataComponent>;
  let apiSpy: jasmine.SpyObj<ApiService>;
  let authSpy: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    apiSpy = jasmine.createSpyObj('ApiService', ['getDeviceData','downloadCsv','downloadExcel']);
    authSpy = jasmine.createSpyObj('AuthService', ['hasRole','getRole','logout']);
    authSpy.hasRole.and.returnValue(true);
    apiSpy.getDeviceData.and.returnValue(of(mockReadings));
    apiSpy.downloadCsv.and.returnValue('http://localhost:8003/devices/d1/data/csv');
    apiSpy.downloadExcel.and.returnValue('http://localhost:8003/devices/d1/data/excel');

    await TestBed.configureTestingModule({
      declarations: [DeviceDataComponent, SidebarComponent],
      imports: [FormsModule, RouterTestingModule],
      providers: [{ provide: ApiService, useValue: apiSpy }, { provide: AuthService, useValue: authSpy }],
    }).compileComponents();
    fixture = TestBed.createComponent(DeviceDataComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => expect(component).toBeTruthy());

  it('load() calls getDeviceData and populates table', () => {
    component.deviceId = 'd1';
    component.load();
    fixture.detectChanges();
    expect(apiSpy.getDeviceData).toHaveBeenCalledWith('d1', 200, undefined, undefined);
    expect(component.readings.length).toBe(1);
  });

  it('CSV download button triggers window.open', () => {
    spyOn(window, 'open');
    component.deviceId = 'd1';
    component.downloadCsv();
    expect(window.open).toHaveBeenCalled();
  });

  it('live refresh toggle starts polling', (done) => {
    component.deviceId = 'd1';
    component.toggleLive();
    expect(component.liveRefresh).toBeTrue();
    component.toggleLive();
    expect(component.liveRefresh).toBeFalse();
    done();
  });
});
