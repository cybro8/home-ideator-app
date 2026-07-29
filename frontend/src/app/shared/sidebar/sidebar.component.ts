import { Component, HostListener } from '@angular/core';
import { AuthService } from '../../services/auth.service';
import { Router } from '@angular/router';

@Component({ selector: 'app-sidebar', templateUrl: './sidebar.component.html', styleUrls: ['./sidebar.component.css'] })
export class SidebarComponent {
  isCollapsed = false;

  constructor(public auth: AuthService, private router: Router) {
    // Auto-collapse on small screens at load
    this.isCollapsed = window.innerWidth < 768;
  }

  @HostListener('window:resize', ['$event'])
  onResize(event: any): void {
    this.isCollapsed = event.target.innerWidth < 768;
  }

  toggle(): void {
    this.isCollapsed = !this.isCollapsed;
  }

  onNavClick(): void {
    // On mobile, collapse sidebar after navigating
    if (window.innerWidth < 768) {
      this.isCollapsed = true;
    }
  }

  logout(): void { this.auth.logout(); }
}
