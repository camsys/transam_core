json.image do 
  json.partial! 'api/v1/images/image', image: @image
end