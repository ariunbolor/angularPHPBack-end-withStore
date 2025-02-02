import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ApiTestService {
  constructor(private http: HttpClient) {}

  testConnection(): Observable<any> {
    return this.http.get(`${environment.apiUrl}/test.php`);
  }
}