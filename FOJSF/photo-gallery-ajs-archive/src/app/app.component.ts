import { Component } from '@angular/core';
import { HelloWorldComponent } from './hello-world/hello-world.component';
import { GalleryComponent } from './gallery/gallery.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [HelloWorldComponent,GalleryComponent],
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'photo-gallery';
}