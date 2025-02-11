<template>
  <div class="photo">
    <img :src="src" :alt="title" />
    <p>{{ title }}</p>
  </div>
</template>

<script>
export default {
  name: 'PhotoItem',
  props: {
    src: {
      type: String,
      required: true
    },
    title: {
      type: String,
      required: true
    }
  }
};
</script>

<style scoped>
.photo {
  border: 2px solid #ccc;
  padding: 10px;
  text-align: center;
}
.photo img {
  max-width: 100%;
  height: auto;
}
</style>