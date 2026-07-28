import { Component } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({ selector: 'app-sidebar', templateUrl: './sidebar.component.html', styleUrls: ['./sidebar.component.css'] })
export class SidebarComponent {
  constructor(public auth: AuthService, private router: Router) {}
  logout(): void { this.auth.logout(); }
}
