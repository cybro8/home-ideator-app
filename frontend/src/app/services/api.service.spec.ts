import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { ApiService } from './api.service';
import { AuthService } from './auth.service';

describe('ApiService', () => {
  let service: ApiService;
  let http: HttpTestingController;
  let authSpy: jasmine.SpyObj<AuthService>;

  beforeEach(() => {
    authSpy = jasmine.createSpyObj('AuthService', ['getToken','isLoggedIn','logout','hasRole','getRole']);
    authSpy.getToken.and.returnValue('fake_token');
    TestBed.configureTestingModule({
      imports: [HttpClientTestingModule, RouterTestingModule],
      providers: [{ provide: AuthService, useValue: authSpy }],
    });
    service = TestBed.inject(ApiService);
    http = TestBed.inject(HttpTestingController);
  });
  afterEach(() => http.verify());

  it('should create', () => expect(service).toBeTruthy());

  it('getAdmins() attaches Authorization header', () => {
    service.getAdmins().subscribe();
    const req = http.expectOne('http://localhost:8003/admins');
    expect(req.request.headers.get('Authorization')).toBe('Bearer fake_token');
    req.flush([]);
  });

  it('getUsers() calls /users endpoint', () => {
    service.getUsers().subscribe();
    const req = http.expectOne((r) => r.url === 'http://localhost:8003/users');
    expect(req.request.method).toBe('GET');
    req.flush([]);
  });

  it('downloadCsv() returns correct URL', () => {
    expect(service.downloadCsv('device_1')).toContain('/devices/device_1/data/csv');
  });

  it('downloadExcel() returns correct URL', () => {
    expect(service.downloadExcel('device_1')).toContain('/devices/device_1/data/excel');
  });

  it('401 response triggers logout', () => {
    service.getAdmins().subscribe({ error: () => {} });
    const req = http.expectOne('http://localhost:8003/admins');
    req.flush({ detail: 'Unauthorized' }, { status: 401, statusText: 'Unauthorized' });
    expect(authSpy.logout).toHaveBeenCalled();
  });
});
