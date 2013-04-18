# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
feeds = Feed.create([
  {name: 'Cloudspace Blog',         url: 'http://feeds.feedburner.com/TheCloudspaceBlog'},
  {name: 'Engadget',                url: 'http://www.engadget.com/rss.xml'},
  {name: 'The Verge',               url: 'http://www.theverge.com/rss/index.xml'},
  {name: 'CNN Top Stories',         url: 'http://rss.cnn.com/rss/cnn_topstories.rss'},
  {name: 'CNN World',               url: 'http://rss.cnn.com/rss/cnn_world.rss'},
  {name: 'CNN U.S.',                url: 'http://rss.cnn.com/rss/cnn_us.rss'},
  {name: 'CNN Business',            url: 'http://rss.cnn.com/rss/money_latest.rss'},
  {name: 'CNN Politics',            url: 'http://rss.cnn.com/rss/cnn_allpolitics.rss'},
  {name: 'CNN Crime',               url: 'http://rss.cnn.com/rss/cnn_crime.rss'},
  {name: 'Joel on Software',        url: 'http://www.joelonsoftware.com/rss.xml'},
  {name: 'prolly not funny',        url: 'http://feeds.feedburner.com/prollynotfunny'},
  {name: 'Doctor Cat MD',           url: 'http://doctorcatmd.com/feed'},
  {name: 'Atomic-Robo.com',         url: 'http://www.atomic-robo.com/feed/'},
  {name: 'duss005.com',             url: 'http://feeds.feedburner.com/duss005'},
  {name: 'Ars Technica',            url: 'http://feeds.arstechnica.com/arstechnica/index/'},
  {name: 'Coloring for Grown-ups',  url: 'http://coloringforgrownups.com/rss'},
])







