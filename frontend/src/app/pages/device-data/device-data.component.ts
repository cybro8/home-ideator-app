import { Component, OnInit, OnDestroy } from '@angular/core';
import { ApiService } from '../../services/api.service';

@Component({ selector: 'app-device-data', templateUrl: './device-data.component.html', styleUrls: ['./device-data.component.css'] })
export class DeviceDataComponent implements OnInit, OnDestroy {
  deviceId = '';
  from = '';
  to = '';
  readings: any[] = [];
  deviceList: any[] = [];
  userGroups: { user_name: string, devices: any[] }[] = [];
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
        // Group by user_name
        const groups: { [key: string]: any[] } = {};
        for (const d of list) {
          const userName = d.user_name || 'Unknown User';
          if (!groups[userName]) groups[userName] = [];
          groups[userName].push(d);
        }
        this.userGroups = Object.keys(groups).sort().map(k => ({
          user_name: k,
          devices: groups[k]
        }));
        
        if (list.length) {
          this.deviceId = list[0].device_id;  // auto-select first device
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
    if (!this.deviceId) return;
    this.api.downloadCsv(this.deviceId, this.from || undefined, this.to || undefined).subscribe((blob) => {
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${this.deviceId}_data.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      a.remove();
    });
  }

  downloadExcel(): void {
    if (!this.deviceId) return;
    this.api.downloadExcel(this.deviceId, this.from || undefined, this.to || undefined).subscribe((blob) => {
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${this.deviceId}_data.xlsx`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      a.remove();
    });
  }

  downloadUserCsv(): void {
    if (!this.deviceId) return;
    // Find the user_uid for the selected device
    let userUid = '';
    for (const group of this.userGroups) {
      const device = group.devices.find(d => d.device_id === this.deviceId);
      if (device) {
        userUid = device.user_uid;
        break;
      }
    }
    if (!userUid) return;

    this.api.downloadUserCsv(userUid, this.from || undefined, this.to || undefined).subscribe((blob) => {
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `user_${userUid}_all_devices_data.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      a.remove();
    });
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
