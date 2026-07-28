import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormsModule } from '@angular/forms';
import { RouterTestingModule } from '@angular/router/testing';
import { AdminManagementComponent } from './admin-management.component';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';
import { SidebarComponent } from '../../shared/sidebar/sidebar.component';
import { of } from 'rxjs';

const mockAdmins = [
  { id:1, username:'admin', email:'a@t.com', role:'admin', is_active:true, created_at:'2025-01-01' },
  { id:2, username:'ml', email:'m@t.com', role:'ml_user', is_active:false, created_at:'2025-01-02' },
];

describe('AdminManagementComponent', () => {
  let component: AdminManagementComponent;
  let fixture: ComponentFixture<AdminManagementComponent>;
  let apiSpy: jasmine.SpyObj<ApiService>;
  let authSpy: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    apiSpy = jasmine.createSpyObj('ApiService', ['getAdmins','createAdmin','toggleAdminStatus','deleteAdmin']);
    authSpy = jasmine.createSpyObj('AuthService', ['hasRole','getRole','logout']);
    authSpy.hasRole.and.returnValue(true);
    apiSpy.getAdmins.and.returnValue(of(mockAdmins));

    await TestBed.configureTestingModule({
      declarations: [AdminManagementComponent, SidebarComponent],
      imports: [FormsModule, RouterTestingModule],
      providers: [{ provide: ApiService, useValue: apiSpy }, { provide: AuthService, useValue: authSpy }],
    }).compileComponents();
    fixture = TestBed.createComponent(AdminManagementComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create and render admin table', () => {
    expect(component).toBeTruthy();
    expect(fixture.nativeElement.querySelector('#adminTable')).toBeTruthy();
  });

  it('renders seeded admin list', () => {
    const rows = fixture.nativeElement.querySelectorAll('#adminTable tbody tr');
    expect(rows.length).toBe(2);
  });

  it('create button opens modal', () => {
    fixture.nativeElement.querySelector('#createAdminBtn').click();
    fixture.detectChanges();
    expect(fixture.nativeElement.querySelector('#createAdminModal')).toBeTruthy();
  });

  it('role dropdown shows 3 options', () => {
    component.showModal = true;
    fixture.detectChanges();
    const opts = fixture.nativeElement.querySelectorAll('#newAdminRole option');
    expect(opts.length).toBe(3);
  });

  it('delete calls API and reloads', () => {
    spyOn(window, 'confirm').and.returnValue(true);
    apiSpy.deleteAdmin.and.returnValue(of(undefined as any));
    component.deleteAdmin(1);
    expect(apiSpy.deleteAdmin).toHaveBeenCalledWith(1);
  });
});
