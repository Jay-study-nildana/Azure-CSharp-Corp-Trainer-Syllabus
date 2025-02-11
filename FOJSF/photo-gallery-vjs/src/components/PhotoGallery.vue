<template>
  <div class="gallery">
    <PhotoItem
      v-for="photo in photos"
      :key="photo.id"
      :src="photo.src"
      :title="photo.title"
    />
  </div>
</template>

<script>
import PhotoItem from './PhotoItem.vue';

export default {
  name: 'PhotoGallery',
  components: {
    PhotoItem
  },
  data() {
    return {
      photos: [
        { id: 1, src: require('@/assets/one.jpg'), title: 'Photo 1' },
        { id: 2, src: require('@/assets/two.jpg'), title: 'Photo 2' },
        { id: 3, src: require('@/assets/three.jpg'), title: 'Photo 3' },
        { id: 4, src: require('@/assets/four.jpg'), title: 'Photo 4' },
      ]
    };
  }
};
</script>

<style scoped>
.gallery {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  justify-content: center;
  margin-top: 20px;
}
</style>