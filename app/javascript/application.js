// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import mammoth from 'mammoth'

window.mammoth = mammoth;

const resizeObserver = new ResizeObserver(entries => {
    const musicPlayerHeight = entries[0].target.offsetHeight;
    document.querySelector('header').style.marginTop = musicPlayerHeight + 'px';
});

resizeObserver.observe(document.querySelector('.music-player'));