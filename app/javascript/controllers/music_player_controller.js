import { Controller } from "@hotwired/stimulus"

const debounceDisableSkipToEndTimeout = 500;

export default class MusicPlayer extends Controller {
  static targets = [ "playPause", "trackName", "progress", "currentTime", "duration", "volume", "muteUnmute", "songTable", "musicList" ]

  connect() {
    if (this.element.dataset.connected) return
    this.element.dataset.connected = 'true'

    this.audioElement = this.element.querySelector('#audio-element')
    this.audioElement.volume = 0.5;
    this.tracks = []
    this.currentTrackIndex = 0
    this.disableSkipToEnd = false

    this.fetchTracks()
    this.updateButtonState()

    // Add event listeners for play and pause events
    this.audioElement.addEventListener('play', () => this.updateButtonState())
    this.audioElement.addEventListener('pause', () => this.updateButtonState())

    navigator.mediaSession.setActionHandler(
      'nexttrack',
      ()=>{this.nextTrack()}
    );
    navigator.mediaSession.setActionHandler(
        'previoustrack',
        ()=>{this.previousTrack()}
    );

    this.progressTarget.addEventListener('input', this.seek.bind(this));
    this.volumeTarget.addEventListener('input', this.setVolume.bind(this));
    
    this.audioElement.addEventListener('timeupdate', this.updateProgress.bind(this));
    this.audioElement.addEventListener('loadedmetadata', this.updateDuration.bind(this));
    
    this.updateMuteButtonState();
    let thisContext = this;

    this.audioElement.addEventListener('ended', ()=>{thisContext.nextTrack()});

    document.addEventListener('keydown', function(event) {
      if (!["input", "textarea"].includes(document.activeElement.tagName.toLowerCase()) || !["text", "password"].includes(document.activeElement.type)) {
        if (['Space', 'Enter', 'KeyP'].includes(event.code)) {
          thisContext.togglePlay();
          event.preventDefault();
        } else if (event.code === 'KeyM') {
          thisContext.toggleMute();
          event.preventDefault();
        } else if (event.code === 'KeyL') {
          thisContext.toggleList();
          event.preventDefault();
        } else if (event.code === 'ArrowRight') {
          if(!thisContext.disableSkipToEnd) {
            thisContext.nextTrack()
          }
          if(!thisContext.disableSkipToEnd) {
            thisContext.disableSkipToEnd = true;
            window.setTimeout(()=>{thisContext.disableSkipToEnd = false;}, debounceDisableSkipToEndTimeout)
          }
          event.preventDefault();
        } else if (event.code === 'ArrowLeft') {
          if(!thisContext.disableSkipToEnd) {
            thisContext.previousTrack()
          }
          if(!thisContext.disableSkipToEnd) {
            thisContext.disableSkipToEnd = true;
            window.setTimeout(()=>{thisContext.disableSkipToEnd = false;}, debounceDisableSkipToEndTimeout)
          }
          event.preventDefault();
        }
      }
    });

    document.addEventListener('set-track', function(event) {
        thisContext.setTrack(event.detail.index)
      }
    )

    window.setTrack = (index) => {
      let event = new CustomEvent('set-track', { detail: {index} });
      document.dispatchEvent(event)
    }
  }

  async fetchTracks() {
    const response = await fetch('/music_player.json')
    this.tracks = await response.json()
    window.tracks = this.tracks;
    this.updateTrack(false) // Don't autoplay when first loading tracks
  }

  togglePlay() {
    if (this.audioElement.paused) {
      this.audioElement.play()
    } else {
      this.audioElement.pause()
    }
  }

  nextTrack() {
    this.currentTrackIndex = (this.currentTrackIndex + 1) % this.tracks.length
    this.updateTrack()
  }

  setTrack(index) {
    this.currentTrackIndex = index % this.tracks.length
    this.updateTrack()
  }

  previousTrack() {
    this.currentTrackIndex = (this.currentTrackIndex - 1 + this.tracks.length) % this.tracks.length
    this.updateTrack()
  }

  updateTrack(autoplay = true) {
    const track = this.tracks[this.currentTrackIndex]
    this.audioElement.src = track.url
    this.trackNameTarget.textContent = track.name
    if (autoplay) {
      this.audioElement.play()
    }
    this.updateButtonState()
    this.updateTrackList();
  }

  updateButtonState() {
    this.playPauseTarget.textContent = this.audioElement.paused ? "Play" : "Pause"
  }

  seek(event) {
    const time = (this.audioElement.duration / 100) * event.target.value;
    if (!Number.isNaN(time) && !(event.target.value >= 100 && this.disableSkipToEnd)){
      this.audioElement.currentTime = time;
    } else {
      event.preventDefault()
    }

    if(event.target.value >= 100 && !this.disableSkipToEnd) {
      this.disableSkipToEnd = true;
      let thisContext = this;
      window.setTimeout(()=>{thisContext.disableSkipToEnd = false;}, debounceDisableSkipToEndTimeout)
    }
  }
  
  setVolume(event) {
    this.audioElement.volume = event.target.value;
  }
  
  toggleMute() {
    this.audioElement.muted = !this.audioElement.muted;
    this.updateMuteButtonState();
  }
  
  updateMuteButtonState() {
    this.muteUnmuteTarget.classList.remove("mute");
    this.muteUnmuteTarget.classList.remove("unMute");
    if(this.audioElement.muted) {
      this.muteUnmuteTarget.setAttribute('aria-label', 'Unmute');
      this.muteUnmuteTarget.classList.add("unMute")
    } else {
      this.muteUnmuteTarget.setAttribute('aria-label', 'Mute');
      this.muteUnmuteTarget.classList.add("mute")
    }
  }

  updateProgress() {
    const currentTime = this.formatTime(this.audioElement.currentTime);
    this.currentTimeTarget.textContent = currentTime;
    this.progressTarget.value = (this.audioElement.currentTime / this.audioElement.duration) * 100 || 0;
  }
  
  updateDuration() {
    const duration = this.formatTime(this.audioElement.duration);
    this.durationTarget.textContent = duration;
  }
  
  formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = Math.floor(seconds % 60);
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
  }

  updateButtonState() {
    this.playPauseTarget.classList.remove("play");
    this.playPauseTarget.classList.remove("pause");
    if(this.audioElement.paused) {
      this.playPauseTarget.setAttribute('aria-label', 'Play');
      this.playPauseTarget.classList.add("play")
    } else {
      this.playPauseTarget.setAttribute('aria-label', 'Pause');
      this.playPauseTarget.classList.add("pause")
    }
  }

  updateTrackList() {
    let content = ""
    for (let i = 0; i < this.tracks.length; i++ ) {
      content += `<tr><td onclick="setTrack(${i})" class="${this.currentTrackIndex == i ? "current" : ""}">${this.tracks[i].name}</td></tr>`
    }
    this.songTableTarget.innerHTML = content;
  }

  toggleList() {
    if(this.musicListTarget.classList.contains("closed")) {
      this.musicListTarget.classList.remove("closed")
      this.musicListTarget.classList.add("open")
    } else {
      this.musicListTarget.classList.add("closed")
      this.musicListTarget.classList.remove("open")
    }
  }
}