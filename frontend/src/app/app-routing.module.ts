import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { RoleGuard } from './guards/role.guard';
import { LoginComponent } from './pages/login/login.component';
import { AdminManagementComponent } from './pages/admin-management/admin-management.component';
import { UserManagementComponent } from './pages/user-management/user-management.component';
import { DeviceDataComponent } from './pages/device-data/device-data.component';

const routes: Routes = [
  { path: '', redirectTo: '/admin/users', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  {
    path: 'admin/accounts',
    component: AdminManagementComponent,
    canActivate: [RoleGuard],
    data: { roles: ['admin'] },
  },
  {
    path: 'admin/users',
    component: UserManagementComponent,
    canActivate: [RoleGuard],
    data: { roles: ['admin', 'end_user_admin'] },
  },
  {
    path: 'admin/devices',
    component: DeviceDataComponent,
    canActivate: [RoleGuard],
    data: { roles: ['admin', 'ml_user'] },
  },
  { path: 'forbidden', redirectTo: '/login' },
  { path: '**', redirectTo: '/login' },
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule],
})
export class AppRoutingModule {}
