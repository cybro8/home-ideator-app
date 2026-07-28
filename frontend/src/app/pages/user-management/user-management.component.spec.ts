import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormsModule } from '@angular/forms';
import { RouterTestingModule } from '@angular/router/testing';
import { UserManagementComponent } from './user-management.component';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';
import { SidebarComponent } from '../../shared/sidebar/sidebar.component';
import { of } from 'rxjs';

const mockUsers = [
  { uid:'u1', username:'ravi', email:'r@t.com', is_active:true, created_at:'2025-01-01' },
  { uid:'u2', username:'priya', email:'p@t.com', is_active:false, created_at:'2025-01-02' },
];

describe('UserManagementComponent', () => {
  let component: UserManagementComponent;
  let fixture: ComponentFixture<UserManagementComponent>;
  let apiSpy: jasmine.SpyObj<ApiService>;
  let authSpy: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    apiSpy = jasmine.createSpyObj('ApiService', ['getUsers','toggleUserStatus','deleteUser']);
    authSpy = jasmine.createSpyObj('AuthService', ['hasRole','getRole','logout']);
    authSpy.hasRole.and.returnValue(true);
    apiSpy.getUsers.and.returnValue(of(mockUsers));

    await TestBed.configureTestingModule({
      declarations: [UserManagementComponent, SidebarComponent],
      imports: [FormsModule, RouterTestingModule],
      providers: [{ provide: ApiService, useValue: apiSpy }, { provide: AuthService, useValue: authSpy }],
    }).compileComponents();
    fixture = TestBed.createComponent(UserManagementComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create and render user table', () => {
    expect(component).toBeTruthy();
    expect(fixture.nativeElement.querySelector('#userTable')).toBeTruthy();
  });

  it('renders all seeded users', () => {
    const rows = fixture.nativeElement.querySelectorAll('#userTable tbody tr');
    expect(rows.length).toBe(2);
  });

  it('search input calls loadUsers()', () => {
    spyOn(component, 'loadUsers');
    const input = fixture.nativeElement.querySelector('#userSearch');
    input.value = 'ravi';
    input.dispatchEvent(new Event('input'));
    expect(component.loadUsers).toHaveBeenCalled();
  });

  it('toggle calls toggleUserStatus', () => {
    apiSpy.toggleUserStatus.and.returnValue(of({}));
    component.toggleStatus(mockUsers[0]);
    expect(apiSpy.toggleUserStatus).toHaveBeenCalledWith('u1', false);
  });
});
