import { Injectable } from '@angular/core';
import {
  HttpClient, HttpHeaders, HttpParams, HttpErrorResponse,
} from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Router } from '@angular/router';
import { AuthService } from './auth.service';

@Injectable({ providedIn: 'root' })
export class ApiService {
  readonly baseUrl = 'http://localhost:8003';

  constructor(
    private http: HttpClient,
    private auth: AuthService,
    private router: Router,
  ) {}

  private get headers(): HttpHeaders {
    const token = this.auth.getToken();
    return new HttpHeaders({ Authorization: `Bearer ${token}` });
  }

  private handleError(err: HttpErrorResponse) {
    if (err.status === 401) this.auth.logout();
    return throwError(() => err);
  }

  // ── Admins ──────────────────────────────────────────────────────────
  getAdmins(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/admins`, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  createAdmin(body: any): Observable<any> {
    return this.http.post<any>(`${this.baseUrl}/admins`, body, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  updateAdmin(id: number, body: any): Observable<any> {
    return this.http.patch<any>(`${this.baseUrl}/admins/${id}`, body, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  toggleAdminStatus(id: number, isActive: boolean): Observable<any> {
    return this.http.patch<any>(`${this.baseUrl}/admins/${id}/status`, { is_active: isActive }, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  deleteAdmin(id: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/admins/${id}`, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  // ── End Users ────────────────────────────────────────────────────────
  getUsers(search?: string, skip = 0, limit = 50): Observable<any[]> {
    let params = new HttpParams().set('skip', skip).set('limit', limit);
    if (search) params = params.set('search', search);
    return this.http.get<any[]>(`${this.baseUrl}/users`, { headers: this.headers, params })
      .pipe(catchError((e) => this.handleError(e)));
  }

  getUser(uid: string): Observable<any> {
    return this.http.get<any>(`${this.baseUrl}/users/${uid}`, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  getUserDevices(uid: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/users/${uid}/devices`, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  toggleUserStatus(uid: string, isActive: boolean): Observable<any> {
    return this.http.patch<any>(`${this.baseUrl}/users/${uid}/status`, { is_active: isActive }, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  deleteUser(uid: string): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/users/${uid}`, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  // ── Device Data ──────────────────────────────────────────────────────
  getDeviceList(): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/devices`, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  getDeviceData(deviceId: string, limit = 100, from?: string, to?: string): Observable<any[]> {
    let params = new HttpParams().set('limit', limit);
    if (from) params = params.set('from', from);
    if (to) params = params.set('to', to);
    return this.http.get<any[]>(`${this.baseUrl}/devices/${deviceId}/data`, { headers: this.headers, params })
      .pipe(catchError((e) => this.handleError(e)));
  }

  downloadCsv(deviceId: string, from?: string, to?: string): Observable<Blob> {
    let params = new HttpParams();
    if (from) params = params.set('from', from);
    if (to) params = params.set('to', to);
    return this.http.get(`${this.baseUrl}/devices/${deviceId}/data/csv`, {
      headers: this.headers,
      params,
      responseType: 'blob'
    }).pipe(catchError((e) => this.handleError(e)));
  }

  downloadExcel(deviceId: string, from?: string, to?: string): Observable<Blob> {
    let params = new HttpParams();
    if (from) params = params.set('from', from);
    if (to) params = params.set('to', to);
    return this.http.get(`${this.baseUrl}/devices/${deviceId}/data/excel`, {
      headers: this.headers,
      params,
      responseType: 'blob'
    }).pipe(catchError((e) => this.handleError(e)));
  }

  getLiveData(uid: string): Observable<any[]> {
    return this.http.get<any[]>(`${this.baseUrl}/users/${uid}/data/live`, { headers: this.headers })
      .pipe(catchError((e) => this.handleError(e)));
  }

  downloadUserCsv(uid: string, from?: string, to?: string): Observable<Blob> {
    let params = new HttpParams();
    if (from) params = params.set('from', from);
    if (to) params = params.set('to', to);
    return this.http.get(`${this.baseUrl}/users/${uid}/data/csv`, {
      headers: this.headers,
      params,
      responseType: 'blob'
    }).pipe(catchError((e) => this.handleError(e)));
  }

  downloadUserExcel(uid: string, from?: string, to?: string): Observable<Blob> {
    let params = new HttpParams();
    if (from) params = params.set('from', from);
    if (to) params = params.set('to', to);
    return this.http.get(`${this.baseUrl}/users/${uid}/data/excel`, {
      headers: this.headers,
      params,
      responseType: 'blob'
    }).pipe(catchError((e) => this.handleError(e)));
  }
}
