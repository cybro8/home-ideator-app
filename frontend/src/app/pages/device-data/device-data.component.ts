import { Component, OnInit, OnDestroy } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-device-data', templateUrl: './device-data.component.html', styleUrls: ['./device-data.component.css'] })
export class DeviceDataComponent implements OnInit, OnDestroy {
  deviceId = '';
  from = '';
  to = '';
  readings: any[] = [];
  deviceList: string[] = [];
  loading = false;
  liveRefresh = false;
  private refreshInterval: any;

  // Stats
  get anomalyCount(): number { return this.readings.filter(r => r.is_anomaly).length; }
  get avgVoltage(): number {
    if (!this.readings.length) return 0;
    return this.readings.reduce((s, r) => s + (r.Voltage || 0), 0) / this.readings.length;
  }
  get avgPower(): number {
    if (!this.readings.length) return 0;
    return this.readings.reduce((s, r) => s + (r.Power || 0), 0) / this.readings.length;
  }
  get avgTemp(): number {
    if (!this.readings.length) return 0;
    return this.readings.reduce((s, r) => s + (r.temperature_C || 0), 0) / this.readings.length;
  }

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.api.getDeviceList().subscribe({
      next: (list) => {
        this.deviceList = list;
        if (list.length) {
          this.deviceId = list[0];  // auto-select first device
          this.load();
        }
      },
      error: () => {}
    });
  }

  ngOnDestroy(): void {
    clearInterval(this.refreshInterval);
  }

  load(): void {
    if (!this.deviceId.trim()) return;
    this.loading = true;
    this.api.getDeviceData(this.deviceId, 200, this.from || undefined, this.to || undefined)
      .subscribe({
        next: (d) => { this.readings = d; this.loading = false; },
        error: () => { this.loading = false; }
      });
  }

  downloadCsv(): void {
    window.open(`${this.api.downloadCsv(this.deviceId)}`, '_blank');
  }

  downloadExcel(): void {
    window.open(`${this.api.downloadExcel(this.deviceId)}`, '_blank');
  }

  toggleLive(): void {
    this.liveRefresh = !this.liveRefresh;
    if (this.liveRefresh) {
      this.load();
      this.refreshInterval = setInterval(() => this.load(), 5000);
    } else {
      clearInterval(this.refreshInterval);
    }
  }
}
