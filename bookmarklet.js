// original
javascript:(function(){
  var URL = 'http://mustachify.me/magickly?mustachify=true&src=';
  var images = document.getElementsByTagName('img');
  var i;
  for (i = 0; i < images.length; i += 1){
    var image = images[i];
    var src = image.getAttribute('src');
    if (image.src[0] === '/'){
      image.setAttribute('src', URL + encodeURIComponent(window.location.origin + src));
    } else if (src.match(/^https?:\/\//)) {
      image.setAttribute('src', URL + encodeURIComponent(src));
    }
  }
})();

// JSMin'd
javascript:(function(){var URL='http://mustachify.me/magickly?mustachify=true&src=';var images=document.getElementsByTagName('img');var i;for(i=0;i<images.length;i+=1){var image=images[i];var src=image.getAttribute('src');if(image.src[0]==='/'){image.setAttribute('src',URL+encodeURIComponent(window.location.origin+src));}else if(src.match(/^https?:\/\//)){image.setAttribute('src',URL+encodeURIComponent(src));}}})();
