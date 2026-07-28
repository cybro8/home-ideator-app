import { TestBed } from '@angular/core/testing';
import { HttpClientTestingModule, HttpTestingController } from '@angular/common/http/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { AuthService } from './auth.service';

describe('AuthService', () => {
  let service: AuthService;
  let http: HttpTestingController;

  beforeEach(() => {
    TestBed.configureTestingModule({ imports: [HttpClientTestingModule, RouterTestingModule] });
    service = TestBed.inject(AuthService);
    http = TestBed.inject(HttpTestingController);
    localStorage.clear();
  });
  afterEach(() => http.verify());

  it('should create', () => expect(service).toBeTruthy());

  it('login() POSTs to /auth/login and stores token', () => {
    service.login('admin@test.com', 'Test@1234').subscribe();
    const req = http.expectOne('http://localhost:8003/auth/login');
    expect(req.request.method).toBe('POST');
    req.flush({ access_token: 'fake.jwt.token', role: 'admin' });
    expect(localStorage.getItem('hi_admin_token')).toBe('fake.jwt.token');
  });

  it('logout() clears token from localStorage', () => {
    localStorage.setItem('hi_admin_token', 'some_token');
    service.logout();
    expect(localStorage.getItem('hi_admin_token')).toBeNull();
  });

  it('isLoggedIn() returns false when no token', () => {
    expect(service.isLoggedIn()).toBeFalse();
  });

  it('getRole() returns empty string when not logged in', () => {
    expect(service.getRole()).toBe('');
  });

  it('hasRole() returns false for unknown role', () => {
    expect(service.hasRole('admin')).toBeFalse();
  });
});
