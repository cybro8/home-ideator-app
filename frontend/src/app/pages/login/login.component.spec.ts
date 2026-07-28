import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { RouterTestingModule } from '@angular/router/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { LoginComponent } from './login.component';
import { AuthService } from '../../services/auth.service';
import { of, throwError } from 'rxjs';

describe('LoginComponent', () => {
  let component: LoginComponent;
  let fixture: ComponentFixture<LoginComponent>;
  let authSpy: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    authSpy = jasmine.createSpyObj('AuthService', ['login','isLoggedIn','getRole']);
    await TestBed.configureTestingModule({
      declarations: [LoginComponent],
      imports: [ReactiveFormsModule, RouterTestingModule, HttpClientTestingModule],
      providers: [{ provide: AuthService, useValue: authSpy }],
    }).compileComponents();
    fixture = TestBed.createComponent(LoginComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create and render form fields', () => {
    expect(component).toBeTruthy();
    const compiled = fixture.nativeElement as HTMLElement;
    expect(compiled.querySelector('#email')).toBeTruthy();
    expect(compiled.querySelector('#password')).toBeTruthy();
    expect(compiled.querySelector('#loginSubmit')).toBeTruthy();
  });

  it('should show validation error for empty email', () => {
    component.form.get('email')?.markAsTouched();
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('.err')).toBeTruthy();
  });

  it('submit() calls AuthService.login() with form values', () => {
    authSpy.login.and.returnValue(of({ access_token: 'tok', role: 'admin', token_type: 'bearer' }));
    component.form.setValue({ email: 'admin@test.com', password: 'Test@1234' });
    component.submit();
    expect(authSpy.login).toHaveBeenCalledWith('admin@test.com', 'Test@1234');
  });

  it('sets error message on login failure', () => {
    authSpy.login.and.returnValue(throwError(() => new Error('Unauthorized')));
    component.form.setValue({ email: 'bad@test.com', password: 'bad123' });
    component.submit();
    expect(component.error).toBe('Invalid email or password.');
  });

  it('does not submit when form is invalid', () => {
    component.form.setValue({ email: '', password: '' });
    component.submit();
    expect(authSpy.login).not.toHaveBeenCalled();
  });
});
