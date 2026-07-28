import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({ selector: 'app-login', templateUrl: './login.component.html', styleUrls: ['./login.component.css'] })
export class LoginComponent {
  form: FormGroup;
  error = '';
  loading = false;
  showPassword = false;

  constructor(private fb: FormBuilder, private auth: AuthService, private router: Router) {
    this.form = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]],
    });
  }

  submit(): void {
    if (this.form.invalid) return;
    this.loading = true; this.error = '';
    const { email, password } = this.form.value;
    this.auth.login(email, password).subscribe({
      next: () => { this.loading = false; this.router.navigate(['/']); },
      error: () => { this.loading = false; this.error = 'Invalid email or password.'; },
    });
  }
}
