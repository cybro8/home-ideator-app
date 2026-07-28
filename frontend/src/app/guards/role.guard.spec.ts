import { TestBed } from '@angular/core/testing';
import { RouterTestingModule } from '@angular/router/testing';
import { ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { RoleGuard } from './role.guard';
import { AuthService } from '../services/auth.service';

describe('RoleGuard', () => {
  let guard: RoleGuard;
  let authSpy: jasmine.SpyObj<AuthService>;

  const mockRoute = (roles: string[]) => {
    const snap = { data: { roles } } as unknown as ActivatedRouteSnapshot;
    return snap;
  };
  const mockState = {} as RouterStateSnapshot;

  beforeEach(() => {
    authSpy = jasmine.createSpyObj('AuthService', ['isLoggedIn','hasRole','getRole','logout']);
    TestBed.configureTestingModule({ imports: [RouterTestingModule], providers: [{ provide: AuthService, useValue: authSpy }] });
    guard = TestBed.inject(RoleGuard);
  });

  it('should create', () => expect(guard).toBeTruthy());

  it('redirects unauthenticated users to /login', () => {
    authSpy.isLoggedIn.and.returnValue(false);
    expect(guard.canActivate(mockRoute([]), mockState)).toBeFalse();
  });

  it('allows admin access to admin-only route', () => {
    authSpy.isLoggedIn.and.returnValue(true);
    authSpy.hasRole.and.returnValue(true);
    expect(guard.canActivate(mockRoute(['admin']), mockState)).toBeTrue();
  });

  it('blocks end_user_admin from admin-only route', () => {
    authSpy.isLoggedIn.and.returnValue(true);
    authSpy.hasRole.and.returnValue(false);
    expect(guard.canActivate(mockRoute(['admin']), mockState)).toBeFalse();
  });

  it('allows ml_user to access device data route', () => {
    authSpy.isLoggedIn.and.returnValue(true);
    authSpy.hasRole.and.returnValue(true);
    expect(guard.canActivate(mockRoute(['admin','ml_user']), mockState)).toBeTrue();
  });
});
