module FeedsHelper
  
  def self.resize_and_crop(image, size)
    if image[:width] < image[:height]
      trim = image[:height] - image[:width]
      remove = (trim / 2).round
      image.shave("0x#{remove}")
    elsif image[:width] > image[:height]
      trim = image[:width] - image[:height]
      remove = (trim/2).round
      image.shave("#{remove}x0")
    end
    image.resize("#{size}x#{size}")
    return image
  end
  
  def self.upload_thumbnail_to_aws(thumbnail, bucket_name)
    s3 = AWS::S3.new
    bucket = s3.buckets[bucket_name]
    obj_key = "#{(0...8).map{(65+rand(26)).chr}.join}.#{thumbnail["format"].downcase}"
    file_location = "#{Rails.root}/tmp/#{obj_key}"
    thumbnail.write file_location
    obj = bucket.objects[obj_key].write(open(file_location), {:acl=>:public_read})
    FileUtils.rm file_location
    return "http://s3.amazonaws.com/#{bucket_name}/#{obj_key}"
  end
end
