import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-admin-management', templateUrl: './admin-management.component.html', styleUrls: ['./admin-management.component.css'] })
export class AdminManagementComponent implements OnInit {
  admins: any[] = [];
  loading = true;
  showModal = false;
  newAdmin = { username: '', email: '', password: '', role: 'end_user_admin' };
  error = '';

  constructor(private api: ApiService) {}

  ngOnInit(): void { this.loadAdmins(); }

  loadAdmins(): void {
    this.api.getAdmins().subscribe({ next: (data) => { this.admins = data; this.loading = false; }, error: () => { this.loading = false; } });
  }

  createAdmin(): void {
    this.api.createAdmin(this.newAdmin).subscribe({ next: () => { this.showModal = false; this.newAdmin = { username: '', email: '', password: '', role: 'end_user_admin' }; this.loadAdmins(); }, error: (e) => { this.error = e.error?.detail ?? 'Failed to create admin.'; } });
  }

  toggleStatus(admin: any): void {
    this.api.toggleAdminStatus(admin.id, !admin.is_active).subscribe({ next: () => this.loadAdmins() });
  }

  deleteAdmin(id: number): void {
    if (!confirm('Delete this admin account?')) return;
    this.api.deleteAdmin(id).subscribe({ next: () => this.loadAdmins() });
  }
}
