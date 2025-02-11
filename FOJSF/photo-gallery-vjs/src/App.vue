<template>
  <div id="app">
    <h1>Photo Gallery</h1>
    <PhotoGallery />
  </div>
</template>

<script>
import PhotoGallery from './components/PhotoGallery.vue';

export default {
  name: 'App',
  components: {
    PhotoGallery
  }
};
</script>

<style>
#app {
  text-align: center;
}

h1 {
  margin-top: 20px;
}
</style>