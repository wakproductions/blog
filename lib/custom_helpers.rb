module CustomHelpers
  def social_media_image(meta_image_path)
    URI.join(config[:base_url], meta_image_path || 'images/blog-default-social-media-image.jpg')
  end
end