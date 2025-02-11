import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { PhotoComponent } from '../photo/photo.component'; // Import the standalone component

@Component({
  selector: 'app-gallery',
  template: './gallery.component.html',
  styleUrls: ['./gallery.component.css'],
  standalone: true,
  imports: [CommonModule, PhotoComponent] // Add the standalone component to imports
})
export class GalleryComponent {
  photos = [
    { id: 1, src: 'assets/one.jpg', title: 'Photo 1' },
    { id: 2, src: 'assets/two.jpg', title: 'Photo 2' },
    { id: 3, src: 'assets/three.jpg', title: 'Photo 3' },
    { id: 4, src: 'assets/four.jpg', title: 'Photo 4' },
  ];
}