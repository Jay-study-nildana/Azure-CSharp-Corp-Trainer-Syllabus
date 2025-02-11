import { bootstrapApplication } from '@angular/platform-browser';
import { appConfig } from './app/app.config';
import { AppComponent } from './app/app.component';
import { importProvidersFrom } from '@angular/core';
import { GalleryComponent } from './app/gallery/gallery.component'; // Import the standalone component
import { HelloWorldComponent } from './app/hello-world/hello-world.component';

bootstrapApplication(AppComponent, {
  ...appConfig,
  providers: [
    importProvidersFrom(GalleryComponent, HelloWorldComponent) // Add the standalone component to providers
  ]
})
  .catch((err) => console.error(err));