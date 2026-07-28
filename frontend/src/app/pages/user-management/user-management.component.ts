import { Component, OnInit } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-user-management', templateUrl: './user-management.component.html', styleUrls: ['./user-management.component.css'] })
export class UserManagementComponent implements OnInit {
  users: any[] = []; loading = true; search = '';

  constructor(private api: ApiService) {}
  ngOnInit(): void { this.loadUsers(); }

  loadUsers(): void {
    this.api.getUsers(this.search).subscribe({ next: (d) => { this.users = d; this.loading = false; }, error: () => { this.loading = false; } });
  }

  toggleStatus(u: any): void {
    this.api.toggleUserStatus(u.uid, !u.is_active).subscribe({ next: () => this.loadUsers() });
  }

  deleteUser(uid: string): void {
    if (!confirm('Delete this user?')) return;
    this.api.deleteUser(uid).subscribe({ next: () => this.loadUsers() });
  }
}
