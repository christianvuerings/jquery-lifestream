TorqueBox.configure do
  # process incoming JMS messages from activeMQ
  service JmsWorker

  # warm up active users caches once a day
  job HotPlate do
    cron '0 1 8 * * ? *'
    singleton true
  end

  # set up messaging queues
  queue '/queues/hot_plate' do
    durable false
    processor HotPlate do
      if ENV['RAILS_ENV'] == 'production'
        concurrency 3
      end
    end
  end
  queue '/queues/warmup_request' do
    durable false
    processor LiveUpdatesWarmer do
      if ENV['RAILS_ENV'] == 'production'
        concurrency 3
      end
    end
  end
  queue '/queues/feed_changed' do
    durable false
    processor FeedUpdateWhiteboard
  end
end

#
#jobs:
#    hot.plate:
#    job: HotPlate
#cron: '0 1 8 * * ? *'
#singleton: true
#
#queues:
#    /queues/hot_plate:
#    durable: false
#/queues/warmup_request:
#    durable: false
#/queues/feed_changed:
#    durable: false
#
#messaging:
#    /queues/hot_plate:
#    HotPlate:
#    concurrency: 1
#/queues/warmup_request:
#    LiveUpdatesWarmer:
#    concurrency: 1
#/queues/feed_changed:
#    FeedUpdateWhiteboard:
#    singleton: false




