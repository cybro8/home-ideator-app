import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { jwtDecode } from 'jwt-decode';

export interface LoginResponse {
  access_token: string;
  token_type: string;
  role: string;
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly adminApiUrl = 'http://localhost:8003';
  private readonly TOKEN_KEY = 'hi_admin_token';

  constructor(private http: HttpClient, private router: Router) {}

  login(email: string, password: string): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse>(`${this.adminApiUrl}/auth/login`, { email, password })
      .pipe(tap((res) => localStorage.setItem(this.TOKEN_KEY, res.access_token)));
  }

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    this.router.navigate(['/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  isLoggedIn(): boolean {
    const token = this.getToken();
    if (!token) return false;
    try {
      const decoded: any = jwtDecode(token);
      return decoded.exp * 1000 > Date.now();
    } catch {
      return false;
    }
  }

  getRole(): string {
    const token = this.getToken();
    if (!token) return '';
    try {
      const decoded: any = jwtDecode(token);
      return decoded.role ?? '';
    } catch {
      return '';
    }
  }

  hasRole(...roles: string[]): boolean {
    return roles.includes(this.getRole());
  }
}
