import React from 'react';
import './Photo.css';

const Photo = ({ src, title }) => {
  return (
    <div className="photo">
      <img src={src} alt={title} />
      <p>{title}</p>
    </div>
  );
};

export default Photo;