import React from 'react';
import Photo from './Photo';
import './Gallery.css';

const photos = [
  { id: 1, src: `${process.env.PUBLIC_URL}/images/one.jpg`, title: 'Photo 1' },
  { id: 2, src: `${process.env.PUBLIC_URL}/images/two.jpg`, title: 'Photo 2' },
  { id: 3, src: `${process.env.PUBLIC_URL}/images/three.jpg`, title: 'Photo 3' },
  { id: 4, src: `${process.env.PUBLIC_URL}/images/four.jpg`, title: 'Photo 4' },
];

const Gallery = () => {
  return (
    <div className="gallery">
      {photos.map(photo => (
        <Photo key={photo.id} src={photo.src} title={photo.title} />
      ))}
    </div>
  );
};

export default Gallery;