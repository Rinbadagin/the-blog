// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import mammoth from 'mammoth'

window.mammoth = mammoth;

function setHeaderMargin(heightOffset) {
  document.querySelector('header').style.marginTop = heightOffset + 'px'; 
}

const resizeObserver = new ResizeObserver(entries => {
    const musicPlayerHeight = entries[0].target.offsetHeight;
    setHeaderMargin(musicPlayerHeight);
});

resizeObserver.observe(document.querySelector('.music-player'));


window.addEventListener('turbo:render', ()=>{
  setHeaderMargin(document.querySelector('.music-player').offsetHeight)
})
