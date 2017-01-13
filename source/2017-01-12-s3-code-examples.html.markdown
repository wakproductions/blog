---
title: AWS S3 Code Examples in Ruby (aws-sdk 2.0)
date: 2017-01-12 01:30 EST
tags:
---

### Logging in and creating an S3 object. The environment variables are set via Figaro.

```ruby
s3 = Aws::S3::Client.new(access_key_id: ENV['AMAZON_S3_KEY_ID'], secret_access_key: ENV['AMAZON_S3_SECRET'])
s3.list_buckets
=> #<struct Aws::S3::Types::ListBucketsOutput
 buckets=
  [...]
```

### Create a bucket

```ruby
resp = s3.create_bucket({ bucket: "analytics-office-data" })
```

### Upload a file

On S3 there's a limitation on the number of buckets you can use, and there's no such thing as a concept of a folder.
However, you can mimic folders using the `prefix` feature.

```ruby
file_name = 'SDI_Download_Data-20140930.csv' 
prefix='downloaded_files'

file_path=File.join(SOURCE_DIR, file_name)
contents = File.open(file_path,'r') { |f| f.read }
s3.put_object(bucket: 'analytics-office-data', key: "#{prefix}/#{file_name}", body: contents)
```

or more conscise:

```ruby
File.open(file_path, 'rb') do |file|
  s3.put_object(bucket: 'analytics-office-data', key: "#{prefix}/#{file_name}", body: file)
end
```

[Another good resource](https://aws.amazon.com/blogs/developer/uploading-files-to-amazon-s3/)

### Read back that file

```ruby
prefix='downloaded_files'
s3.list_objects({ bucket: 'analytics-office-data', prefix: prefix })
=> #<struct Aws::S3::Types::ListObjectsOutput
 is_truncated=false,
 marker="",
 next_marker=nil,
 contents=
  [#<struct Aws::S3::Types::Object
    key="SDI_Download_Data-20140930.csv",
    last_modified=2017-01-12 18:19:34 UTC,
    etag="\"411adb204166d574987bacde05b1d1dd\"",
    size=2404972,
    storage_class="STANDARD",
  ],
 name="analytics-office-data",
 prefix="",
 delimiter=nil,
 max_keys=1000,
 common_prefixes=[],
 encoding_type="url">
 
 r = s3.get_object({ bucket: 'analytics-office-data', key: "#{prefix}/SDI_Download_Data-20140930.csv" })
 => #<struct Aws::S3::Types::GetObjectOutput
  body=#<StringIO:0x007f808669ed40>,
  delete_marker=nil,
  accept_ranges="bytes",
  expiration=nil,
  restore=nil,
  last_modified=2017-01-12 19:13:50 +0000,
  content_length=2404972,
  etag="\"411adb204166d574987bacde05b1d1dd\"",
  missing_meta=nil,
  version_id=nil,
  cache_control=nil,
  content_disposition=nil,
  content_encoding=nil,
  content_language=nil,
  content_range=nil,
  content_type="",
  expires=nil,
  expires_string=nil,
  website_redirect_location=nil,
  server_side_encryption=nil,
  metadata={},
  sse_customer_algorithm=nil,
  sse_customer_key_md5=nil,
  ssekms_key_id=nil,
  storage_class=nil,
  request_charged=nil,
  replication_status=nil>
  
file_contents = r.body.read  
```

An alternative way of reading is:

```ruby
file_contents = AWS::S3.new.buckets['analytics-office-data'].objects['#{prefix}/SDI_Download_Data-20140930.csv'].read
```
