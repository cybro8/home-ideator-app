import { Injectable } from '@angular/core';
import {
  CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router,
} from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({ providedIn: 'root' })
export class RoleGuard implements CanActivate {
  constructor(private auth: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot, _state: RouterStateSnapshot): boolean {
    if (!this.auth.isLoggedIn()) {
      this.router.navigate(['/login']);
      return false;
    }
    const allowedRoles: string[] = route.data['roles'] ?? [];
    if (allowedRoles.length && !this.auth.hasRole(...allowedRoles)) {
      this.router.navigate(['/forbidden']);
      return false;
    }
    return true;
  }
}
