import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-photo',
  template: './photo.component.html',
  styleUrls: ['./photo.component.css'],
  standalone: true // Mark the component as standalone if using Angular 14+
})
export class PhotoComponent {
  @Input() src!: string;
  @Input() title!: string;
}