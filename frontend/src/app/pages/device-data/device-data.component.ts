import { Component } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-device-data', templateUrl: './device-data.component.html', styleUrls: ['./device-data.component.css'] })
export class DeviceDataComponent {
  deviceId = '';
  from = '';
  to = '';
  readings: any[] = [];
  loading = false;
  liveRefresh = false;
  private refreshInterval: any;

  constructor(private api: ApiService) {}

  load(): void {
    if (!this.deviceId.trim()) return;
    this.loading = true;
    this.api.getDeviceData(this.deviceId, 200, this.from || undefined, this.to || undefined)
      .subscribe({ next: (d) => { this.readings = d; this.loading = false; }, error: () => { this.loading = false; } });
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
